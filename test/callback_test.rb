require_relative 'test_helper'

class CallbackOrder < ActiveRecord::Base
  include WorkflowFork
end

class BeforeTransitionOrder < CallbackOrder
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
    before_transition do
      self.callback_name = 'before_transition'
      save!
    end
  end
end

class OnTransitionOrder < CallbackOrder
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
    before_transition do
      self.callback_name = 'before_transition'
      save!
    end
    on_transition do
      self.callback_name = 'on_transition'
      save!
    end
  end
end

class TestCallback < ActiveRecordTestCase
  def setup
    super
    ActiveRecord::Schema.define do
      create_table :callback_orders do |t|
        t.string :workflow_state
        t.boolean :before_flag, defalut: false
        t.string :callback_name
      end
    end
  end

  test 'before_transition' do
    order = BeforeTransitionOrder.new
    order.save
    assert !order.before_flag
    order.place_order_by_user!
    assert_equal 'before_transition', order.callback_name
  end

  test 'on_transition' do
    order = OnTransitionOrder.new
    order.save
    order.place_order_by_user!
    assert_equal 'on_transition', order.callback_name
  end
end
