module WorkflowFork
  # 状态
  class State
    attr_accessor :name, :events, :meta, :on_exit, :on_entry
    attr_reader :spec

    # 初始化
    def initialize(name, spec, meta = {})
      @name, @spec, @events, @meta = name, spec, EventCollection.new, meta
    end

    # to_s返回状态名
    def to_s
      "#{name}"
    end
  end
end
