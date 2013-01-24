require_relative 'test_dynamic_int.rb'
require 'minitest/autorun'

#
# Responsible for testing dynamic integer data types
#
class TestDynamicInteger < MiniTest::Unit::TestCase

  #
  # Compare objects after serialize and deserialize operations
  #
  def test_signedInt
    puts "Test Dynamic Int"
    obj_ser = BabelTest::DynamicInt.new
    obj_ser.list1  = [127, 16383, 2097151, 268435455, 34359738367, 4398046511103, 562949953421311]#, 72057594037927935, 9223372036854775807]
    
    ser = obj_ser.serialize
    serialize(ser)
    res = deserialize()

    obj_deser = BabelTest::DynamicInt.new
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
    #puts "Ser = #{obj_ser.list1}, Deser = #{obj_deser.list1}"
    assert_equal obj_ser.list1, obj_deser.list1
  end

  #
  # Write binary data to file
  # * *Args* :
  #  -data-   --> bytes to be written
  #
  def serialize(data)
    File.open("test/dynamic_int_test/ruby_test/bin.babel.rb", "w+b") do |f|
      f.write(data)
    end
  end
  
  #
  # Read file in binary mode and return its bytes content
  #
  def deserialize()
    mem_buf = File.new('test/dynamic_int_test/ruby_test/bin.babel.rb').binmode
  end

end
