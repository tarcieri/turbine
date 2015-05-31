require "spec_helper"

RSpec.describe Turbine::Processor do
  MIN_THREAD_COUNT = 2
  MAX_THREAD_COUNT = 16
  QUEUE_SIZE       = 100

  let(:example_batch_size)    { 100 }
  let(:example_partition)     { 0 }
  let(:example_batch_count)   { 1000 }
  let(:example_message_count) { example_batch_size * example_batch_count }

  let(:example_elements) do
    example_batch_size.times.map do |n|
      double(:message, value: n)
    end
  end

  let(:example_batches) do
    Array.new(example_batch_count).fill do
      Turbine::Batch.new(example_elements, example_partition)
    end
  end

  let(:mock_consumer) do
    double(:consumer).tap do |consumer|
      allow(consumer).to receive(:fetch).and_return(*example_batches, nil)
      allow(consumer).to receive(:commit)
    end
  end

  let(:example_processor) do
    described_class.new(
      min_threads: MAX_THREAD_COUNT,
      max_threads: MAX_THREAD_COUNT,
      max_queue:   QUEUE_SIZE
    )
  end

  it "supports stopping the event loop" do
    example_processor.stop
    expect(example_processor.running?).to eq false
  end

  it "counts the number of messages processed" do
    example_processor.process(mock_consumer) do |_msg|
      # noop!
    end

    example_processor.drain

    expect(example_processor.completed_count).to eq example_message_count
  end

  it "tolerates processing errors gracefully" do
    # Check the default handler is printing to STDERR
    expect(STDERR).to receive(:puts).at_most(example_message_count).times

    example_processor.process(mock_consumer) do |_msg, _ex|
      fail "uhoh!"
    end

    example_processor.drain
  end

  it "supports a custom error handler" do
    handler_called = false

    example_processor.error_handler do |_ex, _msg|
      handler_called = true
    end

    example_processor.process(mock_consumer) do |_ex, _msg|
      fail "uhoh!"
    end

    example_processor.drain
    expect(handler_called).to eq true
  end

  context "message processing" do
    MIN_THREAD_COUNT.upto(MAX_THREAD_COUNT) do |thread_count|
      it "processes batches of messages with #{thread_count} threads" do
        processor = described_class.new(
          min_threads: thread_count,
          max_threads: thread_count,
          max_queue:   QUEUE_SIZE
        )

        processor.process(mock_consumer) do |_msg|
          # noop!
        end

        processor.drain

        example_batches.each do |example_batch|
          expect(example_batch).to be_completed
        end
      end
    end
  end
end
