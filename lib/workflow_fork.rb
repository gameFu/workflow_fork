require "workflow_fork/version"

module WorkflowFork
  # 钩子方法
  def included(klass)
    klass.extend ClassMethods

    # 配置适配器
    
  end
end
