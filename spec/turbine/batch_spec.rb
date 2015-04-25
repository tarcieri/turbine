require "spec_helper"

RSpec.describe Turbine::Batch do
  let(:example_batch_size) { 13 }
  let(:example_elements)   { (0...13).to_a }
  let(:example_batch)      { described_class.new(example_elements) }

  it "creates batches from arrays" do
    example_elements.size.times do |n|
      expect(example_batch[n]).to eq example_elements[n]
    end
  end

  it "knows its size" do
    expect(example_batch.size).to eq example_batch_size
  end

  it "begins incomplete" do
    expect(example_batch).not_to be_completed
  end

  it "can be completed" do
    example_batch.complete
    expect(example_batch).to be_completed
  end

  it "inspects" do
    expect(example_batch.inspect).to include described_class.to_s
  end
end
