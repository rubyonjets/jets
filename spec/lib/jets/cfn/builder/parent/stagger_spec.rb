module Staggerable
  class Stack
    attr_reader :stagger_depends_on, :name
    def initialize(name, options={})
      @name = name
      @stagger_depends_on = []
    end

    def add_stagger_depends_on(*batch)
      @stagger_depends_on = batch.flatten.map(&:name)
    end
  end

  class Parent
    include Jets::Cfn::Builder::Parent::Stagger
    # override module method `stagger_enabled` in spec to always enable
    def stagger_enabled
      true
    end

    def initialize
      @list = []
    end

    def build(*stacks)
      stacks.flatten.each do |name|
        add_stack(name)
      end
      @list
    end

    def add_stack(name)
      current_stack = Stack.new(name)
      add_stagger(current_stack)
      @list << current_stack
    end
  end
end

describe Jets::Cfn::Builder::Parent::Stagger do
  let(:builder) do
    parent = Staggerable::Parent.new
    allow(parent).to receive(:stagger_batch_size).and_return(batch_size)
    parent
  end

  context "even number of resources in" do
    let(:resources) { (1..6).map { |i| "stack#{i}" } }
    context "batches of 0" do
      let(:batch_size) { 0 }
      it "ok" do
        list = builder.build(resources)
        list.each do |stack|
          expect(stack.stagger_depends_on).to eq([])
        end
      end
    end

    context "batches of 2" do
      let(:batch_size) { 2 }
      it "ok" do
        list = builder.build(resources)
        expect(list[0].stagger_depends_on).to eq([])
        expect(list[1].stagger_depends_on).to eq([])
        expect(list[2].stagger_depends_on).to eq(%w[stack1 stack2])
        expect(list[3].stagger_depends_on).to eq(%w[stack1 stack2])
        expect(list[4].stagger_depends_on).to eq(%w[stack3 stack4])
        expect(list[5].stagger_depends_on).to eq(%w[stack3 stack4])
      end
    end

    context "batches of 3" do
      let(:batch_size) { 3 }
      it "ok" do
        list = builder.build(resources)
        expect(list[0].stagger_depends_on).to eq([])
        expect(list[1].stagger_depends_on).to eq([])
        expect(list[2].stagger_depends_on).to eq([])
        expect(list[3].stagger_depends_on).to eq(%w[stack1 stack2 stack3])
        expect(list[4].stagger_depends_on).to eq(%w[stack1 stack2 stack3])
        expect(list[5].stagger_depends_on).to eq(%w[stack1 stack2 stack3])
      end
    end

    context "batches of 4" do
      let(:batch_size) { 4 }
      it "ok" do
        list = builder.build(resources)
        expect(list[0].stagger_depends_on).to eq([])
        expect(list[1].stagger_depends_on).to eq([])
        expect(list[2].stagger_depends_on).to eq([])
        expect(list[3].stagger_depends_on).to eq([])
        expect(list[4].stagger_depends_on).to eq(%w[stack1 stack2 stack3 stack4])
        expect(list[5].stagger_depends_on).to eq(%w[stack1 stack2 stack3 stack4])
      end
    end
  end

  context "odd number of resources in" do
    let(:resources) { (1..7).map { |i| "stack#{i}" } }
    context "batches of 2" do
      let(:batch_size) { 2 }
      it "ok" do
        list = builder.build(resources)
        expect(list[0].stagger_depends_on).to eq([])
        expect(list[1].stagger_depends_on).to eq([])
        expect(list[2].stagger_depends_on).to eq(%w[stack1 stack2])
        expect(list[3].stagger_depends_on).to eq(%w[stack1 stack2])
        expect(list[4].stagger_depends_on).to eq(%w[stack3 stack4])
        expect(list[5].stagger_depends_on).to eq(%w[stack3 stack4])
        expect(list[6].stagger_depends_on).to eq(%w[stack5 stack6])
      end
    end

    context "batches of 3" do
      let(:batch_size) { 3 }
      it "ok" do
        list = builder.build(resources)
        expect(list[0].stagger_depends_on).to eq([])
        expect(list[1].stagger_depends_on).to eq([])
        expect(list[2].stagger_depends_on).to eq([])
        expect(list[3].stagger_depends_on).to eq(%w[stack1 stack2 stack3])
        expect(list[4].stagger_depends_on).to eq(%w[stack1 stack2 stack3])
        expect(list[5].stagger_depends_on).to eq(%w[stack1 stack2 stack3])
        expect(list[6].stagger_depends_on).to eq(%w[stack4 stack5 stack6])
      end
    end

    context "batches of 4" do
      let(:batch_size) { 4 }
      it "ok" do
        list = builder.build(resources)
        expect(list[0].stagger_depends_on).to eq([])
        expect(list[1].stagger_depends_on).to eq([])
        expect(list[2].stagger_depends_on).to eq([])
        expect(list[3].stagger_depends_on).to eq([])
        expect(list[4].stagger_depends_on).to eq(%w[stack1 stack2 stack3 stack4])
        expect(list[5].stagger_depends_on).to eq(%w[stack1 stack2 stack3 stack4])
        expect(list[6].stagger_depends_on).to eq(%w[stack1 stack2 stack3 stack4])
      end
    end
  end

  context "0 number of resources in" do
    let(:resources) { [] }
    context "batches of 2" do
      let(:batch_size) { 2 }
      it "ok" do
        list = builder.build(resources)
        expect(list).to eq([])
      end
    end
  end
end
