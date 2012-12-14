require_relative 'test_unify.rb'
require 'minitest/autorun'

class TestBabelTestBasic < MiniTest::Unit::TestCase

  def test_unify
    obj_ser = BabelTest::UnifySer.new
    obj_ser.map1 = {2 => 15, 3 => 16}
    obj_ser.str  = "What is This?"
    #ser = obj.serialize
    #serialize(ser)
    res = deserialize()

    obj_deser = BabelTest::UnifySer.new
    obj_deser.deserialize res
    compare(obj_ser, obj_deser)
    
  end

  def compare(obj_ser, obj_deser)
    puts obj_deser.str
    assert obj_ser.map1 == obj_deser.map1
  end

  def serialize(data)
    File.open("bin.babel.rb", "w+b") do |f|
      f.write(data)
    end
  end

  def deserialize()
    mem_buf = File.new('bin.babel.js').binmode
  end

end
