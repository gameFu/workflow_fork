require_relative 'test_helper'

class StiOrder
  include WorkflowFork
  workflow do
    state :new do
      event :next, transitions_to: :next_state
    end
    state :next_state
  end
end

class StiEntityOrder < StiOrder
end

class TestSti < Minitest::Test
  test '测试单表继承不重新定义状态机则将继承父类状态机方法' do
    order = StiOrder.new
    assert order.respond_to? :next!
    entity_order = StiEntityOrder.new
    assert entity_order.respond_to? :next!
  end

  test '单表继承subclass重新定义了状态机，则子类使用重新定义的状态' do
    order = StiOrder.new
    assert order.respond_to? :next!
    StiEntityOrder.class_eval do
      workflow do
        state :first do
          event :to_two, transitions_to: :two
        end
        state :two
      end
    end
    entity_order = StiEntityOrder.new
    assert entity_order.respond_to? :first?
    assert entity_order.respond_to? :to_two!
  end
end
