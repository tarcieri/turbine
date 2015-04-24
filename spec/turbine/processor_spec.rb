require "spec_helper"

RSpec.describe Turbine::Processor do
  let(:example_batch_size) { 1000 }
  let(:example_elements)   { (0...example_batch_size).to_a }
  let(:max_thread_count)   { 10 }

  it "processes batches of messages" do
    1.upto(max_thread_count) do |thread_count|
      example_batch = Turbine::Batch.new(*example_elements)

      mock_consumer = double(:consumer)
      allow(mock_consumer).to receive(:fetch).and_return(example_batch, nil)

      processor = described_class.new(
        min_threads: thread_count,
        max_threads: thread_count,
        max_queue: 100
      )

      processor.process(mock_consumer) do |message|
        # noop!
      end

      processor.drain
      expect(example_batch).to be_completed
    end
  end
end
