require 'minitest/autorun'

#
# Responsible for equality testing to the produced byte files for all languages
#
class TestUnify < MiniTest::Unit::TestCase

  #
  # Make sure that the produced byte files from all languages in every test are the same.
  #
  def test_unify
    puts "Unify Test: Compare the produced binary files"
    paths = [
             	"test/binaryTree_test/",
             	"test/complex_test/",
        	"test/ipv6_test/",
		"test/signed_int_test/",
		"test/dynamic_int_test/"
            ]
    paths.each do |path|
      ruby   = readFile("#{path}ruby_test/bin.babel.rb")
      js     = readFile("#{path}js_test/bin.babel.js")
      java   = readFile("#{path}java_test/bin.babel")
      csharp = readFile("#{path}csharp_test/bin.babel.csharp")
	    
      assert_equal ruby, js
      assert_equal ruby, java
      assert_equal ruby, csharp
    end
  end

  #
  # Read certain file in binary mode and return its content bytes
  # * *Args* :
    #  - +file+ -> path to file name
  def readFile(file)
    data = File.new(file).binmode
    data.read(data.size).each_byte.to_a
  end

end
