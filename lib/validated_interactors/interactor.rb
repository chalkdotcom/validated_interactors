module ValidatedInteractors
  module Interactor
    def self.included(klass)
      klass.class_eval do
        include ActiveModel::Validations
      end
    end

    def process
      tap do
        if valid?
          @succeeded = true
          perform
        else
          fail!
        end
      end
    end

    def succeeded?
      raise ValidatedInteractors::ProcessNotCalled, "I think you forgot to call process!" if @succeeded.nil?

      @succeeded
    end

    def failed?
      !succeeded?
    end

    def fail!(args = {})
      raise ArgumentError, "fail! only excepts no or hash arguments" unless args.is_a? Hash

      @succeeded = false

      args.each do |key, value|
        errors[key] = value
      end
    end
  end
end