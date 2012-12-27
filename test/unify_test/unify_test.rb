require 'minitest/autorun'

class TestUnify < MiniTest::Unit::TestCase

  def test_unify
    puts "Unify Test: Compare the produced binary files"
    paths = [
             	"test/binaryTree_test/",
             	"test/complex_test/",
        	"test/ipv6_test/",
		"test/signed_int_test/"
            ]
    paths.each do |path|
      ruby = readFile("#{path}ruby_test/bin.babel.rb")
      js   = readFile("#{path}js_test/bin.babel.js")
      java = readFile("#{path}java_test/bin.babel")
	    
      assert_equal ruby, js
      assert_equal ruby, java
    end
  end

  def readFile(file)
    data = File.new(file).binmode
    data.read(data.size).each_byte.to_a
  end

end
