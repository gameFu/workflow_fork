require 'workflow_fork/version'
require 'workflow_fork/specification'
require 'workflow_fork/adapters/active_record'

module WorkflowFork
  module ClassMethods
    attr_reader :workflow_spec
    # 定义状态机存储的字段，默认为workflow_state
    def workflow_column(column_name = nil)
      if column_name
        @workflow_state_column_name = column_name.to_sym
      end
      @workflow_state_column_name ||= :workflow_state
    end

    # 定义状态机
    def workflow(&specification)
      assign_workflow Specification.new(Hash.new, &specification)
    end

    private

    # 声明状态机 创建类似my_transition!这样的方法
    def assign_workflow(specification_object)
      @workflow_spec = specification_object
      @workflow_spec.states.values.each do |state|
        state_name = state.name
        # module_eval do
        #   # 防止重名状态方法
        #   undef_method "#{state_name}"
        # end

        state.events.flat.each do |event|
          event_name = event.name
          module_eval do
            # 定义my_transition!方法
            define_method "#{event_name}!".to_sym do |*args|
              process_event!(event_name, *args)
            end

            # 定义can_my_transition?方法
            define_method "can_#{event_name}?".to_sym do
              # 确保不会返回nil
              return !!current_state.events.first_applicable(event_name, self)
            end
          end
        end
      end
    end
  end

  module InstanceMethods

    def process_event!(name, *args)
      event = current_state.events.first_applicable(name, self)
      # 没有匹配的事件抛出异常
      raise NoTransitionAllowed.new(
        "There is no event #{name.to_sym} defined for the #{current_state} state") \
        if event.nil?

      # 检查是否存在可迁移的状态
      check_transition(event)

      # 迁移前状态
      from = current_state
      # 目标迁移状态
      to = spec.states[event.transitions_to]

      # 状态迁移时间执行时执行的callback
      run_before_transition(from, to, name, *args)
      # 如果存在复写的方法，则执行复写的方法
      return_value = run_action_callback(event.name, *args)
      #  状态迁移时执行的callback
      run_on_transition(from, to, name, *args)
      # 特定状态写入数据库前执行的callback
      run_on_exit(from, to, name, *args)

      # 状态更改为迁移的状态
      transitions_value = persist_workflow_state to.to_s

      # 特定状态写入数据库后执行的callback
      run_on_entry(from, to, name, *args)

      # 状态迁移后执行的callback
      run_after_transition(from, to, name, *args)
      return_value.nil? ? transitions_value : return_value
    end

    # 当前的state class
    def current_state
      # 持久化的当前状态
      loaded_state = load_workflow_state
      # 获取状态机
      res = spec.states[loaded_state.to_sym] if loaded_state
      res || spec.initial_state
    end

    # 当前的状态机class
    def spec
      c = self.class
      # 找到引入了workflow并且workflow_spec不为空的类
      until c.workflow_spec || !(c.include? WorkflowFork)
        c = c.superclass
      end
      c.workflow_spec
    end

    # 继承activerecoder等adapter会被重写
    def load_workflow_state
      @workflow_state if instance_variable_defined? :@workflow_state
    end

    def persist_workflow_state(new_value)
      @workflow_state = new_value
    end

    private

    def check_transition(event)
      raise WorkflowError.new("Event[#{event.name}]'s " +
          "transitions_to[#{event.transitions_to}] is not a declared state.") if !spec.states[event.transitions_to]
    end

    # before_transition
    def run_before_transition(from, to, event, *args)
      instance_exec(from.name, to.name, event, *args, &spec.before_transition_proc) if spec.before_transition_proc
    end

    def run_after_transition(from, to, event, *args)
      instance_exec(from.name, to.name, event, *args, &spec.after_transition_proc) if spec.after_transition_proc
    end

    # on_transition
    def run_on_transition(from, to, event, *args)
      instance_exec(from.name, to.name, event, *args, &spec.on_transition_proc) if spec.on_transition_proc
    end

    # on_exit
    def run_on_exit(state, new_state, triggering_event, *args)
      # 两种使用方式
      if state
        # 直接在state block 里定义on_exist block
        if state.on_exit
          instance_exec(state, new_state, triggering_event, *args, &state.on_exit)
          # 在workflow block外定义on_(state_name)_exit method
        else
          hook_name = "on_#{state}_exit"
          self.send hook_name, new_state, triggering_event, *args if has_callback?(hook_name)
        end
      end
    end

    def run_on_entry(state, new_state, triggering_event, *args)
      if state.on_entry
        instance_exec(state, new_state, triggering_event, *args, &state.on_entry)
      else
        hook_name = "on_#{state}_entry"
        self.send hook_name, new_state, triggering_event, *args if has_callback?(hook_name)
      end
    end

    # 是否存在复写的方法
    def has_callback?(action)
      action = action.to_sym
      # 1. public方法
      # 2. protect方法
      # 3. 仅存在当前接收类中的私有方法
      self.respond_to?(action) || self.class.protected_method_defined?(action)  || self.private_methods(false).map(&:to_sym).include?(action)
    end

    def run_action_callback(action_name, *args)
      action = action_name.to_sym
      self.send(action, *args) if has_callback?(action)
    end
  end

  def self.included(klass)
    klass.send :include, InstanceMethods
    klass.extend ClassMethods

    # 配置适配器
    if klass.respond_to?(:workflow_adapter)
      klass.send :include, klass.workflow_adapter
    else
      # 是否使用ActiveRecord并且继承ActiveRecord::Base
      if Object.const_defined?(:ActiveRecord) && klass < ActiveRecord::Base
        # 使用ActiveRecord适配器
        klass.send :include, Adapter::ActiveRecord
      end
    end
  end
end
