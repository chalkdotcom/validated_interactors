module ValidatedInteractors
  module Interactor
    def self.included(klass)
      klass.class_eval do
        include ActiveModel::Validations

        def self.call(*args)
          new(*args).call
        end

        def self.call!(*args)
          new(*args).call!
        end
      end
    end

    def call!
      tap do
        if valid?
          @succeeded = true
          action
        else
          fail!
        end
      end
    end

    def call
      call!
    rescue ValidatedInteractors::Failure => e
      return self
    end

    def success?
      raise ValidatedInteractors::ProcessNotCalled, "I think you forgot to call process!" if @succeeded.nil?

      @succeeded
    end

    def failure?
      !success?
    end

    def fail!(args = {})
      raise ArgumentError, "fail! only accepts no or hash arguments" unless args.is_a? Hash or args.is_a? ActiveModel::Errors

      @succeeded = false

      args.each do |key, value|
        errors[key] = value
      end

      raise ValidatedInteractors::Failure.new(self.errors)
    end
  end
end