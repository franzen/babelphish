require 'pp'

module Babelphish

  class JavascriptHelperMethods < BabelHelperMethods
    def javascript_base_class_template_str
      <<EOS
function decode_to_utf8(utftext) {  
    var string = "";  
    var i = 0;  
    var c = c1 = c2 = 0;  
    
    while ( i < utftext.length ) {  
        c = utftext.charCodeAt(i);  
        if (c < 128) {  
            string += String.fromCharCode(c);  
            i++;  
        }  
        else if((c > 191) && (c < 224)) {  
            c2 = utftext.charCodeAt(i+1);  
            string += String.fromCharCode(((c & 31) << 6) | (c2 & 63));  
            i += 2;  
        }  
        else {  
            c2 = utftext.charCodeAt(i+1);  
            c3 = utftext.charCodeAt(i+2);  
            string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));  
            i += 3;  
        }  
	
    }  
    return string;
}


// ------------------------------------------------------------ BabelDataReader
function BabelDataReader(data) {
    this.data = data;
    this.index = 0;
}

BabelDataReader.prototype.getbyte = function() {
    return this.data[this.index++];
};

BabelDataReader.prototype.read = function(items) {
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

BabelDataWriter.prototype._realloc = function(size) {
   size = size || 4096;
   var old_data = this.data;
   this.data = new Uint8Array(Math.max(size, 4096) + this.data.length);
   this.data.set(old_data, 0);
};

BabelDataWriter.prototype.writeByte = function(a_byte) {
   if(this.index + 1 >= this.data.length)
      this._realloc();
   this.data[this.index++] = a_byte;
};

BabelDataWriter.prototype.write = function(bytes) {
   if(this.index + bytes.length >= this.data.length)
      this._realloc(bytes.length);
   this.data.set(bytes, this.index);
   this.index += bytes.length;
};

BabelDataWriter.prototype.get_data = function() {
    return this.data.subarray(0, this.index);
};


// ------------------------------------------------------------ BabelHelper
function BabelHelper() {}

BabelHelper.prototype.serialize = function() {
  var out = new BabelDataWriter();
  this.serialize_internal(out);
  return out.get_data();
}

BabelHelper.prototype.read_int8 = function(data) {
    return data.getbyte();
};

BabelHelper.prototype.read_int16 = function(data) {
    return (data.getbyte() << 8) | this.read_int8(data);
    //return this.read_int8(data) * 256 + this.read_int8(data);
};

BabelHelper.prototype.read_int24 = function(data) {
    return (data.getbyte() << 16) | this.read_int16(data);
    //return this.read_int16(data) * 256 + this.read_int8(data);
};

BabelHelper.prototype.read_int32 = function(data) {
    return (data.getbyte() << 24) | this.read_int24(data);
    //return this.read_int24(data) * 256 + this.read_int8(data);
};

BabelHelper.prototype.read_binary = function(data) {
    return data.read(this.read_int32(data));
};

BabelHelper.prototype.read_short_binary = function(data) {
    return data.read(this.read_int8(data));
};

BabelHelper.prototype.read_ipnumber = function(data) {
    var ip_array = this.read_short_binary();
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

BabelHelper.prototype.read_string = function(data) {
    return decode_to_utf8(data.read(this.read_int16(data)))
};

BabelHelper.prototype.read_ip = function() {
    var b, ip, ip_array, _i, _len;
    ip_array = this.data.subarray(this.index, this.index + 4);
    this.index += 4;
    ip = "";
    for (_i = 0, _len = ip_array.length; _i < _len; _i++) {
        b = ip_array[_i];
        if (ip.length > 0) {
            ip += ".";
        }
        ip += b.toString();
    }
    return ip;
};

BabelHelper.prototype.write_int8 = function(v, out) {
   if(v > 0xFF) // Max 255
      this.raise_error("Too large int8 number: " + v); 
   out.writeByte(v);
}

BabelHelper.prototype.write_int16 = function(v, out) {
   if(v > 0xFFFF) // Max 65.535
      this.raise_error("Too large int16 number: " + v); 
   this.write_int8( v >> 8 & 0xFF, out);
   this.write_int8( v & 0xFF, out);
}

BabelHelper.prototype.write_int24 = function(v, out) {
   if(v > 0xFFFFFF) // Max 16.777.215
      this.raise_error("Too large int24 number: " + v); 
   this.write_int8( v >> 16 & 0xFF, out);
   this.write_int16( v & 0xFFFF, out);
}

BabelHelper.prototype.write_int32 = function(v, out) {
   if(v > 0xFFFFFFFF) // Max 4.294.967.295
      this.raise_error("Too large int32 number: " + v); 
   this.write_int8( v >> 16 & 0xFF, out);
   this.write_int16( v & 0xFFFF, out);
}

BabelHelper.prototype.write_bool = function(v, out) {
   this.write_int8(v ? 1 : 0, out)
}

BabelHelper.prototype.write_bool = function(v, out) {
   this.write_int8(v ? 1 : 0, out)
}

BabelHelper.prototype.write_string = function(v, out) {
   var s = v; //force_to_utf8_string(v)
   if(s.length > 0xFFFF)
    this.raise_error("Too large string: " + s.length + " bytes");

   this.write_int16(s.length, out);
   out.write(s);
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
<%= c.name %>.prototype.deserialize = function(data) {
<% c.simple_fields.each do |f| %>
   this.<%= f.name %> = read_<%= f.type %>(data);
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
            javascript_serialize_internal(field.name, types)
           ]
      format_src(3, 3, as)
    end

    def javascript_serialize_internal(var, types)
      if types.respond_to? :first
        case types.first
        when :list
          nv = get_fresh_variable_name
          idx = get_fresh_variable_name
          return [
                  "this.write_int32(#{var}.size, out);",
                  "for(var #{idx}=0; #{idx}<#{var.size}; #{idx}++) {",
                  :indent,
                  "var #{nv} = #{var}[#{idx}];",
                  javascript_serialize_internal(nv, types[1]),
                  :deindent,
                  "}"
                 ]
        when :map
          nv1 = get_fresh_variable_name      
          nv2 = get_fresh_variable_name
          key = get_fresh_variable_name
          return [
                  "this.write_int32(#{var}.size, out);",
                  "for(var #{nv1} in #{var}) {",
                  :indent,
                  "var #{nv2} = this.#{var}[#{nv1}];",
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
          "this.#{var}.serialize_internal(out)"
      
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
            javascript_deserialize_internal("#{field.name}", types)
           ]
      format_src(3, 3, as)
    end

    def javascript_deserialize_internal(var, types)
      if types.respond_to? :first
        case types.first
        when :list
          count = get_fresh_variable_name
          nv = get_fresh_variable_name
          iter = get_fresh_variable_name
          return [
                  "this.#{var} = [];",
                  "var #{count} = read_int32(data);",
                  "for(var #{iter}=0; #{iter}<#{count}; #{iter}++) {",
                  :indent,
                  javascript_deserialize_internal(nv, types[1]),
                  "this.#{var}.push(#{nv});",
                  :deindent,
                  "}"
                 ]
        when :map
          count = get_fresh_variable_name
          nv1 = get_fresh_variable_name      
          nv2 = get_fresh_variable_name
          iter = get_fresh_variable_name
          return ["this.#{var} = {};",
                  "var #{count} = read_int32(data);",
                  "for(#{iter}=0; #{iter}<#{count}; #{iter}++) {",
                  :indent,
                  javascript_deserialize_internal(nv1, types[1]),
                  javascript_deserialize_internal(nv2, types[2]),
                  "this.#{var}[#{nv1}] = #{nv2};",
                  :deindent,
                  "}"
                 ]
        else
          raise "Missing serialization for #{var}"
        end
      else
        case types
        when :map
          "#{var} = {}"
        when :list
          "#{var} = []"
        else
          if $all_structs.key? types
            [
             "#{var} = new #{types}();",
             "#{var}.deserialize(data);"
            ]
          else
            "#{var} = read_#{types}(data);"
          end
        end
      end
    end
  end
    


  class JavascriptGenerator < JavascriptHelperMethods
    @debug = true
  
    def generate_code(structs, opts)
      pp opts
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
