require_relative 'test_helper'

class Order < ActiveRecord::Base
  include WorkflowFork
  workflow do
    state :pending do
      # 用户下单
      event :place_order_by_user, transitions_to: :pre_generated
    end
    # 预生成订单
    state :pre_generated do
      # 用户确认下单
      event :confirmed_by_user, transitions_to: :wait_payment
    end
    # 待支付订单
    state :wait_payment do
      # 用户支付
      event :pay, transitions_to: :making
      # 用户关闭订单
      event :close, transitions_to: :closed
    end
  end
end

class TestErrorStateOrder < ActiveRecord::Base
  include WorkflowFork
  workflow do
    state :pending do
      event :place_order_by_user, transitions_to: :pre_generated
    end
    state :done
  end
end

class OverwriteOrder < Order
  def place_order_by_user
    self.paid = true
    save!
  end
end

class TestDeclaerStateAndEventTest < ActiveRecordTestCase

  def setup
    super
    ActiveRecord::Schema.define do
      create_table :orders do |t|
        t.string :workflow_state
        t.boolean :paid
      end
      create_table :test_error_state_orders do |t|
        t.string :workflow_state
      end
    end
  end
  #
  test 'current state is initial_state when not assign state' do
    order = Order.new
    order.save
    assert_equal 'pending', order.workflow_state
    assert_equal 'pending', order.current_state.name.to_s
  end

  test 'can_transition?' do
    order = Order.new
    order.save
    assert order.can_place_order_by_user?
    assert !order.can_confirmed_by_user?
  end

  test 'transitions! success when transition valid' do
    order = Order.new
    order.save
    order.place_order_by_user!
    assert_equal 'pre_generated', order.workflow_state
    order.reload.confirmed_by_user!
    assert_equal 'wait_payment', order.workflow_state
  end

  test 'transition！fails with transition event not exist' do
    order = Order.new
    order.save
    assert_raises 'NoTransitionAllowed' do
      order.confirmed_by_user!
    end
  end

  test 'transition! fails with transition state not exist' do
    order = TestErrorStateOrder.new
    order.save
    assert_raises 'WorkflowError' do
      order.place_order_by_user!
    end
  end

  test 'overwrite transition' do
    order = OverwriteOrder.new
    order.paid = false
    order.save
    assert !order.paid
    order.place_order_by_user!
    assert order.reload.paid
    assert_equal 'pre_generated', order.workflow_state
  end
end
