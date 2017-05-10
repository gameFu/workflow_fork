module WorkflowFork
  class EventCollection < Hash
    # 将所有hash key转为symbol
    def [](name)
      super name.to_sym
    end

    def push(name, event)
      key = name.to_sym
      self[key] ||= []
      self[key] << event
    end
  end
end
