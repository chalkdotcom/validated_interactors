require 'spec_helper'

describe ValidatedInteractors::Interactor do
  let(:interactor) do
    Class.new do
      include ValidatedInteractors::Interactor
      def initialize(args = nil); end
      def action; end
    end
  end

  describe "#call" do
    it "calls new with the arguments passed in" do
      args = "HELLO"
      interactor_object = interactor.new
      interactor.should_receive(:new).with(args) { interactor_object }

      interactor.call(args)
    end

    it "calls .call on a new object" do
      args = "HELLO"
      interactor.any_instance.should_receive(:call)

      interactor.call(args)
    end
  end

  describe ".call" do
    let(:interactor_object) { interactor.new }
    subject(:call) { interactor_object.call }

    it { should be_instance_of interactor }
    it { interactor.any_instance.should_receive(:valid?); call }
    it "calls perform if valid returns true" do
      interactor.any_instance.stub(:valid?).and_return(true)
      interactor_object.should_receive(:action)

      call
    end
    it "calls fail! if valid returns false" do
      interactor.any_instance.stub(:valid?).and_return(false)
      interactor_object.should_receive(:fail!)

      call
    end
    it "succeeds if valid returns true by default" do
      interactor.any_instance.stub(:valid?).and_return(true)
      call
      expect(interactor_object.success?).to eq(true)
    end
    it "fails if valid returns false" do
      interactor.any_instance.stub(:valid?).and_return(false)
      call
      expect(interactor_object.success?).to eq(false)
    end
  end

  describe ".success?" do
    let(:interactor_object) { interactor.new }

    it "throws an exception by default" do
      expect { interactor_object.success? }.to raise_error(ValidatedInteractors::ProcessNotCalled)
    end

    it "returns true if it succeeded" do
      interactor_object.instance_variable_set(:@succeeded, true)

      expect(interactor_object.success?).to eq(true)
    end

    it "returns false if it failed" do
      interactor_object.instance_variable_set(:@succeeded, false)

      expect(interactor_object.success?).to eq(false)
    end
  end

  describe ".failure?" do
    let(:interactor_object) { interactor.new }

    it "throws an exception by default" do
      expect { interactor_object.success? }.to raise_error(ValidatedInteractors::ProcessNotCalled)
    end

    it "returns false if it succeeded" do
      interactor_object.instance_variable_set(:@succeeded, true)

      expect(interactor_object.failure?).to eq(false)
    end

    it "returns true if it failed" do
      interactor_object.instance_variable_set(:@succeeded, false)

      expect(interactor_object.failure?).to eq(true)
    end
  end

  describe ".fail!" do
    subject(:interactor_object) { interactor.new }

    it "throws an exception" do
      expect { interactor_object.fail! }.to raise_error(ValidatedInteractors::Failure)
    end

    it "fails the object" do
      begin
        interactor_object.fail!
      rescue ValidatedInteractors::Failure => e
      end

      expect(interactor_object.success?).to eq(false)
    end

    it "adds any hash into errors" do
      begin
        interactor_object.fail! message: "UH OH"
      rescue ValidatedInteractors::Failure => e
      end

      expect(interactor_object.errors.get(:message)).to eq(["UH OH"])
    end

    it "adds any errors into errors" do
      errors = ActiveModel::Errors.new(interactor_object)
      errors[:message] = "UH OH"
      begin
        interactor_object.fail! errors
      rescue ValidatedInteractors::Failure => e
      end

      expect(interactor_object.errors.get(:message)).to eq(["UH OH"])
    end

    it "throws an exception if any arguments are not hashes" do
      expect { interactor_object.fail! "TEST" }.to raise_error(ArgumentError)
    end
  end
end