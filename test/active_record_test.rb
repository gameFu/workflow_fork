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

class TestActiveRecordTest < ActiveRecordTestCase

  def setup
    super
    ActiveRecord::Schema.define do
      create_table :orders do |t|
        t.string :workflow_state
      end
    end
  end

  test 'with_(:state)_state' do
    pending_order = Order.create
    pre_generated_order = pre_generated_order_create
    wait_payment_order = wait_payment_order_create
    assert_equal pending_order.id, Order.with_pending_state.first.id
    assert_equal pre_generated_order.id, Order.with_pre_generated_state.first.id
    assert_equal wait_payment_order.id, Order.with_wait_payment_state.first.id
  end

  test 'without_(:state)_state' do
    pending_order = Order.create
    pre_generated_order = pre_generated_order_create
    assert_equal pending_order.id, Order.without_pre_generated_state.first.id
    assert_equal pre_generated_order.id, Order.without_pending_state.first.id
  end

  def pre_generated_order_create
    o = Order.create
    o.place_order_by_user!
    o
  end

  def wait_payment_order_create
    o = pre_generated_order_create
    o.confirmed_by_user!
    o
  end
end
