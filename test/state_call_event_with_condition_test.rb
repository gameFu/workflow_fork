require_relative 'test_helper'

class EntityOrder < ActiveRecord::Base
  include WorkflowFork
  workflow do
    state :pending do
      # 用户下单
      event :place_order_by_user, transitions_to: :pre_generated, if: :not_paid?
    end
    # 预生成订单
    state :pre_generated do
      # 用户确认下单
      event :confirmed_by_user, transitions_to: :wait_payment
    end
  end

  def not_paid?
    !paid
  end
end

class TestStateCallEventWithConditionTest < ActiveRecordTestCase

  def setup
    super
    ActiveRecord::Schema.define do
      create_table :entity_orders do |t|
        t.string :workflow_state
        t.boolean :paid
      end
    end
  end

  test 'transitions to state false with symbol condition false' do
    order = EntityOrder.new
    order.paid = false
    order.save
    assert order.can_place_order_by_user?
    order.paid = true
    order.save
    assert !order.can_place_order_by_user?
  end
end
