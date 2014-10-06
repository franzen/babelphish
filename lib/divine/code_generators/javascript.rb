# Some notes on Javascript and numbers:
# . The bitwise operators and shift operators operate on 32-bit ints.
# . Note that all the positive and negative integers whose magnitude is no greater than 253 are representable in the Number type (indeed, the integer 0 has two representations, +0 and −0).
# . They are 64-bit floating point values, the largest exact integral value is 2^53, or 9007199254740992 (-9007199254740992 to 9007199254740992)


module Divine
  $debug_javascript = false
##
# * +JS Helper+ :
# Support base function needed to build base divine functions and DSL structs
#
  class JavascriptHelperMethods < BabelHelperMethods

    #
    # Return the header comment
    #
    def get_header_comment
      get_header_comment_text.map do |s|
        "// #{s}"
      end.join("\n")
    end
##
# Generate the base functions of:
# * serialize
# * deserialize
# * Read Methods
# * Write Methods

    def javascript_base_class_template_str
      <<EOS
// ------------------------------------------------------------ DivineDataReader
function DivineDataReader(data) {
    this.data = data;
    this.index = 0;
}

DivineDataReader.prototype.getbyte = function () {
    return this.data[this.index++];
};

DivineDataReader.prototype.read = function (items) {
    var from = this.index;
    this.index += items
    return this.data.subarray(from, this.index)
};


// ------------------------------------------------------------ DivineDataWriter
function DivineDataWriter(data) {
    this.data = data;
    this.index = 0;
    this.data = new Uint8Array(4096);
}

DivineDataWriter.prototype._realloc = function (size) {
    size = size || 4096;
    var old_data = this.data;
    this.data = new Uint8Array(Math.max(size, 4096) + this.data.length);
    this.data.set(old_data, 0);
};

DivineDataWriter.prototype.writeByte = function (a_byte) {
    if (this.index + 1 >= this.data.length) this._realloc();
    this.data[this.index++] = a_byte;
};

DivineDataWriter.prototype.write = function (bytes) {
    if (this.index + bytes.length >= this.data.length) this._realloc(bytes.length);
    this.data.set(bytes, this.index);
    this.index += bytes.length;
};

DivineDataWriter.prototype.get_data = function () {
    return this.data.subarray(0, this.index);
};


// ------------------------------------------------------------ DivineHelper
function DivineHelper() {}

DivineHelper.prototype.serialize = function () {
    var out = new DivineDataWriter();
    this.serialize_internal(out);
    return out.get_data();
}

DivineHelper.prototype.read_int8 = function (data) {
    return data.getbyte();
};

DivineHelper.prototype.read_int16 = function (data) {
    return (data.getbyte() << 8) | this.read_int8(data);
};

DivineHelper.prototype.read_int24 = function (data) {
    return (data.getbyte() << 16) | this.read_int16(data);
};

DivineHelper.prototype.read_int32 = function (data) {
    // return (data.getbyte() << 24) | this.read_int24(data); // See notes about numbers above
    return (data.getbyte() * (256*256*256)) + this.read_int24(data);
};

DivineHelper.prototype.read_sint32 = function (data) {
    // return (data.getbyte() << 24) | this.read_int24(data); // See notes about numbers above
    var num = (data.getbyte() * (256*256*256)) + this.read_int24(data);
    if (num > (Math.pow(2, 32 - 1) -1) ){
      return num - Math.pow(2, 32);
    }
    return num;
};

DivineHelper.prototype.read_sint64 = function (data) {
    var part1 = this.read_int32(data).toString(2);	// read first part of 32 bit number
    var part2 = this.read_int32(data).toString(2);  	// read second part of 32 bit.
    if (part1.length < 32){ 				// deal with positive number
      part2 = Array(32 - part2.length + 1).join("0") + part2;
      return parseInt((part1 + part2), 2);
    }else{						// deal with negative number
      part1 = part1.substr(11,part1.length);
      part2 = Array(32 - part2.length + 1).join("0") + part2;
      var binStr = part1 + part2;
      binStr = binStr.replace(/1/g,'f').replace(/0/g,'1').replace(/f/g,'0');
      val    = parseInt(binStr, 2) + 1;
      return val * -1;
    }
}

