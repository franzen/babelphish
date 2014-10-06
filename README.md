# Divine

Divine provides a compact data interchange format for Ruby, Java and Javascript. Divine is similar to [Thrift](http://thrift.apache.org/) and [Protobuf](http://code.google.com/p/protobuf/), but I try to overcome of some of the shortcommings I think the other libraries have. 

This software is still under active development and testing.

We support C#, Java, Ruby and Javascript at the moment.


## Supported types

<table>
	<tr>
		<th>Name</th>
		<th>Range</th>
		<th>Range (hex)</th>
		<th>Description</th>
	</tr>
	<tr>
		<td>int8</td>
		<td>0-255</td>
		<td>0x00-0xFF</td>
		<td>Unsinged integer stored in a singe byte</td>
	</tr>
	<tr>
		<td>int16</td>
		<td>0-65,535</td>
		<td>0x00-0xFFFF</td>
		<td>Unsinged integer stored in two bytes</td>
	</tr>
	<tr>
		<td>int24</td>
		<td>0-16,777,215</td>
		<td>0x00-0xFFFFFF</td>
		<td>Unsinged integer stored in three bytes</td>
	</tr>
	<tr>
		<td>int32</td>
		<td>0-4,294,967,295</td>
		<td>0x00-0xFFFFFFFF</td>
		<td>Unsinged integer stored in four bytes</td>
	</tr>
	<tr>
		<td>dint63</td>
		<td>0-9,223,372,036,854,775,807</td>
		<td>0x00-0x7FFFFFFFFFFFFFFF</td>
		<td>The dynamic int 63 will use between 1 to 9 bytes to represent the value. It will use 1 bit/byte to keep information if the next byte is used for the dynamic int
			<table>
				<tr><th>Size</th><th>Max value</th></tr>
				<tr><td>1 byte</td><td>127</td></tr>
				<tr><td>2 bytes</td><td>16,383</td></tr>
				<tr><td>3 bytes</td><td>2,097,151</td></tr>
				<tr><td>4 bytes</td><td>268,435,455</td></tr>
				<tr><td>5 bytes</td><td>34,359,738,367</td></tr>
				<tr><td>6 bytes</td><td>4,398,046,511,103</td></tr>
				<tr><td>7 bytes</td><td>562,949,953,421,311</td></tr>
				<tr><td>8 bytes</td><td>72,057,594,037,927,935</td></tr>
				<tr><td>9 bytes</td><td>9,223,372,036,854,775,807</td></tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>sint32</td>
		<td>-2,147,483,648 to 2,147,483,647</td>
		<td></td>
		<td>A signed integer that requires 4 bytes</td>
	</tr>
	<tr>
		<td>sint64</td>
		<td>-9,223,372,036,854,775,808 to 9,223,372,036,854,775,807</td>
		<td></td>
		<td>A signed integer that requires 8 bytes</td>
	</tr>
</table>

<table>
	<tr>
		<th>Name</th>
		<th>Description</th>
	</tr>
	<tr>
		<td>bool</td>
		<td>Write a boolean value requiring 1 byte</td>
	</tr>
	<tr>
		<td>binary</td>
		<td>Write a byte array of max 4,294,967,295 bytes</td>
	</tr>
	<tr>
		<td>string</td>
		<td>A UTF-8 based string of max 65,535 bytes (and one UTF8 char is represented by between 1 to 4 bytes)</td>
	</tr>
	<tr>
		<td>ip_number</td>
		<td>A IPv4 or IPv6 number as a string. An IPv4 number require 5 bytes, while an IPv6 number will require somewhere between 3-17 bytes.</td>
	</tr>
	<tr>
		<td>list</td>
		<td>A list of items</td>
	</tr>
	<tr>
		<td>map</td>
		<td>A hash-map of key/value items</td>
	</tr>
</table>

## Example 1


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

## Example 2
```ruby
require 'divine'

struct 'SignedInt' do
  list :list1, :sint32
  list :list2, :sint64
end

Divine::GraphGenerator.new.draw(".", "graph", "jpg")

Divine::CodeGenerator.new.generate(:java, file: 'test.java')
Divine::CodeGenerator.new.generate(:csharp, file: 'test.cs')
```
a Java example that uses the generated file test.java
```java
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;

public class JavaTest {

	public void testSignedInt() throws IOException {
		SignedInt ser = buildObj();
		
		serialize(ser);
		byte[] res = deserialize();

		SignedInt deser = new SignedInt();
		deser.deserialize(new ByteArrayInputStream(res));

		compare(ser, deser);
	}

	public SignedInt buildObj() {
		SignedInt obj = new SignedInt();
		obj.list1   = new ArrayList<Integer>(){{
			add(-1);
			add(-2);
			add(-3);
			add(Integer.MAX_VALUE);
			add(Integer.MIN_VALUE);
		}};
		
		obj.list2   = new ArrayList<Long>(){{
			add(-1L);
			add(-2L);
			add(-3L);
			add( (long)Math.pow(2, 54-1)-1 );
			add( (long)(Math.pow(2, (54-1)) - Math.pow(2, 54)) );
		}};

		return obj;
	}

	public void compare(SignedInt obj1, SignedInt obj2) {
		for (int i = 0; i < obj1.list1.size(); i++){
			System.out.println("Ser = " + obj1.list1.get(i) + ", Deser = " + obj2.list1.get(i));
		}		
		for (int i = 0; i < obj1.list2.size(); i++){
			System.out.println("Ser = " + obj1.list2.get(i) + ", Deser = " + obj2.list2.get(i));
		}
	}

	public void serialize(Divine obj) throws IOException {
		byte[] data = obj.serialize();
		File file = new File("bin.babel");
		try {
			new FileOutputStream(file).write(data);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public byte[] deserialize() throws IOException{
		File file = new File("bin.babel");
		byte[] data = new byte[(int) file.length()];
		try {
			new FileInputStream(file).read(data);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return data;
	}

}
```
And a C# example that uses the generated file test.cs
```csharp
using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using divine;

namespace test
{
    class divine
    {
        public static void Main(String[] args)
        {
            SignedInt ser = buildObj();
            serialize(ser);
            byte[] res = deserialize();

            SignedInt deser = new SignedInt();
            deser.deserialize(new MemoryStream(res));

            compare(ser, deser);
   
            System.Console.Read();
            
        }

        public static SignedInt buildObj() {
		SignedInt obj = new SignedInt();
		obj.list1.Add(-1);
		obj.list1.Add(-2);
		obj.list1.Add(-3);
		obj.list1.Add(int.MaxValue);
		obj.list1.Add(int.MinValue);

		obj.list2.Add(-1);
		obj.list2.Add(-2);
		obj.list2.Add(-3);
		obj.list2.Add( (long) Math.Pow(2, 53) -1 );
		obj.list2.Add( (long) (Math.Pow(2, 53) - Math.Pow(2, 54)) );
            return obj;
	    }

        public static void compare(SignedInt obj1, SignedInt obj2)
        {
            for (int i = 0; i < obj1.list1.Count; i++)
            {
                System.Console.Write("Ser = " + obj1.list1[i] + ", Deser = " + obj2.list1[i] + "\n");
            }
            for (int i = 0; i < obj1.list2.Count; i++)
            {
                System.Console.Write("Ser = " + obj1.list2[i] + ", Deser = " + obj2.list2[i] + "\n");
            }
        }

        public static void serialize(Divine obj)
        {
            try
            {
                byte[] data = obj.serialize();
                File.WriteAllBytes("bin.babel", data);                
            }
            catch (System.IO.IOException ex)
            {
                throw ex;
            }
	}

	public static byte[] deserialize()
	{
            try
            {
                byte[] data = File.ReadAllBytes("bin.babel");
                return data;
            }
            catch (System.IO.IOException ex)
            {
                throw ex;
            }
	}
            
    }
}
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

* A versioned struct defines all fields you want to serialize/deserialize
* You can delete and add fields as you whish between versions
* You are not allowed to change type of a defined variable between versions
* You cannot have a bigger version number than 255
* The class that represents the struct also defines a 'struct_version' that keeps the current version of the struct


### Freezing
When starting to use generated code in production, the defined structs cannot be changed without breaking everything (unless you really know what you're doing).
To prevent that you change a struct by accident, you can 'freeze' a struct. The easiest way to get started is to add a empty _freeze_ field to the struct, like below

```ruby
require 'divine'

struct 'Foobar', freeze: '' do
  int8 :foo
  int8 :bar
end

Divine::CodeGenerator.new.generate(:ruby, file: 'test_babel.rb')
```

The compiler will throw a runtime exception saying that the MD5 sum differs. Take the MD5 sum from this exception and put into the _freeze_ field as below 

```ruby
require 'divine'

struct 'Foobar', freeze: '3e59aa582d3137a2d0cdba174e5aa6b18beb649b' do
  int8 :foo
  int8 :bar
end

Divine::CodeGenerator.new.generate(:ruby, file: 'test_babel.rb')
```

It is now not possible to alter _Foobar_ by accident. If you make a change to the struct, you will also need to provide a correct MD5 sum.


### Graphviz

To generate a graphviz diagram of your defined structs, add the following line to your definition file

```ruby
Divine::GraphGenerator.new.draw(".", "graph", "jpg")
```


## Caveats
Javascript does only support numbers in the range of -9,007,199,254,740,992 to 9,007,199,254,740,991, a runtime error is thrown if you try to deserialize bigger number.


## Change log
Version 0.0.5

* Adapted to docile 1.1.5
* Removed short_binary


Version 0.0.4

* Added dint63 (Dynamic Int 63)
* Added graphviz graph generation

Version 0.0.3

* Added C# code generator
* Added sint32 and sint64 (Signed Int 32 and 64)
* Added versioning and freezing


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
