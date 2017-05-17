module WorkflowFork
  module Adapter
    module ActiveRecord
      def self.included(klass)
        klass.send :include, Adapter::ActiveRecord::InstanceMethods
        klass.send :extend, Adapter::ActiveRecord::Scopes
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
      #
      module Scopes
        # 类引入时触发 object是引入的那个类
        def self.extended(object)
          class << object
            # 相当于在module中实现类继承的重写
            # 首先先将在直接定义状态机的workflow方法起一个别名
            alias_method :workflow_without_scopes, :workflow unless method_defined?(:workflow_without_scopes)
            # 然后将重写过的workflow方法名字定义为workflow_with_scopes，并且将该方法起一个别名为workflow，这样就在module通过起别名将其他module的方法名进行重写
            alias_method :workflow, :workflow_with_scopes
          end
        end

        def workflow_with_scopes(&specification)
          # 先执行workflow中的workflow（现在已经是别名）方法来定义状态机
          workflow_without_scopes(&specification)
          # 取出所有状态
          states = workflow_spec.states.values
          states.each do |state|
            # 定义类方法 由于已经定义了to_s这里将会直接转为state的name
            define_singleton_method "with_#{state}_state" do
              # table_name为ar自带method，返回当前模型表名 with_(:state)_state方法，返回所有state为（:state）的记录
              where("#{table_name}.#{self.workflow_column.to_sym} = ?", state.to_s)
            end

            # 定义without_(:state)_state方法，返回所有state不为(:state)的方法
            define_singleton_method "without_#{state}_state" do
              where.not("#{table_name}.#{self.workflow_column.to_sym} = ?", state.to_s)
            end
          end
        end
      end
    end
  end
end