DivineHelper.prototype.read_dint63 = function (data) {
    var byte = this.read_int8(data)
    var part1 = part2 = "";				// To hold first 32-bit and second 32-bit respectively
    var bin =  byte & 0x7F;				// tmp To hold binary string
    var numBytes = 1;
    while ((byte >> 7) == 1) {
      byte = this.read_int8(data)
      bin = bin << 7
      bin = bin | byte & 0x7F
      numBytes ++;
      if (numBytes == 4 && (byte >> 7) == 1){
        part1 = bin.toString(2);
        bin = 1;					// To avoid unshifting of zero
      }
    }
    bin = bin.toString(2);
    if (bin.length > 1 && part1 != "")
      bin = bin.substr(1, bin.length);
    part2 = bin;
    var val = parseInt(part1 + part2, 2);
    return val;
}

DivineHelper.prototype.read_bool = function (data) {
    return this.read_int8(data) == 1;
}

DivineHelper.prototype.read_binary = function (data) {
    return data.read(this.read_dint63(data));
};

DivineHelper.prototype.read_ip_number = function (data) {
    var ip_array = data.read(this.read_int8(data));
    if(ip_array.length == 4){
       return this.read_ipv4_number(ip_array);
    }else{
       return this.read_ipv6_number(ip_array);
    }
};

DivineHelper.prototype.read_ipv4_number = function (ip_array) {
    ip = "";
    for (i = 0, len = ip_array.length; i < len; i++) {
        b = ip_array[i];
        if (ip.length > 0) {
            ip += ".";
        }
        ip += b.toString();
    }
    return ip;
};
DivineHelper.prototype.read_ipv6_number = function (ip_array) {
    var ip = "";
    var part1, part2;
    for (i = 0, len = ip_array.length; i < len; i+=2) {
        part1 = ip_array[i];
        part2 = ip_array[i+1];
        ip += part1 == 0? "" : part1.toString(16);
        ip += (part1 == 0 && part2 == 0)? "" : (part2 < 10 && part1 != 0? "0" + part2.toString(16): part2.toString(16));
        if (i < ip_array.length-2)
            ip += ":";
    }
    ip = ip.replace(/:{3,}/g, "::");
    return ip;
};

DivineHelper.prototype.read_string = function (data) {
    return this.decode_utf8(data.read(this.read_dint63(data)))
};

DivineHelper.prototype.write_int8 = function (v, out) {
    if (v > 0xFF) // Max 255
      this.raise_error("Too large int8 number: " + v);
    if(v < 0)
      this.raise_error("a negative number passed  to int8 number: " + v);
    out.writeByte(v);
}

DivineHelper.prototype.write_int16 = function (v, out) {
    if (v > 0xFFFF) // Max 65.535
      this.raise_error("Too large int16 number: " + v);
    if(v < 0)
      this.raise_error("a negative number passed  to int16 number: " + v);
    this.write_int8(v >> 8 & 0xFF, out);
    this.write_int8(v & 0xFF, out);
}

DivineHelper.prototype.write_int24 = function (v, out) {
    if (v > 0xFFFFFF) 	// Max 16.777.215
      this.raise_error("Too large int24 number: " + v);
    if (v < 0)		// In Case added to JavaScript declaration
      this.raise_error("a negative number passed  to int24 number: " + v);
    this.write_int8(v >> 16 & 0xFF, out);
    this.write_int16(v & 0xFFFF, out);
}

DivineHelper.prototype.write_int32 = function (v, out) {
    if (v > 0xFFFFFFFF) // Max 4.294.967.295
      this.raise_error("Too large int32 number: " + v);
    if(v < 0)
      this.raise_error("a negative number passed  to int32 number: " + v);
    this.write_int8(v >> 24 & 0xFF, out);
    this.write_int24(v & 0xFFFFFF, out);
}

