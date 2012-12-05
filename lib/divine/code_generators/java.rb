module Divine

  class JavaHelperMethods < BabelHelperMethods
    def java_base_class_template_str
      <<EOS
abstract class BabelBase <%= toplevel_class %> {
	private static final Charset UTF8 = Charset.forName("UTF-8");

	public byte[] serialize() throws IOException {
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		serializeInternal(baos);
		baos.close();
		return baos.toByteArray();
	}

	abstract void serializeInternal(ByteArrayOutputStream baos) throws IOException;

	abstract void deserialize(ByteArrayInputStream baos) throws IOException;

	protected int readInt8(ByteArrayInputStream data) {
		return data.read() & 0xff;
	}

	protected int readInt16(ByteArrayInputStream data) {
		return (data.read() << 8) | readInt8(data);
	}

	protected int readInt24(ByteArrayInputStream data) {
		return (data.read() << 16) | readInt16(data);
	}

	protected long readInt32(ByteArrayInputStream data) {
		return (data.read() << 24) | readInt24(data);
	}

	protected boolean readBool(ByteArrayInputStream data) {
		return readInt8(data) == 1;
	}

	protected String readString(ByteArrayInputStream data) throws IOException {
		// Force utf8
		return new String(readBytes(readInt16(data), data), UTF8);
	}

	private byte[] readBytes(int size, ByteArrayInputStream data) throws IOException {
		byte[] bs = new byte[size];
		data.read(bs);
		return bs;
	}

	protected byte[] readBinary(ByteArrayInputStream data) throws IOException {
		long c = readInt32(data);
		if (c > Integer.MAX_VALUE) {
			throw new IndexOutOfBoundsException("Binary data to big for java");
		}
		return readBytes((int) readInt32(data), data);
	}

	protected byte[] readShortBinary(ByteArrayInputStream data) throws IOException {
		return readBytes(readInt8(data), data);
	}

	protected String readIpNumber(ByteArrayInputStream data) throws IOException {
		byte[] ips = readShortBinary(data);
		String ip = "";
		for (byte b : ips) {
			if (ip.length() > 0) {
				ip += ".";
			}
			ip += (b & 0xFF);
		}
		return ip;
	}

	protected void writeInt8(int v, ByteArrayOutputStream out) {
		if (v > 0xFF) { // Max 255
			raiseError("Too large int8 number: " + v);
		}
		out.write(v);
	}

	protected void writeInt16(int v, ByteArrayOutputStream out) {
		if (v > 0xFFFF) { // Max 65.535 
			raiseError("Too large int16 number: " + v);
		}
		writeInt8(v >> 8 & 0xFF, out);
		writeInt8(v & 0xFF, out);
	}

	protected void writeInt24(int v, ByteArrayOutputStream out) {
		if (v > 0xFFFFFF) { // Max 16.777.215
			raiseError("Too large int24 number: " + v);
		}
		writeInt8(v >> 16 & 0xFF, out);
		writeInt16(v & 0xFFFF, out);
	}

	protected void writeInt32(long v, ByteArrayOutputStream out) {
		if (v > 0xFFFFFFFF) { // Max 4.294.967.295
			raiseError("Too large int32 number: " + v);
		}
		writeInt8((int) ((v >> 24) & 0xFF), out);
		writeInt24((int) (v & 0xFFFFFF), out);
	}

	protected void writeBool(boolean v, ByteArrayOutputStream out) {
		writeInt8(v ? 1 : 0, out);
	}

	protected void writeString(String v, ByteArrayOutputStream out) throws IOException {
		byte[] bs = v.getBytes(UTF8);
		if (bs.length > 0xFFFF) {
			raiseError("Too large string: " + bs.length + " bytes");
		}
		writeInt16(bs.length, out);
		out.write(bs);
	}

	protected void writeBinary(byte[] v, ByteArrayOutputStream out) throws IOException {
		if (v.length > 0xFFFFFFFF) {
			raiseError("Too large binary: " + v.length + " bytes");
		}
		writeInt32(v.length, out);
		out.write(v);
	}

	protected void writeShortBinary(byte[] v, ByteArrayOutputStream out) throws IOException {
		if (v.length > 0xFF) {
			raiseError("Too large short_binary: " + v.length + " bytes");
		}
		writeInt8(v.length, out);
		out.write(v);
	}

