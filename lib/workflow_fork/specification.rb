require 'workflow/state'
require 'workflow/event_collection'

module Workflow
  # 状态机总规则
  class Specification
    attr_accessor :states, :initial_state, :meta

    def initialize(meta = {}, &specification)
      @meta = meta
      @states = Hash.new
      # 递归声明所有状态和事件
      instance_eval(&specification)
    end

    def state_names
      @state.keys
    end

    private

    # 声明状态
    def state(name, meta={ meta: {} }, &events_and_etc)
      new_state = WorkflowFork::State.new(name, self, meta[:meta])
      # 初始化状态
      @initial_state = new_state if @states.empty?
      @states[name.to_sym] = new_state

    end
  end
end