DivineHelper.prototype.write_sint32 = function (v, out) {
    var max = Math.pow(2, 32 - 1) - 1;
    var min = Math.pow(2, 32 - 1) - Math.pow(2, 32);
    if (v > max) 			// Max  2.147.483.647
      this.raise_error("Too large sInt32 number: " + v + ", Max = " + max);
    if(v < min)				// Min -2.147.483.648
      this.raise_error("Too small sInt32 number: " + v + ", Min = " + min);
    this.write_int8(v >> 24 & 0xFF, out);
    this.write_int24(v & 0xFFFFFF, out);
}

DivineHelper.prototype.write_sint64 = function (v, out) {
    var max =  Math.pow(2, 53) - 1;
    var min = -Math.pow(2, 53);
    if (v > max)			// Max  9,007,199,254,740,991
      this.raise_error("Too large sInt64 number: " + v + ", Max = " + max);
    if (v < min)	 		// Min -9,007,199,254,740,992
      this.raise_error("Too small sInt64 number: " + v + ", Min = " + min);
    
    binStr = v.toString(2);
    if (v < 0){
      invBinStr = binStr.replace('-','').replace(/1/g,'f').replace(/0/g,'1').replace(/f/g,'0');
      invBinStr = (parseInt(invBinStr, 2) + 1).toString(2);
      binStr    = Array(binStr.length - invBinStr.length).join("0") + invBinStr;
      binStr    = Array(64 - binStr.length + 1).join("1") + binStr;
    }else{
      binStr    = Array(64 - binStr.length + 1).join("0") + binStr;
    }
    part1  = binStr.substr(0, binStr.length - 32);
    part2  = binStr.substr(binStr.length - 32, binStr.length);
    this.write_int32(parseInt(part1, 2), out);
    this.write_int32(parseInt(part2, 2), out);
}

DivineHelper.prototype.write_dint63 = function (v, out) {
    var max =  Math.pow(2, 53) - 1;
    var min = 0;
    if (v > max)			// Max  9,007,199,254,740,991
      this.raise_error("Too large Dynamic Int53 number: " + v + ", Max = " + max);
    if (v < min)	 		// Min 0
      this.raise_error("Too small Dynamic Int53 number: " + v + ", Min = " + min);
    
    bytes = v.toString(2).split("").reverse().join("").split(/(.{7})/).filter(function(t){if (t != "" ) return true});
    for (var i = bytes.length - 1; i >= 0; i--){
       var bin = bytes[i];
       bin += Array(8 - bin.length).join("0") + Math.min(i,1);
       var val = parseInt(bin.split("").reverse().join(""), 2);
       this.write_int8(val, out);  
    }
}

DivineHelper.prototype.write_bool = function (v, out) {
    this.write_int8(v ? 1 : 0, out)
}

DivineHelper.prototype.write_string = function (v, out) {
    var s = this.encode_utf8(v);
    if (s.length > 0xFFFF) this.raise_error("Too large string: " + s.length + " bytes");
    this.write_dint63(s.length, out);
    out.write(s);
}

DivineHelper.prototype.write_binary = function (v, out) {
    if ((v instanceof Array) || (v instanceof Uint8Array)) {
        if (v.length > 0xFFFFFFFF) this.raise_error("Too large binary: " + v.length + " (" + v.constructor.name + ")");
        this.write_dint63(v.length, out)
        out.write(v);
    } else if (v.constructor == String) {
        if (v.length > 0xFFFFFFFF) this.raise_error("Too large binary: " + v.length + " (" + v.constructor.name + ")");
        this.write_dint63(v.length, out)
        out.write(v);
    } else if (v == null) {
        this.raise_error("Unsupported binary 'null'");
    } else {
        this.raise_error("Unsupported binary of type '" + v.constructor.name + "'");
    }
}

DivineHelper.prototype.write_16_binary = function (v, out) {
    if ((v instanceof Array) || (v instanceof Uint8Array)) {
        if (v.length > 0xFF) this.raise_error("Too large 16 binary: " + v.length*2 + " (" + v.constructor.name + ")");
        this.write_int8(v.length * 2, out)
        for (i = 0, len = v.length; i < len; i++) {
	  this.write_int16(v[i], out);
        }
        
    } else if (v == null) {
        this.raise_error("Unsupported binary 'null'");
    } else {
        this.raise_error("Unsupported binary of type '" + v.constructor.name + "'");
    }
}