	protected void writeIpNumber(String v, ByteArrayOutputStream out) throws IOException {
		String[] bs = v.split(".");
		byte[] ss = new byte[bs.length];
		for (int i = 0; i < bs.length; i++) {
			ss[i] = (byte) (Integer.parseInt(bs[i]) & 0xFF);
		}
		if (ss.length == 0 || ss.length == 4) {
			writeShortBinary(ss, out);
		} else {
			raiseError("Unknown IP v4 number " + v); // Only IPv4 for now 
		}
	}

	protected void raiseError(String msg) {
		throw new IllegalArgumentException("[" + this.getClass().getCanonicalName() + "] " + msg);
	}
}
EOS
    end

    def java_class_template_str
      <<EOS2
public class <%= c.name %> extends BabelBase {
<% unless c.fields.empty? %>
<% c.fields.each do |f| %>
	public <%= this.java_get_type_declaration(f) %> <%= f.name %> = <%= this.java_get_empty_declaration(f) %>;
<% end %>
<% end %>

	@Override
	void serializeInternal(ByteArrayOutputStream baos) throws IOException {
<% c.simple_fields.each do |f| %>
		<%= this.camelize("write", f.type) %>(this.<%= f.name %>, baos);
<% end %>
<% c.complex_fields.each do |f| %>
<%= this.java_serialize_complex f %>
<% end %>
	}

	@Override
	void deserialize(ByteArrayInputStream bais) throws IOException {
<% c.simple_fields.each do |f| %>
		this.<%= f.name %> = <%= this.camelize("read", f.type) %>(bais);
<% end %>
<% c.complex_fields.each do |f| %>
<%= this.java_deserialize_complex f %>
<% end %>
	}
}
EOS2
    end

    def java_get_empty_declaration(types, is_reference_type = false)
      if types.respond_to? :referenced_types
        java_get_empty_declaration(types.referenced_types)

      elsif types.respond_to? :first
        case types.first
        when :list
          "new #{java_get_type_declaration(types, true)}()"
        when :map
          "new #{java_get_type_declaration(types, true)}()"
        else
          raise "Missing empty declaration for #{types}"
        end

      else
        case types
        when :binary, :short_binary
          is_reference_type ? "new Byte[0]" : "new byte[0]"
        when :int8, :int16
          "0"
        when :int32
          "0L"
        when :string, :ip_number
          "\"\""
        else
          if $all_structs[types]
            types
          else
            raise "Unkown field type #{types}"
          end
        end
      end
    end
    
    def java_get_type_declaration(types, is_reference_type = false)
      if types.respond_to? :referenced_types
        java_get_type_declaration(types.referenced_types, is_reference_type)

      elsif types.respond_to? :first
        case types.first
        when :list
          subtypes = java_get_type_declaration(types[1], true)
          return "ArrayList<#{subtypes}>"
        when :map
          key_type = java_get_type_declaration(types[1], true)
          value_type = java_get_type_declaration(types[2], true)
          return "HashMap<#{key_type}, #{value_type}>"
        else
          raise "Missing serialization for #{types}"
        end

      else
        case types
        when :binary, :short_binary
          is_reference_type ? "Byte[]" : "byte[]"
        when :int8, :int16
          is_reference_type ? "Integer" : "int"
        when :int32
          is_reference_type ? "Long" : "long"
        when :string, :ip_number
          "String"
        else
          if $all_structs[types]
            types
          else
            raise "Unkown field type #{types}"
          end
        end
      end
    end
    
    def java_serialize_complex(field)
      types = field.referenced_types
      as = [
            "// Serialize #{field.type} '#{field.name}'",
            java_serialize_internal(field.name, types)
           ]
      format_src(2, 1, as, "\t")
    end

    def java_serialize_internal(var, types)
      if types.respond_to? :first
        case types.first
        when :list
          nv = get_fresh_variable_name
          idx = get_fresh_variable_name
          return [
                  "writeInt32(#{var}.size(), baos);",
                  "for(int #{idx}=0; #{idx}<#{var}.size(); #{idx}++) {",
                  :indent,
                  "#{java_get_type_declaration types[1]} #{nv} = #{var}.get(#{idx});",
                  java_serialize_internal(nv, types[1]),
                  :deindent,
                  "}"
                 ]
        when :map
          nv1 = get_fresh_variable_name      
          nv2 = get_fresh_variable_name
          return [
                  "writeInt32(#{var}.size(), baos);",
                  "for(#{java_get_type_declaration types[1]} #{nv1} : #{var}.keySet()) {",
                  :indent,
                  "#{java_get_type_declaration types[2]} #{nv2} = #{var}.get(#{nv1});",
                  java_serialize_internal(nv1, types[1]),
                  java_serialize_internal(nv2, types[2]),
                  :deindent,
                  "}"
                 ]
        else
          raise "Missing serialization for #{var}"
        end
      else
        if $all_structs[types]
          "#{var}.serializeInternal(baos);"
      
        elsif $available_types[types] && $available_types[types].ancestors.include?(SimpleDefinition)
          "#{self.camelize "write", types}(#{var}, baos);"
      
        else
          raise "Missing code generation case #{types}"
        end
      end
    end

    def java_deserialize_complex(field)
      types = field.referenced_types
      as = [
            "// Deserialize #{field.type} '#{field.name}'",
            java_deserialize_internal("this.#{field.name}", types)
           ]
      format_src(2, 1, as, "\t")
    end

    def java_deserialize_internal(var, types)
      if types.respond_to? :first
        case types.first
        when :list
          count = get_fresh_variable_name
          nv = get_fresh_variable_name
          iter = get_fresh_variable_name
          return [
                  "#{"#{java_get_type_declaration(types)} " unless var.include? "this."}#{var} = #{java_get_empty_declaration(types)};",
                  "int #{count} = (int)this.readInt32(bais);",
                  "for(int #{iter}=0; #{iter}<#{count}; #{iter}++) {",
                  :indent,
                  java_deserialize_internal(nv, types[1]),
                  "#{var}.add(#{nv});",
                  :deindent,
                  "}"
                 ]
        when :map
          count = get_fresh_variable_name
          nv1 = get_fresh_variable_name      
          nv2 = get_fresh_variable_name
          iter = get_fresh_variable_name
          return ["#{"#{java_get_type_declaration(types)} " unless var.include? "this."}#{var} = #{java_get_empty_declaration(types)};",
                  "int #{count} = (int)readInt32(bais);",
                  "for(int #{iter}=0; #{iter}<#{count}; #{iter}++) {",
                  :indent,
                  java_deserialize_internal(nv1, types[1]),
                  java_deserialize_internal(nv2, types[2]),
                  "#{var}.put(#{nv1}, #{nv2});",
                  :deindent,
                  "}"
                 ]
        else
          raise "Missing serialization for #{var}"
        end
      else
