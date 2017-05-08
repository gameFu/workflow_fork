require 'workflow_fork/version'
require 'workflow_fork/adapters/active_record'

module WorkflowFork
  module ClassMethods
    # 定义状态机存储的字段，默认为workflow_state
    def workflow_column(column_name = nil)
      if column_name
        @workflow_state_column_name = column_name.to_sym
      end
      @workflow_state_column_name ||= :workflow_state
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
