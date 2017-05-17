require_relative 'test_helper'

class TestComparable< Minitest::Test

  test 'comparable' do
    c = Class.new
    c.class_eval do
      include WorkflowFork
      workflow do
        state :new do
          event :next, transitions_to: :next_state
        end
        state :next_state
      end
    end
    o = c.new
    assert o.current_state < :next_state
    assert !(o.current_state >= :next_state)
    assert o.current_state >= :new
    assert o.current_state == :new
  end

end
