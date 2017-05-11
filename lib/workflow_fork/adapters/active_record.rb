module WorkflowFork
  module Adapter
    module ActiveRecord
      def self.included(klass)
        klass.send :include, Adapter::ActiveRecord::InstanceMethods
        klass.before_validation :write_initial_state
      end

      module InstanceMethods
        # 读状态机状态
        def load_workflow_state
          read_attribute self.class.workflow_column
        end

        # 更新状态机状态
        def persist_workflow_state(new_value)
          update_column self.class.workflow_column, new_value
        end

        private

        # 初始化状态机状态，默认初始化为定义的第一个状态
        def write_initial_state
          write_attribute self.class.workflow_column, current_state.to_s
        end
      end
    end
  end
end
