require_relative 'test_ipv6.rb'
require 'minitest/autorun'

class TestBabelTestBasic < MiniTest::Unit::TestCase

  def test_ipv6
    obj_ser = BabelTest::IPV6.new
    obj_ser.ip  = "255.102.0.25"
    
    # Should Success
    obj_ser.ipv6  = "ff:fabf:faf:f15f:f1ff:f2f:1f:f2"
    #obj_ser.ipv6 = "2001:db8::ff00:1:8329";
    #obj_ser.ipv6 = "1::";
    #obj_ser.ipv6 = "::1";
    #obj_ser.ipv6 = "";
    
    # Should Fail or raise error
    #obj_ser.ipv6 = "2001:0db8:0000:0000:0000:ff00:0042:8329";
    #obj_ser.ipv6 = "2001:db8::fff00:42:8329";
    #obj_ser.ipv6 = "2001:db8:::ff00:42:8329";
    #obj_ser.ipv6 = "2001:db8:ff00:42:8329";
    #obj_ser.ipv6 = "::";

    ser = obj_ser.serialize
    serialize(ser)
    res = deserialize()

    obj_deser = BabelTest::IPV6.new
    obj_deser.deserialize res
    compare(obj_ser, obj_deser)
    
  end

  def compare(obj_ser, obj_deser)
    puts ""
    puts obj_ser.ipv6
    puts obj_deser.ipv6
    assert obj_ser.ip == obj_deser.ip
    assert obj_ser.ipv6 == obj_deser.ipv6
  end

  def serialize(data)
    File.open("bin.babel.rb", "w+b") do |f|
      f.write(data)
    end
  end

  def deserialize()
    mem_buf = File.new('bin.babel.rb').binmode
  end

end
