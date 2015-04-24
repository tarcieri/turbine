require "spec_helper"

RSpec.describe Turbine::Batch do
  let(:example_elements) { (0...max_thread_count).to_a }
  let(:example_batch)    { described_class.new(*example_elements) }
  let(:max_thread_count) { 100 }

  it "creates batches from arrays" do
    example_elements.size.times do |n|
      expect(example_batch[n]).to eq example_elements[n]
    end
  end

  it "defaults to all job completions being false" do
    expect(example_batch.completed.all? { |x| x == false }).to eq true
  end

  it "marks completions in a thread-safe manner" do
    1.upto(max_thread_count) do |thread_count|
      batch = described_class.new(*(0..thread_count).to_a)
      expect(batch).to_not be_completed

      threads = []
      (0..thread_count).sort_by { rand }.each do |n|
        threads << Thread.new { batch.complete(n) }
      end
      threads.each(&:join)

      expect(batch).to be_completed
    end
  end

  it "inspects" do
    expect(example_batch.inspect).to include described_class.to_s
  end
end
