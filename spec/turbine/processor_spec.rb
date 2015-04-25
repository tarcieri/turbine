require "spec_helper"

RSpec.describe Turbine::Processor do
  let(:example_batch_size)  { 100 }
  let(:example_elements)    { (0...example_batch_size).to_a }
  let(:max_thread_count)    { 10 }
  let(:example_batch_count) { 100 }

  it "processes batches of messages" do
    1.upto(max_thread_count) do |thread_count|
      example_batches = Array.new(example_batch_count).fill do
        Turbine::Batch.new(example_elements)
      end

      mock_consumer = double(:consumer)
      allow(mock_consumer).to receive(:fetch).and_return(*example_batches, nil)

      processor = described_class.new(
        min_threads: thread_count,
        max_threads: thread_count,
        max_queue: 100
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