DivineHelper.prototype.write_ip_number = function (v, out) {
    if ((v instanceof Array) || (v instanceof Uint8Array)){
      if(v.length == 4){
         this.write_ipv4_number(v, out);
      }else{
         this.write_ipv6_number(v, out);
      }
    }else if(v.constructor == String){
      if(/:/g.test(v)){
         this.write_ipv6_number(v, out);
      }else{
         this.write_ipv4_number(v, out);
      }
    }else{
      this.raise_error("Unknown IP number '" + v + "'");
    }
}

DivineHelper.prototype.write_ipv4_number = function (v, out) {
    if ((v instanceof Array) || (v instanceof Uint8Array)) {
        if (v.length != 4 && v.length != 0) this.raise_error("Unknown IP v4 number " + v);
        this.write_int8(v.length, out)
        out.write(v);
    } else if (v.constructor == String) {
        var ss = [];
        if (v.length > 0) {
            ss = v.split(".").map(Number);
        }
        this.write_ipv4_number(ss, out);
    } else {
        this.raise_error("Unknown IP number '" + v + "'");
    }
};

DivineHelper.prototype.write_ipv6_number = function (v, out) {
    if ((v instanceof Array) || (v instanceof Uint8Array)) {
        this.write_16_binary(v, out)
    } else if (v.constructor == String) {
        var ss = [];
        var contains_ipv6_letters  = /[0-9a-f]+/gi.test(v);
        var contains_other_letters = /[^:0-9a-f]+/gi.test(v);
        if (v.length > 0 && v.split(/:{3,}/g).length == 1 && v.split(/:{2}/g).length <= 2 && !contains_other_letters && 
            contains_ipv6_letters) {
            v = v.replace(/ /g, "");
            ss = v.split(":").map(function (t){
               if (t.length > 4)
		 new DivineHelper().raise_error("Unknown IP Group number '" + t + "'");
               if (t.length == 0)
                 t = "0";
               return parseInt(t, 16);
            });
        }
        if (!contains_other_letters &&
           ( !/::/g.test(v) && ss.length == 0 || ss.length == 8) || ( /::/g.test(v) && ss.length > 2 && ss.length < 8) ) {
          this.write_ipv6_number(ss, out);
        } else {
          this.raise_error("Unknown IP v6 number '" + v + "'");
        }

    } else {
        this.raise_error("Unknown IP v6 number '" + v + "'");
    }
}

DivineHelper.prototype.encode_utf8 = function (str) {
    var utf8 = [];
    var chr, next_chr;
    var x, y, z;
    for (var i = 0; i < str.length; i++) {
        chr = str.charCodeAt(i);
        if ((chr & 0xFF80) == 0) {
            utf8.push(chr);
        } else {
            if ((chr & 0xFC00) == 0xD800) {
                next_chr = str.charCodeAt(i + 1);
                if ((next_chr & 0xFC00) == 0xDC00) {
                    // UTF-16 surrogate pair
                    chr = (((chr & 0x03FF) << 10) | (next_chr & 0X3FF)) + 0x10000;
                    i++;
                } else {
                    this.raise_error("Error decoding surrogate pair: " + chr + ", " + next_chr);
                }
            }
            x = chr & 0xFF;
            y = chr & 0xFF00;
            z = chr & 0xFF0000;

            if (chr <= 0x0007FF) {
                utf8.push(0xC0 | (y >> 6) | (x >> 6));
                utf8.push(0x80 | (x & 63));
            } else if (chr <= 0x00FFFF) {
                utf8.push(0xe0 | (y >> 12));
                utf8.push(0x80 | ((y >> 6) & 63) | (x >> 6));
                utf8.push(0x80 | (x & 63));
            } else if (chr <= 0x10FFFF) {
                utf8.push(0xF0 | (z >> 18));
                utf8.push(0x80 | ((z >> 12) & 63) | (y >> 12));
                utf8.push(0x80 | ((y >> 6) & 63) | (x >> 6));
                utf8.push(0x80 | (x & 63));
            } else {
                this.raise_error("Error encoding to UTF8: " + chr + " is greater than U+10FFFF");
            }
        }
    }
    return utf8;
}

