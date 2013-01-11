require_relative 'test_ipv6.rb'
require 'minitest/autorun'

#
# Responsible for testing IP data types
#
class TestIP < MiniTest::Unit::TestCase

  #
  # Compare objects after serialize and deserialize operations
  #
  def test_ip
    puts "Test IP"
    obj_ser = BabelTest::IPV6.new
    obj_ser.list1  = ["255.102.0.25","ff:fabf:faf:f15f:f1ff:f2f:1f:f2","2001:db8::ff00:1:8329","f::","::1",""]
    
    # Should Fail or raise error
    #obj_ser.ip = "2001:0db8:0000:0000:0000:ff00:0042:8329";
    #obj_ser.ip = "2001:db8::fff00:42:8329";
    #obj_ser.ip = "2001:db8:::ff00:42:8329";
    #obj_ser.ip = "2001:db8:ff00:42:8329";
    #obj_ser.ip = "::";

    ser = obj_ser.serialize
    serialize(ser)
    res = deserialize()

    obj_deser = BabelTest::IPV6.new
    obj_deser.deserialize res
    compare(obj_ser, obj_deser)
    
  end

  #
  # Make sure that the comming two objects are the same
  # * *Args* :
  #  -obj_ser-   --> original object
  #  -obj_deser- --> obtained object after serialize and deserialize operations
  #
  def compare(obj_ser, obj_deser)
    assert_equal obj_ser.list1, obj_deser.list1
  end

  #
  # Write binary data to file
  # * *Args* :
  #  -data-   --> bytes to be written
  #
  def serialize(data)
    File.open("test/ipv6_test/ruby_test/bin.babel.rb", "w+b") do |f|
      f.write(data)
    end
  end

  #
  # Read file in binary mode and return its bytes content
  #
  def deserialize()
    mem_buf = File.new('test/ipv6_test/ruby_test/bin.babel.rb').binmode
  end

end
