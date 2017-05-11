module WorkflowFork
  class Error < StandardError; end
  class WorkflowDefinitionError < Error; end
  class NoTransitionAllowed < Error; end
end
