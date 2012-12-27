# Divine

Divine provides a compact data interchange format for Ruby, Java and Javascript. Divine is similar to [Thrift](http://thrift.apache.org/) and [Protobuf](http://code.google.com/p/protobuf/), but I try to overcome of some of the shortcommings I think the other libraries have. 


## Example


```ruby
require 'divine'

struct 'TestBasic' do
  int8 :i8
  int16 :i16
  int32 :i32
  string :str
  ip_number :ip
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

Divine::CodeGenerator.new.generate(:ruby, file: 'test_babel.rb', module: 'BabelTest', parent_class: "Object")
Divine::CodeGenerator.new.generate(:javascript, file: 'test_babel.js')
```

The resulting _test_babel.rb_ contains the generated source code for the defined structs. Below is an example on how to use the generated code in ruby

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
p1.list1 = [0, 1, 255, 0x7FFFFFFF, 0x7FFFFFFF+1, 0xFFFFFFFE, 0xFFFFFFFF]
p1.list2 = [0,1, 15,16, 127,128, 254,255]
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

And a javascript example that uses the generated file _test_babel.js_

```javascript
var c1 = new TestComplex();
c1.list1 = [0, 1, 255, 0x7FFFFFFF, 0x7FFFFFFF+1, 0xFFFFFFFE, 0xFFFFFFFF];
c1.list2 = [0,1, 15,16, 127,128, 254,255];

c1.map1[0] = 10;
c1.map1[10] = 100;

c1.map2["FooBar"] = [new Entry(), new Entry()];


console.log("SERIALIZE");
var ca = c1.serialize();

console.log("DESERIALIZE");
var c2 = new TestComplex();
c2.deserialize(new BabelDataReader(ca));
console.log(c2);
```

### Versioning
```ruby
require 'divine'

struct 'Foobar' do # Default version is '1'
  int8 :foo
end


struct 'Foobar', version: 2 do
  int8 :foo
  int8 :bar # We added a new field named 'bar' in version 2 of Foobar
end

Divine::CodeGenerator.new.generate(:ruby, file: 'test_babel.rb')
Divine::CodeGenerator.new.generate(:java, file: 'test_babel.java')
```

There are some basic rules regarding versioning of structs

* A versioned struct defineds all fields you want to serialize/deserialize
* You can delete and add fields as you whish between versions
* You are not allowed to change type of a defined variable between versions
* You  cannot have a bigger version number than 255
* The class that represents the struct also defines a 'struct_version' that keeps the current version of the struct


## Installation

Add this line to your application's Gemfile:

    gem 'divine'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install divine

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
