require 'pp'

module Babelphish
  $debug_javascript = false
  
  class JavascriptHelperMethods < BabelHelperMethods
    def javascript_base_class_template_str
      <<EOS
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
    return (data.getbyte() << 24) | this.read_int24(data);
};

BabelHelper.prototype.read_binary = function (data) {
    return data.read(this.read_int32(data));
};

BabelHelper.prototype.read_short_binary = function (data) {
    return data.read(this.read_int8(data));
};

BabelHelper.prototype.read_ipnumber = function (data) {
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

BabelHelper.prototype.write_ipnumber = function (v, out) {
    if ((v instanceof Array) || (v instanceof Uint8Array)) {
        if (v.length != 4 && v.length != 0) this.raise_error("Unknown IP v4 number " + v);
        this.write_short_binary(v, out)
    } else if (v.constructor == String) {
        var ss = [];
        if (v.length > 0) {
            ss = v.split(".").map(Number);
        }
        this.write_ipnumber(ss, out);
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
EOS
    end

    def javascript_class_template_str
      <<EOS2
// ------------------------------------------------------------ <%= c.name %>
function <%= c.name %>() {
   BabelHelper.call(this);  
<% c.fields.each do |f| %>
   this.<%= f.name %> = <%= this.javascript_get_empty_declaration(f) %>;
<% end %>
}

// Inherit BabelHelper
<%= c.name %>.prototype = new BabelHelper();
 
// Correct the constructor pointer because it points to BabelHelper
<%= c.name %>.prototype.constructor = <%= c.name %>;

// Define the methods of <%= c.name %>
<%= c.name %>.prototype.deserialize = function (data) {
<% c.simple_fields.each do |f| %>
   this.<%= f.name %> = this.read_<%= f.type %>(data);
<% end %>
<% c.complex_fields.each do |f| %>
<%= this.javascript_deserialize_complex f %>
<% end %>
}

<%= c.name %>.prototype.serialize_internal = function(out) {
<% c.simple_fields.each do |f| %>
   this.write_<%= f.type %>(this.<%= f.name %>, out);
<% end %>
<% c.complex_fields.each do |f| %>
<%= this.javascript_serialize_complex f %>
<% end %>
}
EOS2
    end

    def javascript_get_empty_declaration(field)
      case field.type
      when :list, :binary, :short_binary
        "[]"
      when :map
        "{}"
      when :int8, :int16, :int32
        "0"
      when :string, :ipnumber
        "\"\""
      else
        raise "Unkown field type #{field.type}"
      end
    end

    def javascript_serialize_complex(field)
      types = field.referenced_types
      as = [
            "// Serialize #{field.type} '#{field.name}'",
            $debug_javascript ? "console.log(\"Serialize '#{field.name}'\");" : nil,
            javascript_serialize_internal("this.#{field.name}", types)
           ]
      format_src(4, 4, as)
    end

    def javascript_serialize_internal(var, types)
      if types.respond_to? :first
        case types.first
        when :list
          nv = get_fresh_variable_name
          idx = get_fresh_variable_name
          return [
                  "this.write_int32(#{var}.length, out);",
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
                  "this.write_int32(#{len}, out);",
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

    def javascript_deserialize_complex(field)
      types = field.referenced_types
      as = [
            "// Deserialize #{field.type} '#{field.name}'",
            $debug_javascript ? "console.log(\"Deserialize '#{field.name}'\");" : nil,
            javascript_deserialize_internal("this.#{field.name}", types)
           ]
      format_src(4, 4, as)
    end

    def javascript_deserialize_internal(var, types)
      if types.respond_to? :first
        case types.first
        when :list
          count = get_fresh_variable_name
          nv = get_fresh_variable_name
          iter = get_fresh_variable_name
          return [
                  "#{"var " unless var.include? "this."}#{var} = [];",
                  "var #{count} = this.read_int32(data);",
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
                  "var #{count} = this.read_int32(data);",
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
    


  class JavascriptGenerator < JavascriptHelperMethods
    def generate_code(structs, opts)
      pp opts
      $debug_javascript = true if opts[:debug]
      base_template = Erubis::Eruby.new(javascript_base_class_template_str)
      class_template = Erubis::Eruby.new(javascript_class_template_str)
      keys = structs.keys.sort
      src = keys.map do |k|
        ss = structs[k]
        # TODO: Should we merge different versions and deduce deprecated methods, warn for incompatible changes, etc?
        raise "Duplicate definitions of struct #{k}" if ss.size > 1
        class_template.result( c: ss.first, this: self )
      end
    
      # User defined super class?
      toplevel = opts[:parent_class] || nil
      toplevel = " < #{toplevel}" if toplevel 
      return "#{javascript_get_begin_module(opts)}#{base_template.result({ toplevel_class: toplevel })}\n\n#{src.join("\n\n")}#{javascript_get_end_module(opts)}"
    end
  
    def javascript_get_begin_module(opts)
      nil
    end

    def javascript_get_end_module(opts)
      nil
    end
  end


  $language_generators[:javascript] = JavascriptGenerator.new
end
