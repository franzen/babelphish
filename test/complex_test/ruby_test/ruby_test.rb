require_relative 'test_complex.rb'
require 'minitest/autorun'

class TestBabelTestBasic < MiniTest::Unit::TestCase

  def test_complex
    com_ser = buildObject
    res = serialize_deserialize(com_ser)
    com_deser = BabelTest::Complex.new
    com_deser.deserialize res
    compare(com_ser, com_deser)
    
  end

  def buildObject()
    ipList_1 = BabelTest::IPList.new
    ipList_1.list1 = ["10.2.2.1","127.0.0.1","129.36.58.15"]

    ipList_2 = BabelTest::IPList.new
    ipList_2.list1 = ["100.20.20.10","17.10.10.1","12.36.68.105"]

    com = BabelTest::Complex.new
    com.list1 = [{}]
    com.list1[0] = {"AA" => [ipList_1, ipList_2]}
    com.list1[1] = {"BB" => [ipList_2, ipList_1]}
    com
  end

  def compare(obj1, obj2)
    assert obj1.list1.length == obj2.list1.length
    assert obj1.list1[0]["AA"].length == obj2.list1[0]["AA"].length
    assert obj1.list1[0]["AA"][0].list1.length == obj2.list1[0]["AA"][0].list1.length
    assert obj1.list1[0]["AA"][0].list1[2] == obj2.list1[0]["AA"][0].list1[2]
  end

  def serialize_deserialize(obj)
    data = obj.serialize
    File.open("bin.babel", "w+b") do |f|
      f.write(data)
    end

    mem_buf = File.new('bin.babel').binmode
  end

end
