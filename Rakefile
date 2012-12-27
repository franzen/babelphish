require "bundler/gem_tasks"


task :default => ["test:all"]


namespace :test  do
  desc "Run all tests"
  task :all => [:ruby, :js, :java, :unify]  	# Make sure that the unify test be the last one in the list.
  
  desc "Run Ruby code test suite"
  task :ruby do
    generate_source('ruby')
    ruby "test/signed_int_test/ruby_test/ruby_test.rb"
    ruby "test/ipv6_test/ruby_test/ruby_test.rb"
    ruby "test/complex_test/ruby_test/ruby_test.rb"
    ruby "test/binaryTree_test/ruby_test/ruby_test.rb"
    ruby "test/basic_complex_test/ruby_test/ruby_test.rb"
    system("find . -name 'test*.rb' | xargs rm") # Remove generated source code files
  end


  desc "Run JS code test suite"
  task :js do
    generate_source('js')
    system("node test/signed_int_test/js_test/js_test.js")
    system("node test/ipv6_test/js_test/js_test.js")
    system("node test/complex_test/js_test/js_test.js")
    system("node test/binaryTree_test/js_test/js_test.js")
    system("node test/basic_complex_test/js_test/js_testBasic.js")
    system("node test/basic_complex_test/js_test/js_testComplex.js")
    system("find . -name 'test*.js' | xargs rm") # Remove generated source code files
  end

  desc "Run java code test suite"
  task :java do
    generate_source('java')
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

    system("find . -name 'test*.java' | xargs rm") # Remove generated source code files
    system("find . -name '*.class' | xargs rm") # Remove generated .class files
  end

  desc "Unify test to compare the produced binary files. Prerequisite Other tests must be run first to generate bin files to be compared"
  task :unify do
     ruby "test/unify_test/unify_test.rb"
     system("find . -name 'bin.babel*' | xargs rm") # Remove generated bin files
  end
end


def generate_source(lang)
  puts "Divine Version #{Divine::VERSION}"
  ruby "test/signed_int_test/signed_int_test.rb #{lang}"
  ruby "test/ipv6_test/ipv6_test.rb #{lang}"
  ruby "test/complex_test/complex_test.rb #{lang}"
  ruby "test/binaryTree_test/binaryTree_test.rb #{lang}"
  ruby "test/basic_complex_test/basic_complex_test.rb #{lang}"
end
