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

class TestDeclaerStateAndEventTest < ActiveRecordTestCase

  def setup
    super
    ActiveRecord::Schema.define do
      create_table :orders do |t|
        t.string :workflow_state
      end
    end
  end

  test 'declaer state' do
    order = Order.new
  end

end
