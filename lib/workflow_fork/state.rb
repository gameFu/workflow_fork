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

    # 重写比较方法实现类似 article.current_state < :accepted 返回true或false这种方法
    if RUBY_VERSION >= '1.9'
      include Comparable
      def <=>(other_state)
        # 返回所有states名字数组，顺序是这个hash定义key时的顺序
        states = spec.states.keys
        raise ArgumentError, "state `#{other_state}' does not exist" unless states.include?(other_state.to_sym)
        states.index(self.to_sym) <=> states.index(other_state.to_sym)
      end
    end

    def to_sym
      name.to_sym
    end
  end
end
