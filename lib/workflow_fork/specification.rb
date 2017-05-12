require 'workflow_fork/state'
require 'workflow_fork/event_collection'
require 'workflow_fork/errors'
require 'workflow_fork/event'

module WorkflowFork
  # 状态机总规则
  class Specification
    attr_accessor :states, :initial_state, :meta, :before_transition_proc, :on_transition_proc, :on_transition

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
      # 当前声明的状态
      @scoped_state = new_state
      # 递归声明事件
      instance_eval(&events_and_etc) if events_and_etc
    end

    # 声明事件
    def event(name, args = {}, &action)
      # 事件指向的状态
      target = args[:transitions_to]
      condition = args[:if]
      raise WorkflowDefinitionError.new(
        "missing ':transitions_to' in workflow event definition for '#{name}'") \
        if target.nil?
      # 事件加入状态事件集中
      @scoped_state.events.push(name, WorkflowFork::Event.new(name, target, condition, (args[:meta] or {}), &action))
    end

    def before_transition(&proc)
      @before_transition_proc = proc
    end

    def on_transition(&proc)
      @on_transition_proc = proc
    end

    def on_exit(&proc)
      @scoped_state.on_exit = proc
    end

    def on_entry(&proc)
      @scoped_state.on_entry = proc
    end
  end
end
