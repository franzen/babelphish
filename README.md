# Babelphish

Babelphish provides a compact data interchange format for Ruby, Java and Javascript. Babelphish is similar to [Thrift](http://thrift.apache.org/) and [Protobuf](http://code.google.com/p/protobuf/), but I try to overcome of some of the shortcommings I think the other libraries have. 


## Example


```ruby
require 'babelphish'

struct 'TestBasic' do
  int8 :i8
  int16 :i16
  int32 :i32
  string :str
  ipnumber :ip
  binary :guid
end

struct 'Entry' do
  
end


struct(:TestComplex) {
  list :list1, :int32
  list :list2, :int8
  map :map1, :int8, :int32
  map(:map2, :string) { 
    list 'Entry'
  }
}

Babelphish::CodeGenerator.new.generate(:ruby, file: 'test_babel.rb', module: 'BabelTest', parent_class: "Object")
```

The resulting _test_babel.rb_ contains the generated source code for the defined structs. Below is an example on how to use the generated code

```ruby
require_relative 'test_babel.rb'

t1 = BabelTest::TestBasic.new
t1.i8 = 0x0F
t1.i16 = 0X1234
t1.i32 = 0x567890AB
t1.str = "abc\n123\tåäö´+'\""
t1.ip = "192.168.0.1"
t1.guid = (0..255).to_a

p1 = BabelTest::TestComplex.new
p1.list1 += (1000..1020).to_a
p1.list2 += (200..210).to_a
p1.map1[0] = 10
p1.map1[10] = 100
p1.map2["Hello"] = [BabelTest::Entry.new, BabelTest::Entry.new]


data1 = t1.serialize
data2 = p1.serialize
File.open("bin.babel", "w+b") do |f|
  f.write(data1)
  f.write(data2)
end

mem_buf = File.new('bin.babel').binmode
t2 = BabelTest::TestBasic.new
t2.deserialize mem_buf

p2 = BabelTest::TestComplex.new
p2.deserialize mem_buf
```



## Installation

Add this line to your application's Gemfile:

    gem 'babelphish'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install babelphish

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