DivineHelper.prototype.decode_utf8 = function (utf8_data) {
    var str = "";
    var chr, b2, b3, b4;
    for (var i = 0; i < utf8_data.length; i++) {
        chr = utf8_data[i];
        if ((chr & 0x80) == 0x00) {} 
        else if ((chr & 0xF8) == 0xF0) {
            // 4 bytes: U+10000 - U+10FFFF
            b2 = utf8_data[i + 1];
            b3 = utf8_data[i + 2];
            b4 = utf8_data[i + 3];
            if ((b2 & 0xc0) == 0x80 && (b3 & 0xC0) == 0x80 && (b4 & 0xC0) == 0x80) {
                chr = (chr & 7) << 18 | (b2 & 63) << 12 | (b3 & 63) << 6 | (b4 & 63);
                i += 3;
            } else {
                this.raise_error("Error decoding from UTF8: " + chr + "," + b2 + "," + b3 + "," + b4);
            }
        } else if ((chr & 0xF0) == 0xE0) {
            // 3 bytes: U+0800 - U+FFFF
            b2 = utf8_data[i + 1];
            b3 = utf8_data[i + 2];
            if ((b2 & 0xC0) == 0x80 && (b3 & 0xC0) == 0x80) {
                chr = (chr & 15) << 12 | (b2 & 63) << 6 | (b3 & 63);
                i += 2;
            } else {
                this.raise_error("Error decoding from UTF8: " + chr + "," + b2 + "," + b3);
            }
        } else if ((chr & 0xE0) == 0xC0) {
            // 2 bytes: U+0080 - U+07FF
            b2 = utf8_data[i + 1];
            if ((b2 & 0xC0) == 0x80) {
                chr = (chr & 31) << 6 | (b2 & 63);
                i += 1;
            } else {
                this.raise_error("Error decoding from UTF8: " + chr + "," + b2);
            }
        } else {
            // 80-BF: Second, third, or fourth byte of a multi-byte sequence
            // F5-FF: Start of 4, 5, or 6 byte sequence
            this.raise_error("Error decoding from UTF8: " + chr + " encountered not in multi-byte sequence");
        }
        if (chr <= 0xFFFF) {
            str += String.fromCharCode(chr);
        } else if (chr > 0xFFFF && chr <= 0x10FFFF) {
            // Must be encoded into UTF-16 surrogate pair.
            chr -= 0x10000;
            str += (String.fromCharCode(0xD800 | (chr >> 10)) + String.fromCharCode(0xDC00 | (chr & 1023)));
        } else {
            this.raise_error("Error encoding surrogate pair: " + chr + " is greater than U+10ffff");
        }
    }
    return str;
}

DivineHelper.prototype.raise_error = function (msg) {
    throw "[" + this.constructor.name + "] " + msg;
}
EOS
    end

