require_relative 'test_helper'
require 'active_record'
require 'sqlite3'
require 'workflow_fork'
require 'pry'

# 关闭migrate 输出
ActiveRecord::Migration.verbose = false

class Order < ActiveRecord::Base
  include WorkflowFork
end

class TestOrder < ActiveRecord::Base
  include WorkflowFork
  workflow_column :state
end

class TestWorkflow < Minitest::Test

  def setup
    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database  => ":memory:" #"tmp/test"
    )

    # eliminate ActiveRecord warning. TODO: delete as soon as ActiveRecord is fixed
    ActiveRecord::Base.connection.reconnect!
    ActiveRecord::Schema.define do
      create_table :orders do |t|
        t.string :workflow_state
      end
      create_table :test_orders do |t|
        t.string :state
      end
    end
  end

  def test_defalut_workflow_column
    order = Order.new
    order.save
    assert_equal 'init', order.workflow_state
  end

  def test_custome_workflow_column
    order = TestOrder.new
    order.save
    assert_equal 'init', order.state
    assert_equal :state, TestOrder.workflow_column
  end
end
