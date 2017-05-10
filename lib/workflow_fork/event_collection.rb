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

    # 返回所有不重复eventclass 数组
    # [eventclass1,eventclass2]
    def flat
      # 铺平hash
      # [pay: [eventclass1], close: [eventclass2]] to [eventclass1,eventclass2]
      self.values.flatten.uniq do |event|
        # 比较所有event 确保没有完全一致属性的event
        # [[event1.name, event1.transitions_to, event1.meta, event1.action], [event2.name, event2.transitions_to, event2.meta, event2.action]]
        [:name, :transitions_to, :meta, :action].map { |method|  event.send method }
      end
    end
  end
end