##
#  Generate required functions that corresponding to the struct definition
#  * *Args*    :
#   - +sh+ -> Struct Name

    def javascript_class_template(sh)
      code = [
        "",
        "// ------------------------------------------------------------ #{sh.name}",
        "function #{sh.name}() {",
        :indent,
        "DivineHelper.call(this);",
        "",
        # PROPERTIES
      	"this.struct_version = #{sh.latest_version};",
        sh.field_names.map do |fn|
          f = sh.field(fn).last
          "this.#{f.name} = #{javascript_get_empty_declaration(f)};"
        end,
        :deindent,
        "}", "",
        
        "// Inherit DivineHelper",
        "#{sh.name}.prototype = new DivineHelper();", "",

        "// Correct the constructor pointer because it points to DivineHelper",
        "#{sh.name}.prototype.constructor = #{sh.name};", "",

        # SERiALIZE INTERNAL
        "// Serialize",
        "#{sh.name}.prototype.serialize_internal = function(out) {",
        :indent,
        "this.write_int8(this.struct_version, out);",
        sh.structs.map do |s|
          [
            "if(this.struct_version == #{s.version}) {",
            :indent,
            s.simple_fields.map do |f|
              "this.write_#{f.type}(this.#{f.name}, out);"
            end,
            s.complex_fields.map do |f|
              [
                "", "// Serialize #{f.type} '#{f.name}'",
                $debug_javascript ? "console.log(\"Serialize '#{field.name}'\");" : nil,
                javascript_serialize_internal("this.#{f.name}",  f.referenced_types)
              ]
            end,
            "return;",
            :deindent,
            "}", ""
          ]
        end, "",
        "throw \"Unsupported version \" + this.struct_version + \" for type '#{sh.name}'\";",
        :deindent,
        "}", "",

        # DESERIALIZE
        "// Deserialize",
        "#{sh.name}.prototype.deserialize = function (data) {",
        :indent,
        "this.struct_version = this.read_int8(data);",
        sh.structs.map do |s|
          [
            "if(this.struct_version == #{s.version}) {",
            :indent,
            s.simple_fields.map do |f|
              "this.#{f.name} = this.read_#{f.type}(data);"
            end,
            s.complex_fields.map do |f|
              [
                "", "// Read #{f.type} '#{f.name}'",
                $debug_javascript ? "console.log(\"Deserialize '#{field.name}'\");" : nil,
                javascript_deserialize_internal("this.#{f.name}",  f.referenced_types)
              ]
            end,
            "return;",
            :deindent,
            "}"
          ]
        end, "",
        "throw \"Unsupported version \" + this.struct_version + \" for type '#{sh.name}'\";",
        :deindent,
        "}"
      ]
        
      format_src(0, 3, code)
    end

##
#  Generate default JS data types declaration values corresponding to each DSL types:
#  * DSL Type --> Corresponding Default JS Value
#  * dint63   --> 0 range -> [0 - 9.007.199.254.740.991]
#   * 1 byte:  range ->  [0 - 127]
#   * 2 bytes: range ->  [0 - 16,383]
#   * 3 bytes: range ->  [0 - 2,097,151]
#   * 4 bytes: range ->  [0 - 268,435,455]
#   * 5 bytes: range ->  [0 - 34,359,738,367]
#   * 6 bytes: range ->  [0 - 4,398,046,511,103]
#   * 7 bytes: range ->  [0 - 562,949,953,421,311]
#   * 8 bytes: range ->  [0 - 9.007.199.254.740.991] (limited by 53-bit)
#  * int8     --> 0 Range -> [0 - 255]
#  * int16    --> 0 Range -> [0 - 65535]
#  * int32    --> 0 Range -> [0 - 4.294.967.295]
#  * sint32   --> 0 Range -> [-2.147.483.648 - 2.147.483.647]
#  * sint64   --> 0 Range -> [-9.007.199.254.740.992, 9.007.199.254.740.991] (limited by 53-bit)
#  * string   --> ""
#  * ip_number--> ""
#  * binary   --> []
#  * list     --> []
#  * map      --> {}

    def javascript_get_empty_declaration(field)
      case field.type
      when :list, :binary
        "[]"
      when :map
        "{}"
      when :int8, :int16, :int32, :sint32, :sint64, :dint63
        "0"
      when :string, :ip_number
        "\"\""
      when :bool
        false
      else
        raise "Unkown field type #{field.type}"
      end
    end