#        case types
#        when :map
#          "#{var} = #{java_get_empty_declaration(types)}"
#        when :list
#          "#{var} = #{java_get_empty_declaration(types)}"
#        else
          if $all_structs.key? types
            [
             "#{types} #{var} = new #{types}();",
             "#{var}.deserialize(bais);"
            ]
          else
            "#{"#{java_get_type_declaration(types)} " unless var.include? "this."}#{var} = #{self.camelize("read", types)}(bais);"
          end
#        end
      end
    end
  end


  class JavaGenerator < JavaHelperMethods
    def generate_code(structs, opts)
      pp opts
      $debug_java = true if opts[:debug]
      base_template = Erubis::Eruby.new(java_base_class_template_str)
      class_template = Erubis::Eruby.new(java_class_template_str)
      keys = structs.keys.sort
      src = keys.map do |k|
        ss = structs[k]
        # TODO: Should we merge different versions and deduce deprecated methods, warn for incompatible changes, etc?
        raise "Duplicate definitions of struct #{k}" if ss.size > 1
        class_template.result( c: ss.first, this: self )
      end
    
      # User defined super class?
      toplevel = opts[:parent_class] || nil
      toplevel = " extends #{toplevel}" if toplevel 
      return "#{java_get_begin_module(opts)}#{base_template.result({ toplevel_class: toplevel })}\n\n#{src.join("\n\n")}"
    end
  
    def java_get_begin_module(opts)
      if opts[:package]
        [
          "package #{opts[:package]};\n",
          "import java.io.ByteArrayInputStream;",
          "import java.io.ByteArrayOutputStream;",
          "import java.io.IOException;",
          "import java.util.ArrayList;",
          "import java.util.HashMap;",
          "import java.nio.charset.Charset;\n\n"
        ].join("\n")
      else 
        nil
      end
    end
  end

  $language_generators[:java] = JavaGenerator.new
end