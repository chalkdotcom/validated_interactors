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

    def success?
      raise ValidatedInteractors::ProcessNotCalled, "I think you forgot to call process!" if @succeeded.nil?

      @succeeded
    end

    def failure?
      !success?
    end

    def fail!(args = {})
      raise ArgumentError, "fail! only accepts no or hash arguments" unless args.is_a? Hash

      @succeeded = false

      args.each do |key, value|
        errors[key] = value
      end
    end
  end
end