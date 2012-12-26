require "bundler/gem_tasks"

namespace :test  do
  
  desc "Run Ruby code test suite"
  task :ruby => :environment do
    #ruby "test/signed_float_test/ruby_test/ruby_test.rb"
    
    ruby "test/signed_int_test/ruby_test/ruby_test.rb"
    ruby "test/basic_complex_test/ruby_test/ruby_test.rb"
    ruby "test/binaryTree_test/ruby_test/ruby_test.rb"
    ruby "test/ipv6_test/ruby_test/ruby_test.rb"
    ruby "test/complex_test/ruby_test/ruby_test.rb"
  end


  desc "Run JS code test suite"
  task :js => :environment do
    system("node test/signed_int_test/js_test/js_test.js")
    system("node test/basic_complex_test/js_test/js_testBasic.js")
    system("node test/basic_complex_test/js_test/js_testComplex.js")
    system("node test/binaryTree_test/js_test/js_test.js")
    system("node test/ipv6_test/js_test/js_test.js")
    system("node test/complex_test/js_test/js_test.js")
  end

  desc "Run java code test suite"
  task :java => :environment do

    #system("javac -cp test/java_lib/junit.jar: test/signed_float_test/java_test/*.java")
    #system("java -cp test/signed_float_test/java_test/:test/java_lib/junit.jar:. org.junit.runner.JUnitCore JavaTest")

    system("javac -cp test/java_lib/junit.jar: test/signed_int_test/java_test/*.java")
    system("java -cp test/signed_int_test/java_test/:test/java_lib/junit.jar:. org.junit.runner.JUnitCore JavaTest")

    system("javac -cp test/java_lib/junit.jar: test/ipv6_test/java_test/*.java")
    system("java -cp test/ipv6_test/java_test/:test/java_lib/junit.jar:. org.junit.runner.JUnitCore JavaTest")

    system("javac -cp test/java_lib/junit.jar: test/complex_test/java_test/*.java")
    system("java -cp test/complex_test/java_test/:test/java_lib/junit.jar:. org.junit.runner.JUnitCore JavaTest")

    system("javac -cp test/java_lib/junit.jar: test/binaryTree_test/java_test/*.java")
    system("java -cp test/binaryTree_test/java_test/:test/java_lib/junit.jar:. org.junit.runner.JUnitCore JavaTest")

    system("javac -cp test/java_lib/junit.jar: test/basic_complex_test/java_test/*.java")
    system("java -cp test/basic_complex_test/java_test/:test/java_lib/junit.jar:. org.junit.runner.JUnitCore JavaTest")
  end


  desc "Generate Source Code"
  task :environment do
    puts "Divine Version #{Divine::VERSION}"
    lang = Rake.application.top_level_tasks[0].match(/:(.*)/)[1]
    
    #ruby "test/signed_float_test/signed_float_test.rb #{lang}"

    ruby "test/signed_int_test/signed_int_test.rb #{lang}"
    ruby "test/basic_complex_test/basic_complex_test.rb #{lang}"
    ruby "test/ipv6_test/ipv6_test.rb #{lang}"
    ruby "test/complex_test/complex_test.rb #{lang}"
    ruby "test/binaryTree_test/binaryTree_test.rb #{lang}"
  end
end

