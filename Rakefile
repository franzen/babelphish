require "bundler/gem_tasks"

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
