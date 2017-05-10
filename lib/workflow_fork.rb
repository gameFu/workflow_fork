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
      binding.pry
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
            # define_method "#{event_name}!".to_sym do |*arg|
            #   process_event!(event_name, *args)
            # end

            # 定义can_my_transition?方法
            define_method "can_#{event_name}?".to_sym do |*arg|
              
            end
          end
        end
      end
    end
  end

  def self.included(klass)
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
