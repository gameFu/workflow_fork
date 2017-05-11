require_relative 'test_helper'

class TOrder < ActiveRecord::Base
  include WorkflowFork
  workflow do
    state :pending
  end
end

class TestOrder < ActiveRecord::Base
  include WorkflowFork
  workflow_column :state
  workflow do
    state :pending
  end
end

class TestWorkflowCloumn < ActiveRecordTestCase

  def setup
    super
    ActiveRecord::Schema.define do
      create_table :t_orders do |t|
        t.string :workflow_state
      end
      create_table :test_orders do |t|
        t.string :state
      end
    end
  end

  test 'defalut workflow column' do
    order = TOrder.new
    order.save
    assert_equal 'pending', order.workflow_state
  end

  test 'custome workflow column' do
    order = TestOrder.new
    order.save
    assert_equal 'pending', order.state
    assert_equal :state, TestOrder.workflow_column
  end
end
