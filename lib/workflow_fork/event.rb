module WorkflowFork
  class Event
    attr_accessor :name, :transitions_to, :meta, :action, :condition

    def initialize(name, transitions_to, condition = nil, meta = {}, &action)
      @name = name
      @transitions_to = transitions_to
      @meta = meta
      @action = action
      # condition必须为symbol或者为lambda或者为proc或者为nil
      @condition = if condition.nil? || condition.is_a?(Symbol) || condition.respond_to?(:call)
                      condition
                   else
                     raise TypeError, 'condition must be nil, an instance method name symbol or a callable (eg. a proc or lambda)'
                   end
    end

    # 条件判断
    def condition_applicatble?(object)
      if condition
        if condition.is_a?(Symbol)
          object.send condition
        else
          object.call condition
        end
      else
        true
      end
    end
  end
end
