// ------------------------------------------------------------ BabelDataReader
function BabelDataReader(data) {
    this.data = data;
    this.index = 0;
}

BabelDataReader.prototype.getbyte = function () {
    return this.data[this.index++];
};

BabelDataReader.prototype.read = function (items) {
    var from = this.index;
    this.index += items
    return this.data.subarray(from, this.index)
};


// ------------------------------------------------------------ BabelDataWriter
function BabelDataWriter(data) {
    this.data = data;
    this.index = 0;
    this.data = new Uint8Array(4096);
}

BabelDataWriter.prototype._realloc = function (size) {
    size = size || 4096;
    var old_data = this.data;
    this.data = new Uint8Array(Math.max(size, 4096) + this.data.length);
    this.data.set(old_data, 0);
};

BabelDataWriter.prototype.writeByte = function (a_byte) {
    if (this.index + 1 >= this.data.length) this._realloc();
    this.data[this.index++] = a_byte;
};

BabelDataWriter.prototype.write = function (bytes) {
    if (this.index + bytes.length >= this.data.length) this._realloc(bytes.length);
    this.data.set(bytes, this.index);
    this.index += bytes.length;
};

BabelDataWriter.prototype.get_data = function () {
    return this.data.subarray(0, this.index);
};


// ------------------------------------------------------------ BabelHelper
function BabelHelper() {}

BabelHelper.prototype.serialize = function () {
    var out = new BabelDataWriter();
    this.serialize_internal(out);
    return out.get_data();
}

BabelHelper.prototype.read_int8 = function (data) {
    return data.getbyte();
};

BabelHelper.prototype.read_int16 = function (data) {
    return (data.getbyte() << 8) | this.read_int8(data);
};

BabelHelper.prototype.read_int24 = function (data) {
    return (data.getbyte() << 16) | this.read_int16(data);
};

BabelHelper.prototype.read_int32 = function (data) {
    // return (data.getbyte() << 24) | this.read_int24(data); // See notes about numbers above
    return (data.getbyte() * (256*256*256)) + this.read_int24(data);
};

BabelHelper.prototype.read_binary = function (data) {
    return data.read(this.read_int32(data));
};

BabelHelper.prototype.read_short_binary = function (data) {
    return data.read(this.read_int8(data));
};

BabelHelper.prototype.read_ip_number = function (data) {
    var ip_array = this.read_short_binary(data);
    if(ip_array.length == 4){
       return this.read_ipv4_number(ip_array);
    }else{
       return this.read_ipv6_number(ip_array);
    }
};

