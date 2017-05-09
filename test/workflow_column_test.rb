require_relative 'test_helper'

class Order < ActiveRecord::Base
  include WorkflowFork
end

class TestOrder < ActiveRecord::Base
  include WorkflowFork
  workflow_column :state
end

class TestWorkflowCloumn < ActiveRecordTestCase

  def setup
    super
    ActiveRecord::Schema.define do
      create_table :orders do |t|
        t.string :workflow_state
      end
      create_table :test_orders do |t|
        t.string :state
      end
    end
  end

  test 'defalut workflow column' do
    order = Order.new
    order.save
    assert_equal 'init', order.workflow_state
  end

  test 'custome workflow column' do
    order = TestOrder.new
    order.save
    assert_equal 'init', order.state
    assert_equal :state, TestOrder.workflow_column
  end
end