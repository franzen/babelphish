require "bundler/gem_tasks"

task :generateSrc do
  ruby "test/ipv6_test/ipv6_test.rb"
  ruby "test/complex_test/complex_test.rb"
  ruby "test/binaryTree_test/binaryTree_test.rb"
  ruby "test/basic_complex_test/basic_complex_test.rb"
end

task :test_rb do
  ruby "test/basic_complex_test/ruby_test/ruby_test.rb"
  ruby "test/binaryTree_test/ruby_test/ruby_test.rb"
  ruby "test/ipv6_test/ruby_test/ruby_test.rb"
  ruby "test/complex_test/ruby_test/ruby_test.rb"
end


task :test_js do
  system("node test/basic_complex_test/js_test/js_testBasic.js")
  system("node test/basic_complex_test/js_test/js_testComplex.js")
  system("node test/binaryTree_test/js_test/js_test.js")
  system("node test/ipv6_test/js_test/js_test.js")
  system("node test/complex_test/js_test/js_test.js")
end

task :test_java do
  system("javac -cp test/java_lib/junit.jar: test/ipv6_test/java_test/*.java")
  system("java -cp test/ipv6_test/java_test/:test/java_lib/junit.jar:. org.junit.runner.JUnitCore JavaTest")

  system("javac -cp test/java_lib/junit.jar: test/complex_test/java_test/*.java")
  system("java -cp test/complex_test/java_test/:test/java_lib/junit.jar:. org.junit.runner.JUnitCore JavaTest")

  system("javac -cp test/java_lib/junit.jar: test/binaryTree_test/java_test/*.java")
  system("java -cp test/binaryTree_test/java_test/:test/java_lib/junit.jar:. org.junit.runner.JUnitCore JavaTest")

  system("javac -cp test/java_lib/junit.jar: test/basic_complex_test/java_test/*.java")
  system("java -cp test/basic_complex_test/java_test/:test/java_lib/junit.jar:. org.junit.runner.JUnitCore JavaTest")

end