BabelHelper.prototype.read_ipv4_number = function (ip_array) {
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
BabelHelper.prototype.read_ipv6_number = function (ip_array) {
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

BabelHelper.prototype.read_string = function (data) {
    return this.decode_utf8(data.read(this.read_int16(data)))
};

BabelHelper.prototype.write_int8 = function (v, out) {
    if (v > 0xFF) // Max 255
    this.raise_error("Too large int8 number: " + v);
    out.writeByte(v);
}

BabelHelper.prototype.write_int16 = function (v, out) {
    if (v > 0xFFFF) // Max 65.535
    this.raise_error("Too large int16 number: " + v);
    this.write_int8(v >> 8 & 0xFF, out);
    this.write_int8(v & 0xFF, out);
}

BabelHelper.prototype.write_int24 = function (v, out) {
    if (v > 0xFFFFFF) // Max 16.777.215
    this.raise_error("Too large int24 number: " + v);
    this.write_int8(v >> 16 & 0xFF, out);
    this.write_int16(v & 0xFFFF, out);
}

BabelHelper.prototype.write_int32 = function (v, out) {
    if (v > 0xFFFFFFFF) // Max 4.294.967.295
    this.raise_error("Too large int32 number: " + v);
    this.write_int8(v >> 24 & 0xFF, out);
    this.write_int24(v & 0xFFFFFF, out);
}

BabelHelper.prototype.write_bool = function (v, out) {
    this.write_int8(v ? 1 : 0, out)
}

BabelHelper.prototype.write_bool = function (v, out) {
    this.write_int8(v ? 1 : 0, out)
}

BabelHelper.prototype.write_string = function (v, out) {
    var s = this.encode_utf8(v);
    if (s.length > 0xFFFF) this.raise_error("Too large string: " + s.length + " bytes");
    this.write_int16(s.length, out);
    out.write(s);
}

BabelHelper.prototype.write_binary = function (v, out) {
    if ((v instanceof Array) || (v instanceof Uint8Array)) {
        if (v.length > 0xFFFFFFFF) this.raise_error("Too large binary: " + v.length + " (" + v.constructor.name + ")");
        this.write_int32(v.length, out)
        out.write(v);
    } else if (v.constructor == String) {
        if (v.length > 0xFFFFFFFF) this.raise_error("Too large binary: " + v.length + " (" + v.constructor.name + ")");
        this.write_int32(v.length, out)
        out.write(v);
    } else if (v == null) {
        this.raise_error("Unsupported binary 'null'");
    } else {
        this.raise_error("Unsupported binary of type '" + v.constructor.name + "'");
    }
}

BabelHelper.prototype.write_16_binary = function (v, out) {
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

BabelHelper.prototype.write_short_binary = function (v, out) {
    if ((v instanceof Array) || (v instanceof Uint8Array)) {
        if (v.length > 0xFF) this.raise_error("Too large binary: " + v.length + " (" + v.constructor.name + ")");
        this.write_int8(v.length, out)
        out.write(v);
    } else if (v.constructor == String) {
        if (v.length > 0xFF) this.raise_error("Too large binary: " + v.length + " (" + v.constructor.name + ")");
        this.write_int8(v.length, out)
        out.write(v);
    } else if (v == null) {
        this.raise_error("Unsupported binary 'null'");
    } else {
        this.raise_error("Unsupported binary of type '" + v.constructor.name + "'");
    }
}

BabelHelper.prototype.write_ip_number = function (v, out) {
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

BabelHelper.prototype.write_ipv4_number = function (v, out) {
    if ((v instanceof Array) || (v instanceof Uint8Array)) {
        if (v.length != 4 && v.length != 0) this.raise_error("Unknown IP v4 number " + v);
        this.write_short_binary(v, out)
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

BabelHelper.prototype.write_ipv6_number = function (v, out) {
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
		 new BabelHelper().raise_error("Unknown IP Group number '" + t + "'");
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

BabelHelper.prototype.encode_utf8 = function (str) {
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

BabelHelper.prototype.decode_utf8 = function (utf8_data) {
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

BabelHelper.prototype.raise_error = function (msg) {
    throw "[" + this.constructor.name + "] " + msg;
}


// ------------------------------------------------------------ Entry
function Entry() {
   BabelHelper.call(this);  
}

// Inherit BabelHelper
Entry.prototype = new BabelHelper();
 
// Correct the constructor pointer because it points to BabelHelper
Entry.prototype.constructor = Entry;

// Define the methods of Entry
Entry.prototype.deserialize = function (data) {
}

Entry.prototype.serialize_internal = function(out) {
}


// ------------------------------------------------------------ TestBasic
function TestBasic() {
   BabelHelper.call(this);  
   this.i8 = 0;
   this.i16 = 0;
   this.i32 = 0;
   this.str = "";
   this.ip = "";
   this.guid = [];
}

// Inherit BabelHelper
TestBasic.prototype = new BabelHelper();
 
// Correct the constructor pointer because it points to BabelHelper
TestBasic.prototype.constructor = TestBasic;

// Define the methods of TestBasic
TestBasic.prototype.deserialize = function (data) {
   this.i8 = this.read_int8(data);
   this.i16 = this.read_int16(data);
   this.i32 = this.read_int32(data);
   this.str = this.read_string(data);
   this.ip = this.read_ip_number(data);
   this.guid = this.read_binary(data);
}

TestBasic.prototype.serialize_internal = function(out) {
   this.write_int8(this.i8, out);
   this.write_int16(this.i16, out);
   this.write_int32(this.i32, out);
   this.write_string(this.str, out);
   this.write_ip_number(this.ip, out);
   this.write_binary(this.guid, out);
}


// ------------------------------------------------------------ TestComplex
function TestComplex() {
   BabelHelper.call(this);  
   this.list1 = [];
   this.list2 = [];
   this.map1 = {};
   this.map2 = {};
}

// Inherit BabelHelper
TestComplex.prototype = new BabelHelper();
 
// Correct the constructor pointer because it points to BabelHelper
TestComplex.prototype.constructor = TestComplex;

// Define the methods of TestComplex
TestComplex.prototype.deserialize = function (data) {
    // Deserialize list 'list1'
    this.list1 = [];
    var var_100 = this.read_int32(data);
    for(var var_102=0; var_102<var_100; var_102++) {
        var var_101 = this.read_int32(data);
        this.list1.push(var_101);
    }
    // Deserialize list 'list2'
    this.list2 = [];
    var var_103 = this.read_int32(data);
    for(var var_105=0; var_105<var_103; var_105++) {
        var var_104 = this.read_int8(data);
        this.list2.push(var_104);
    }
    // Deserialize map 'map1'
    this.map1 = {};
    var var_106 = this.read_int32(data);
    for(var var_109=0; var_109<var_106; var_109++) {
        var var_107 = this.read_int8(data);
        var var_108 = this.read_int32(data);
        this.map1[var_107] = var_108;
    }
    // Deserialize map 'map2'
    this.map2 = {};
    var var_10a = this.read_int32(data);
    for(var var_10d=0; var_10d<var_10a; var_10d++) {
        var var_10b = this.read_string(data);
        var var_10c = [];
        var var_10e = this.read_int32(data);
        for(var var_110=0; var_110<var_10e; var_110++) {
            var var_10f = new Entry();
            var_10f.deserialize(data);
            var_10c.push(var_10f);
        }
        this.map2[var_10b] = var_10c;
    }
}

TestComplex.prototype.serialize_internal = function(out) {
    // Serialize list 'list1'
    this.write_int32(this.list1.length, out);
    for(var var_112=0; var_112<this.list1.length; var_112++) {
        var var_111 = this.list1[var_112];
        this.write_int32(var_111, out)
    }
    // Serialize list 'list2'
    this.write_int32(this.list2.length, out);
    for(var var_114=0; var_114<this.list2.length; var_114++) {
        var var_113 = this.list2[var_114];
        this.write_int8(var_113, out)
    }
    // Serialize map 'map1'
    var var_115 = Object.keys(this.map1).length;
    this.write_int32(var_115, out);
    for(var var_116 in this.map1) {
        var var_117 = this.map1[var_116];
        this.write_int8(var_116, out)
        this.write_int32(var_117, out)
    }
    // Serialize map 'map2'
    var var_119 = Object.keys(this.map2).length;
    this.write_int32(var_119, out);
    for(var var_11a in this.map2) {
        var var_11b = this.map2[var_11a];
        this.write_string(var_11a, out)
        this.write_int32(var_11b.length, out);
        for(var var_11e=0; var_11e<var_11b.length; var_11e++) {
            var var_11d = var_11b[var_11e];
            var_11d.serialize_internal(out)
        }
    }
}
