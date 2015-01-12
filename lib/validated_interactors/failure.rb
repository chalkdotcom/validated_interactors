module ValidatedInteractors
  class Failure < StandardError
    attr_reader :errors

    def initialize(errors)
      @errors = errors
    end
  end
end