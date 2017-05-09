$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'workflow_fork'
require 'active_record'
require 'sqlite3'
require 'pry'

require 'minitest/autorun'

# 关闭migrate 输出
ActiveRecord::Migration.verbose = false

class << Minitest::Test
  def test(name, &block)
    test_name = :"test_#{name.gsub(' ','_')}"
    raise ArgumentError, "#{test_name} is already defined" if self.instance_methods.include? test_name.to_s
    if block
      define_method test_name, &block
    else
      puts "PENDING: #{name}"
    end
  end
end


class ActiveRecordTestCase < Minitest::Test
  def setup
    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database  => ":memory:" #"tmp/test"
    )
    # eliminate ActiveRecord warning. TODO: delete as soon as ActiveRecord is fixed
    ActiveRecord::Base.connection.reconnect!
  end
end
