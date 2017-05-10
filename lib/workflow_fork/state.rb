module WorkflowFork
  # 状态
  class State
    attr_accessor :name, :events, :meta
    attr_reader :spec

    # 初始化
    def initialize(name, spec, meta = {})
      @name, @spec, @events, @meta = name, spec, EventCollection.new, meta
    end
  end
end
