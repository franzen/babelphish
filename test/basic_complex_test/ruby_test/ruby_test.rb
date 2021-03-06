require_relative 'test_babel.rb'
require 'minitest/autorun'

#
# Responsible for testing basic and complex structure
#
class TestBabelTestBasic < MiniTest::Unit::TestCase

  #
  # Compare objects after serialize and deserialize operations "simple structure"
  #
  def test_basic
    puts "Basic Test"
    testbasic_ser = BabelTest::TestBasic.new
    testbasic_ser.i8 = 0x0F
    testbasic_ser.i16 = 0X1234
    testbasic_ser.i32 = 0x567890AB
    testbasic_ser.str = "abc\n123\t\""
    testbasic_ser.ip = "192.168.0.1"
    testbasic_ser.guid = (300..302).to_s
    
    ser = testbasic_ser.serialize
    serialize(ser)
    res = deserialize()

    testbasic_deser = BabelTest::TestBasic.new
    testbasic_deser.deserialize res

    assert_equal testbasic_ser.i8 , testbasic_deser.i8
    assert_equal testbasic_ser.i16 , testbasic_deser.i16
    assert_equal testbasic_ser.i32 , testbasic_deser.i32
    assert_equal testbasic_ser.str , testbasic_deser.str
    assert_equal testbasic_ser.ip , testbasic_deser.ip
    assert_equal testbasic_ser.guid , testbasic_deser.guid
  end

  #
  # Compare objects after serialize and deserialize operations "complex structure"
  #
  def test_complex
    testcomplex_ser = BabelTest::TestComplex.new
    testcomplex_ser.list1 = [0, 1, 255, 0x7FFFFFFF, 0x7FFFFFFF+1, 0xFFFFFFFE, 0xFFFFFFFF]
    testcomplex_ser.list2 = [0,1, 15,16, 127,128, 254,255]
    testcomplex_ser.map1[0] = 10
    testcomplex_ser.map1[10] = 100
    testcomplex_ser.map2["Hello_1"] = [BabelTest::Entry.new, BabelTest::Entry.new, BabelTest::Entry.new]
    testcomplex_ser.map2["Hello_2"] = [BabelTest::Entry.new, BabelTest::Entry.new]
    
    ser = testcomplex_ser.serialize
    serialize(ser)
    res = deserialize()

    testcomplex_deser = BabelTest::TestComplex.new
    testcomplex_deser.deserialize res

    assert_equal testcomplex_ser.list1, testcomplex_deser.list1
    assert_equal testcomplex_ser.list2, testcomplex_deser.list2
    assert_equal testcomplex_ser.map1, testcomplex_deser.map1
    testcomplex_ser.map2.keys.each do |k|
      assert_equal testcomplex_ser.map2[k].length, testcomplex_deser.map2[k].length
    end
  end

  #
  # Write binary data to file
  # * *Args* :
  #  -data-   --> bytes to be written
  #
  def serialize(data)
    File.open("test/basic_complex_test/ruby_test/bin.babel.rb", "w+b") do |f|
      f.write(data)
    end
  end

  #
  # Read file in binary mode and return its bytes content
  #
  def deserialize()
    mem_buf = File.new('test/basic_complex_test/ruby_test/bin.babel.rb').binmode
  end
end
