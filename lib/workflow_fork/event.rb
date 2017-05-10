module WorkflowFork
  class Event
    attr_accessor :name, :transitions_to, :meta, :action, :condition

    def initialize(name, transitions_to, condition = nil, meta = {}, &action)
      @name = name
      @transitions_to = transitions_to
      @meta = meta
      @action = action
    end
  end
end
