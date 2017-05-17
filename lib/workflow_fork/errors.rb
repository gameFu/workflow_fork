module WorkflowFork
  class Error < StandardError; end
  class TransitionHalted < Error
    def initialize(msg = nil)
      super msg
    end
  end
  class WorkflowDefinitionError < Error; end
  class NoTransitionAllowed < Error; end
end
