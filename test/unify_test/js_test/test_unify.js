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
    if ((v instanceof Array) || (v instanceof Uint8Array)) {
        if (v.length != 4 && v.length != 0) this.raise_error("Unknown IP v4 number " + v);
        this.write_short_binary(v, out)
    } else if (v.constructor == String) {
        var ss = [];
        if (v.length > 0) {
            ss = v.split(".").map(Number);
        }
        this.write_ip_number(ss, out);
    } else {
        this.raise_error("Unknown IP number '" + v + "'");
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


// ------------------------------------------------------------ UnifySer
function UnifySer() {
   BabelHelper.call(this);  
   this.str = "";
   this.map1 = {};
}

// Inherit BabelHelper
UnifySer.prototype = new BabelHelper();
 
// Correct the constructor pointer because it points to BabelHelper
UnifySer.prototype.constructor = UnifySer;

// Define the methods of UnifySer
UnifySer.prototype.deserialize = function (data) {
   this.str = this.read_string(data);
    // Deserialize map 'map1'
    this.map1 = {};
    var var_100 = this.read_int32(data);
    for(var var_103=0; var_103<var_100; var_103++) {
        var var_101 = this.read_int8(data);
        var var_102 = this.read_int32(data);
        this.map1[var_101] = var_102;
    }
}

UnifySer.prototype.serialize_internal = function(out) {
   this.write_string(this.str, out);
    // Serialize map 'map1'
    var var_104 = Object.keys(this.map1).length;
    this.write_int32(var_104, out);
    for(var var_105 in this.map1) {
        var var_106 = this.map1[var_105];
        this.write_int8(var_105, out)
        this.write_int32(var_106, out)
    }
}