##
#  Generate the way of serializing different DSL types
#  * *Args*    :
#   - +var+   -> variable name
#   - +types+ -> variable type

    def javascript_serialize_internal(var, types)
      if types.respond_to? :first
        case types.first
        when :list
          nv = get_fresh_variable_name
          idx = get_fresh_variable_name
          return [
                  "this.write_dint63(#{var}.length, out);",
                  "for(var #{idx}=0; #{idx}<#{var}.length; #{idx}++) {",
                  :indent,
                  "var #{nv} = #{var}[#{idx}];",
                  javascript_serialize_internal(nv, types[1]),
                  :deindent,
                  "}"
                 ]
        when :map
          len = get_fresh_variable_name
          nv1 = get_fresh_variable_name      
          nv2 = get_fresh_variable_name
          key = get_fresh_variable_name
          return [
                  "var #{len} = Object.keys(#{var}).length;",
                  "this.write_dint63(#{len}, out);",
                  "for(var #{nv1} in #{var}) {",
                  :indent,
                  "var #{nv2} = #{var}[#{nv1}];",
                  javascript_serialize_internal(nv1, types[1]),
                  javascript_serialize_internal(nv2, types[2]),
                  :deindent,
                  "}"
                 ]
        else
          raise "Missing serialization for #{var}"
        end
      else
        if $all_structs[types]
          "#{var}.serialize_internal(out)"
      
        elsif $available_types[types] && $available_types[types].ancestors.include?(SimpleDefinition)
          "this.write_#{types}(#{var}, out)"
      
        else
          raise "Missing code generation case #{types}"
        end
      end
    end

##
#  Generate the way of deserializing different DSL types
#  * *Args*    :
#   - +var+   -> variable name
#   - +types+ -> variable type

    def javascript_deserialize_internal(var, types)
      if types.respond_to? :first
        case types.first
        when :list
          count = get_fresh_variable_name
          nv = get_fresh_variable_name
          iter = get_fresh_variable_name
          return [
                  "#{"var " unless var.include? "this."}#{var} = [];",
                  "var #{count} = this.read_dint63(data);",
                  "for(var #{iter}=0; #{iter}<#{count}; #{iter}++) {",
                  :indent,
                  javascript_deserialize_internal(nv, types[1]),
                  "#{var}.push(#{nv});",
                  :deindent,
                  "}"
                 ]
        when :map
          count = get_fresh_variable_name
          nv1 = get_fresh_variable_name      
          nv2 = get_fresh_variable_name
          iter = get_fresh_variable_name
          return ["#{"var " unless var.include? "this."}#{var} = {};",
                  "var #{count} = this.read_dint63(data);",
                  "for(var #{iter}=0; #{iter}<#{count}; #{iter}++) {",
                  :indent,
                  javascript_deserialize_internal(nv1, types[1]),
                  javascript_deserialize_internal(nv2, types[2]),
                  "#{var}[#{nv1}] = #{nv2};",
                  :deindent,
                  "}"
                 ]
        else
          raise "Missing serialization for #{var}"
        end
      else
        case types
        when :map
          "#{"var " unless var.include? "this."}#{var} = {}"
        when :list
          "#{"var " unless var.include? "this."}#{var} = []"
        else
          if $all_structs.key? types
            [
             "#{"var " unless var.include? "this."}#{var} = new #{types}();",
             "#{var}.deserialize(data);"
            ]
          else
            "#{"var " unless var.include? "this."}#{var} = this.read_#{types}(data);"
          end
        end
      end
    end
  end
    

##
# Responsible for generating Divine and structs functions
#

  class JavascriptGenerator < JavascriptHelperMethods

##
# Generate JS Functions
# * *Args*    :
#   - +structs+ -> Dictionary of structs
#   - +opts+    -> Dictionary that contains generation params [file, debug, parent_class, target_dir]

    def generate_code(structs, opts)
      $debug_javascript = true if opts[:debug]
      base_template = Erubis::Eruby.new(javascript_base_class_template_str)
      keys = structs.keys.sort
      src = keys.map do |k|
        ss = structs[k]
        # Check different aspects the the structs
        vss = sanity_check(ss)
        javascript_class_template(StructHandler.new(vss))
      end
    
      # User defined super class?
      toplevel = opts[:parent_class] || nil
      toplevel = " < #{toplevel}" if toplevel 
      return [{file: opts[:file], src: "#{javascript_get_begin_module(opts)}#{base_template.result({ toplevel_class: toplevel })}\n\n#{src.join("\n\n")}#{javascript_get_end_module(opts)}"}]
    end

    #
    # Build Header Comments
    #
    def javascript_get_begin_module(opts)
       "#{get_header_comment}\n\n"
    end

    # Do nothing
    def javascript_get_end_module(opts)
      nil
    end
  end


  $language_generators[:javascript] = JavascriptGenerator.new
end
