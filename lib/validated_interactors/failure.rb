module ValidatedInteractors
  class Failure < StandardError
    attr_reader :context

    def initialize(context = nil)
      @context = context
    end
  end
end