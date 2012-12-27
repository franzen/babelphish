require_relative 'test_signed_float.rb'
require 'minitest/autorun'

class TestBabelTestBasic < MiniTest::Unit::TestCase

  def test_signedFloat
    puts "Test Signed Int"
    obj_ser = BabelTest::SignedFloat.new
    obj_ser.list1  = [-1093.0802e+4]
    
    ser = obj_ser.serialize
    serialize(ser)
    res = deserialize()

    obj_deser = BabelTest::SignedFloat.new
    obj_deser.deserialize res
    compare(obj_ser, obj_deser)
    
  end

  def compare(obj_ser, obj_deser)
    puts "Ser = #{obj_ser.list1}, Deser = #{obj_deser.list1}"
    assert_equal obj_ser.list1, obj_deser.list1
  end

  def serialize(data)
    File.open("test/signed_float_test/ruby_test/bin.babel.rb", "w+b") do |f|
      f.write(data)
    end
  end

  def deserialize()
    mem_buf = File.new('test/signed_float_test/ruby_test/bin.babel.rb').binmode
  end

end
