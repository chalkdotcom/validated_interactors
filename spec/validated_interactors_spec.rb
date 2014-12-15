require 'spec_helper'

describe ValidatedInteractors::Interactor do
  let(:interactor) do
    Class.new do
      include ValidatedInteractors::Interactor
      def perform; end
    end
  end

  describe ".process" do
    let(:interactor_object) { interactor.new }
    subject(:process) { interactor_object.process }

    it { should be_instance_of interactor }
    it { interactor.any_instance.should_receive(:valid?); process }
    it "calls perform if valid returns true" do
      interactor.any_instance.stub(:valid?).and_return(true)
      interactor_object.should_receive(:perform)

      process
    end
    it "calls fail! if valid returns false" do
      interactor.any_instance.stub(:valid?).and_return(false)
      interactor_object.should_receive(:fail!)

      process
    end
    it "succeeds if valid returns true by default" do
      interactor.any_instance.stub(:valid?).and_return(true)
      process
      expect(interactor_object.success?).to eq(true)
    end
    it "fails if valid returns false" do
      interactor.any_instance.stub(:valid?).and_return(false)
      process
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

    it "fails the object" do
      interactor_object.fail!
      expect(interactor_object.success?).to eq(false)
    end

    it "adds any hash into errors" do
      interactor_object.fail! message: "UH OH"
      expect(interactor_object.errors.get(:message)).to eq(["UH OH"])
    end

    it "throws an exception if any arguments are not hashes" do
      expect { interactor_object.fail! "TEST" }.to raise_error(ArgumentError)
    end
  end
end