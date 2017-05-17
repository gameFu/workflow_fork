require_relative 'test_helper'

class TestHalt< Minitest::Test
  test '调用halt方法后会返回false' do
    c = Class.new
    c.class_eval do
      include WorkflowFork
      workflow do
        state :new do
          event :next, transitions_to: :next_state
        end
        state :next_state
      end

      def next
        halt '该返回错误了'
        return 1
      end
    end
    o = c.new
    assert !o.next!
  end

  test '调用halt!方法将会返回workflow异常' do
    c = Class.new
    c.class_eval do
      include WorkflowFork
      workflow do
        state :new do
          event :next, transitions_to: :next_state
        end
        state :next_state
      end

      def next
        halt! '该返回错误了'
        return 1
      end
    end
    o = c.new
    assert_raises 'WorkflowFork::TransitionHalted' do
      o.next!
    end
  end
end
