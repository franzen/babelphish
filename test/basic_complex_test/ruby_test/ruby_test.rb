require_relative 'test_babel.rb'
require 'minitest/autorun'

class TestBabelTestBasic < MiniTest::Unit::TestCase

  def setup
    
  end

  def test_basic
    puts "Basic Test"
    testbasic_ser = BabelTest::TestBasic.new
    testbasic_ser.i8 = 0x0F
    testbasic_ser.i16 = 0X1234
    testbasic_ser.i32 = 0x567890AB
    testbasic_ser.str = "abc\n123\t\""
    testbasic_ser.ip = "192.168.0.1"
    testbasic_ser.guid = (300..302).to_s
    
    res = serialize_deserialize(testbasic_ser)
    testbasic_deser = BabelTest::TestBasic.new
    testbasic_deser.deserialize res

    assert testbasic_ser.i8 == testbasic_deser.i8
    assert testbasic_ser.i16 == testbasic_deser.i16
    assert testbasic_ser.i32 == testbasic_deser.i32
    assert testbasic_ser.str == testbasic_deser.str
    assert testbasic_ser.ip == testbasic_deser.ip
    assert testbasic_ser.guid == testbasic_deser.guid
  end

  def test_complex
    testcomplex_ser = BabelTest::TestComplex.new
    testcomplex_ser.list1 = [0, 1, 255, 0x7FFFFFFF, 0x7FFFFFFF+1, 0xFFFFFFFE, 0xFFFFFFFF]
    testcomplex_ser.list2 = [0,1, 15,16, 127,128, 254,255]
    testcomplex_ser.map1[0] = 10
    testcomplex_ser.map1[10] = 100
    testcomplex_ser.map2["Hello_1"] = [BabelTest::Entry.new, BabelTest::Entry.new, BabelTest::Entry.new]
    testcomplex_ser.map2["Hello_2"] = [BabelTest::Entry.new, BabelTest::Entry.new]
    
    res = serialize_deserialize(testcomplex_ser)
    testcomplex_deser = BabelTest::TestComplex.new
    testcomplex_deser.deserialize res

    assert testcomplex_ser.list1.sort == testcomplex_deser.list1.sort
    assert testcomplex_ser.list2.sort == testcomplex_deser.list2.sort
    assert testcomplex_ser.map1 == testcomplex_deser.map1
    testcomplex_ser.map2.keys.each do |k|
      assert testcomplex_ser.map2[k].length == testcomplex_deser.map2[k].length
    end
  end

  def serialize_deserialize(obj)
    data = obj.serialize
    File.open("bin.babel.rb", "w+b") do |f|
      f.write(data)
    end

    mem_buf = File.new('bin.babel.rb').binmode
  end

end
