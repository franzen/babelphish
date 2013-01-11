require_relative 'test_complex.rb'
require 'minitest/autorun'

#
# Responsible for testing complex structure
#
class TestComplexStructure < MiniTest::Unit::TestCase

  #
  # Compare objects after serialize and deserialize operations
  #
  def test_complex
    puts "Test Complex Data Structure"
    com_ser = buildObject

    ser = com_ser.serialize
    serialize(ser)
    res = deserialize()

    com_deser = BabelTest::Complex.new
    com_deser.deserialize res
    compare(com_ser, com_deser)
    
  end

  #
  # Initialize the original object
  #
  def buildObject()
    ipList_1 = BabelTest::IPList.new
    ipList_1.list1 = ["10.2.2.1","127.0.0.1","129.36.58.15"]
    ipList_1.list2 = ["2001:db8::ff00:1:8329","ff:ac:12::5f","1::"]

    ipList_2 = BabelTest::IPList.new
    ipList_2.list1 = ["100.20.20.10","17.10.10.1","12.36.68.105"]
    ipList_2.list2 = ["ff:fabf:faf:f15f:f1ff:f2f:1f:f2", "2001:db8::ff00:1:8329","::1"]

    com = BabelTest::Complex.new
    com.list1 = [{}]
    com.list1[0] = {"AA" => [ipList_1, ipList_2]}
    com.list1[1] = {"BB" => [ipList_2, ipList_1]}
    com
  end

  #
  # Make sure that the comming two objects are the same
  # * *Args* :
  #  -obj_ser-   --> original object
  #  -obj_deser- --> obtained object after serialize and deserialize operations
  #
  def compare(obj1, obj2)
    assert obj1.list1.length == obj2.list1.length
    assert obj1.list1[0]["AA"].length == obj2.list1[0]["AA"].length
    assert obj1.list1[0]["AA"][0].list1.length == obj2.list1[0]["AA"][0].list1.length
    assert obj1.list1[0]["AA"][0].list1[2] == obj2.list1[0]["AA"][0].list1[2]
    assert obj1.list1[0]["AA"][0].list2[0] == obj2.list1[0]["AA"][0].list2[0]
    assert obj1.list1[1]["BB"][0].list2[2] == obj2.list1[1]["BB"][0].list2[2]
  end

  #
  # Write binary data to file
  # * *Args* :
  #  -data-   --> bytes to be written
  #
  def serialize(data)
    File.open("test/complex_test/ruby_test/bin.babel.rb", "w+b") do |f|
      f.write(data)
    end
  end

  #
  # Read file in binary mode and return its bytes content
  #
  def deserialize()
    mem_buf = File.new('test/complex_test/ruby_test/bin.babel.rb').binmode
  end

end
