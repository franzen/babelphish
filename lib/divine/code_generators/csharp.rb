module Divine

##
# * +C# Helper+ :
# Support base function needed to build Divine enviroment and classes corresponding to DSL structs
#
  class CsharpHelperMethods < BabelHelperMethods
    
    #
    # Return the header comment
    #
    def get_header_comment
      get_header_comment_text.map do |s|
        "// #{s}"
      end.join("\n")
    end

##
# Generate the base Divine Csharp Class
# that contains the main methods:
# * serialize
# * serialize Internal
# * deserialize
# * Read Methods
# * Write Methods

    def csharp_base_class_template_str
      <<EOS
namespace divine
{
    public abstract class Divine 
    {

        public byte[] serialize()
        {
            try
            {
                MemoryStream baos = new MemoryStream();
                serializeInternal(baos);
                baos.Close();
                return baos.ToArray();
            }
            catch (System.IO.IOException ex)
            {
                throw ex;
            }
        }

        public abstract void serializeInternal(MemoryStream baos);

        public abstract void deserialize(MemoryStream baos);

        protected byte readInt8(MemoryStream data)
        {
            return (byte)(data.ReadByte() & 0xff);
        }

        protected ushort readInt16(MemoryStream data)
        {
            return (ushort)((data.ReadByte() << 8) | readInt8(data));
        }

        protected int readInt24(MemoryStream data)
        {
            return (data.ReadByte() << 16) | readInt16(data);
        }

        protected uint readInt32(MemoryStream data)
        {
            uint x = (uint)data.ReadByte() << 24;
            uint y = (uint)readInt24(data);
            return x | y;
        }

        protected int readSint32(MemoryStream data)
        {
            return (data.ReadByte() << 24) | readInt24(data);
        }

        protected long readSint64(MemoryStream data)
        {
            return ((long)readInt32(data) << 32) | (readInt32(data) & 0xFFFFFFFF);
        }

	protected long readDint63(MemoryStream data)
        {
            int b = this.readInt8(data);
            long val = b & 0x7F;
            while ((b >> 7) == 1)
            {
                b = this.readInt8(data);
                val = val << 7;
                val = val | (uint)(b & 0x7F);
            }
            return val;
        }

        protected bool readBool(MemoryStream data)
        {
            return readInt8(data) == 1;
        }

        protected String readString(MemoryStream data)
        {
            // Force utf8
            try
            {
                return System.Text.Encoding.UTF8.GetString(readBytes((int)readDint63(data), data));
            }
            catch (System.IO.IOException ex)
            {
                throw ex;
            }
        }

        private byte[] readBytes(int size, MemoryStream data)
        {
            try
            {
                byte[] bs = new byte[size];
                data.Read(bs, 0, size);
                return bs;
            }
            catch (System.IO.IOException ex)
            {
                throw ex;
            }
        }

        protected byte[] readBinary(MemoryStream data)
        {
            try
            {
                long c = readDint63(data);
                if (c > int.MaxValue)
                {
                    throw new System.IndexOutOfRangeException("Binary data to big for csharp");
                }
                return readBytes((int)c, data);
            }
            catch (System.IO.IOException ex)
            {
                throw ex;
            }
        }

        protected String readIpNumber(MemoryStream data)
        {
            try
            {
                byte[] ips = readBytes(readInt8(data), data);
                if (ips.Length == 4)
                {
                    return readIpv4Number(ips);
                }
                else
                {
                    return readIpv6Number(ips);
                }
            }
            catch (System.IO.IOException ex)
            {
                throw ex;
            }
        }

        protected String readIpv4Number(byte[] ips)
        {
            String ip = "";
            foreach (byte b in ips)
            {
                if (ip.Length > 0)
                {
                    ip += ".";
                }
                ip += (b & 0xFF);
            }
            return ip;
        }

        protected String readIpv6Number(byte[] ips)
        {
            try
            {
                String ip = "";
                int part1, part2;
                for (int i = 0; i < ips.Length; i += 2)
                {
                    part1 = ips[i] & 0xFF;
                    part2 = ips[i + 1] & 0xFF;
                    ip += part1 == 0 ? "" : part1.ToString("X");
                    ip += (part1 == 0 && part2 == 0) ? "" : (part2 < 10 && part1 != 0 ? "0" + part2.ToString("X") : part2.ToString("X"));
                    if (i < ips.Length - 2)
                    {
                        ip += ":";
                    }
                }
                ip = System.Text.RegularExpressions.Regex.Replace(ip, ":{3,}", "::");
                return ip;
            }
            catch (System.IO.IOException ex)
            {
                throw ex;
            }
        }

        protected void writeInt8(byte v, MemoryStream output)
        {
            if (v > 0xFF)
            { // Max 255
                raiseError("Too large int8 number: " + v);
            }
            else if (v < 0)
            {
                raiseError("a negative number passed  to int8 number: " + v);
            }
            output.WriteByte((byte) v);
        }

        protected void writeInt16(ushort v, MemoryStream output)
        {
            if (v > 0xFFFF)
            { // Max 65.535 
                raiseError("Too large int16 number: " + v);
            }
            else if (v < 0)
            {
                raiseError("a negative number passed  to int16 number: " + v);
            }
            writeInt8((byte)(v >> 8 & 0xFF), output);
            writeInt8((byte)(v & 0xFF), output);
        }

        protected void writeInt24(int v, MemoryStream output)
        {
            if (v > 0xFFFFFF)
            { 	// Max 16.777.215
                raiseError("Too large int24 number: " + v);
            }
            else if (v < 0)
            {	// In Case added to csharp declaration
                raiseError("a negative number passed  to int24 number: " + v);
            }
            writeInt8((byte)(v >> 16 & 0xFF), output);
            writeInt16((ushort)(v & 0xFFFF), output);
        }

        protected void writeInt32(uint v, MemoryStream output)
        {
            if (v > 0xFFFFFFFF)
            { // Max 4.294.967.295
                raiseError("Too large int32 number: " + v);
            }
            else if (v < 0)
            {
                raiseError("a negative number passed  to int32 number: " + v);
            }
            writeInt8((byte)((v >> 24) & 0xFF), output);
            writeInt24((int)(v & 0xFFFFFF), output);
        }

        protected void writeSint32(int v, MemoryStream output)
        {
            if (v > int.MaxValue)
            { 		// Max  2.147.483.647
                raiseError("Too large sInt32 number: " + v + ", Max = " + int.MaxValue);
            }
            else if (v < int.MinValue)
            { 		// Min -2.147.483.648
                raiseError("Too small sInt32 number: " + v + ", Min = " + int.MinValue);
            }
            writeInt8((byte)((v >> 24) & 0xFF), output);
            writeInt24((int)(v & 0xFFFFFF), output);
        }

	protected void writeSint64(long v, MemoryStream output) {
	    if (v > long.MaxValue ) { 			// Max  9,223,372,036,854,775,807
		raiseError("Too large sInt64 number: " + v + ", Max = " + long.MaxValue);
	    }else if(v < long.MinValue){ 		// Min -9,223,372,036,854,775,808
                raiseError("Too small sInt64 number: " + v + ", Min = " + long.MinValue);
	    }
            writeInt32((uint)((v >> 32) & 0xFFFFFFFF), output);
            writeInt32((uint)(v & 0xFFFFFFFF), output);
	}

	

	protected void writeDint63(long v, MemoryStream output)
        {
            if (v > long.MaxValue)
            { 		// Max  9,223,372,036,854,775,807
                raiseError("Too large Dynamic Int63 number: " + v + ", Max = " + long.MaxValue);
            }
            else if (v < long.MinValue)
            { 		// Min 0
                raiseError("Too small Dynamic Int63 number: " + v + ", Min = " + 0);
            }
            char[] charArray = Convert.ToString(v, 2).ToCharArray();
            Array.Reverse(charArray);
            MatchCollection matches = Regex.Matches(new String(charArray), ".{1,7}");
            for (int i = matches.Count - 1; i >= 0 ; i--)
            {
                String val = matches[i].Value;
                val += new String('0', (7 - val.Length)) + Math.Min(i, 1);
                charArray = val.ToCharArray();
                Array.Reverse(charArray);
                String str = new String(charArray);
                int t = Convert.ToInt32(str, 2);
                this.writeInt8((byte)t, output);
            }
            
        }

        protected void writeBool(bool v, MemoryStream output)
        {
            writeInt8((byte)(v ? 1 : 0), output);
        }

        protected void writeString(String v, MemoryStream output)
        {
            try
            {
                byte[] bs = System.Text.Encoding.UTF8.GetBytes (v);

                if (bs.Length > 0xFFFF)
                {
                    raiseError("Too large string: " + bs.Length + " bytes");
                }
                writeDint63((long)bs.Length, output);
                output.Write(bs, 0, bs.Length);
            }
            catch (System.IO.IOException ex)
            {
                throw ex;
            }
        }

        protected void writeBinary(byte[] v, MemoryStream output)
        {
            try
            {
                if ((uint)v.Length > 0xFFFFFFFF)
                {
                    raiseError("Too large binary: " + v.Length + " bytes");
                }
                writeDint63((long)v.Length, output);
                output.Write(v, 0, v.Length);
            }
            catch (System.IO.IOException ex)
            {
                throw ex;
            }
        }

        protected void write16Binary(int[] v, MemoryStream output)
        {
            try
            {
                if (v.Length * 2 > 0xFF)
                {
                    raiseError("Too large 16_binary: " + (v.Length * 2) + " bytes");
                }
                writeInt8((byte)(v.Length * 2), output);
                for (int i = 0; i < v.Length; i++)
                {
                    this.writeInt16((ushort)v[i], output);
                }
            }
            catch (System.IO.IOException ex)
            {
                throw ex;
            }
        }

        protected void writeIpNumber(String v, MemoryStream output)
        {
            try
            {
                if (v.Contains(":"))
                {
                    writeIpv6Number(v, output);
                }
                else
                {
                    writeIpv4Number(v, output);
                }
            }
            catch (System.IO.IOException ex)
            {
                throw ex;
            }
        }

        protected void writeIpv4Number(String v, MemoryStream output)
        {
            try
            {
                byte[] ss = new byte[0];
                if (v.Length != 0)
                {
                    String[] bs = v.Split('.');
                    ss = new byte[bs.Length];
                    for (int i = 0; i < bs.Length; i++)
                    {
                        //  TODO: check that each part is in range from 0 to 255
                        ss[i] = (byte)(int.Parse(bs[i]) & 0xFF);
                    }
                }
                if (ss.Length == 0 || ss.Length == 4)
                {
                    writeInt8((byte)ss.Length, output);
                    output.Write(ss, 0, ss.Length);
                }
                else
                {
                    raiseError("Unknown IP v4 number " + v); // Only IPv4 for now 
                }
            }
            catch (System.IO.IOException ex)
            {
                throw ex;
            }
        }

        protected void writeIpv6Number(String v, MemoryStream output)
        {
            try
            {
                v = v.Replace(" ", "");
                int[] ss = new int[0];
                bool contains_ipv6_letters = Regex.IsMatch(v.Trim().ToLower(), "[0-9a-f]+");
                bool contains_other_letters = Regex.IsMatch(v.Trim().ToLower(), "[^:0-9a-f]+");
                bool contains_more_seprators = Regex.IsMatch(v.Trim().ToLower(), ":{3,}");
                bool contains_one_shorthand = Regex.Matches(v.Trim().ToLower(), ":{2}").Count <= 1;
                // make sure of v must have only one "::" and no more than two of ":".
                // e.g. 1::1::1 & 1:::1:205
                if (v.Trim().Length != 0 && !contains_more_seprators && contains_one_shorthand && !contains_other_letters
                        && contains_ipv6_letters)
                {
                    String[] bs = v.Split(':');
                    ss = new int[bs.Length];
                    for (int i = 0; i < bs.Length; i++)
                    {
                        String s = bs[i].Trim();
                        if (s.Length <= 4)
                        { // to avoid such number 0125f
                            ss[i] = int.Parse(((s.Length == 0 ? "0" : bs[i].Trim())), System.Globalization.NumberStyles.HexNumber);
                        }
                        else
                        {
                            raiseError("Unknown IPv6 Group " + i + " which is " + s);
                        }
                    }
                }
                // Check for make sure of the size of the IP groups in case "::" is used
                // [> 2 & < 8]or not [must == 8]
                if (!contains_other_letters
                        && (!v.Contains("::") && ss.Length == 0 || ss.Length == 8)
                        || (v.Contains("::") && ss.Length > 2 && ss.Length < 8))
                {
                    write16Binary(ss, output);
                }
                else
                {
                    raiseError("Unknown IP v6 number " + v);
                }
            }
            catch (System.IO.IOException ex)
            {
                throw ex;
            }
        }

        protected void raiseError(String msg)
        {
            throw new System.InvalidOperationException("[" + GetType() + "] " + msg);
        }
    }
EOS
    end

##
#  Generate C# Class that corresponding to the struct definition
#  * *Args*    :
#   - +sh+ -> Struct Name

    def csharp_class_template(sh)
      code = [
        "public class #{sh.name} : Divine {",
        :indent,
        "",

        # PROPERTIES
      	"public int struct_version = #{sh.latest_version};",
        sh.field_names.map do |fn|
          f = sh.field(fn).last
        	"public #{csharp_get_type_declaration(f)} #{fn} = #{csharp_get_empty_declaration(f)};"
        end, "",
        

        # SERiALIZE INTERNAL
        "override",
        "public void serializeInternal(MemoryStream baos) {",
        :indent,
	"try{",
	:indent,
        "writeInt8((byte)this.struct_version, baos);",
        sh.structs.map do |s|
          [
            "if(this.struct_version == #{s.version}) {",
            :indent,
            s.simple_fields.map do |f|
              "#{camelize("write", f.type)}(this.#{f.name}, baos);"
            end,
            s.complex_fields.map do |f|
              [
                "", "// Serialize #{f.type} '#{f.name}'",
                csharp_serialize_internal("this.#{f.name}",  f.referenced_types)
              ]
            end,
            "return;",
            :deindent,
            "}", ""
          ]
        end, "",
        "throw new System.InvalidOperationException(\"Unsupported version \" + this.struct_version + \" for type '#{sh.name}'\");",
	:deindent,	
  	"}catch (System.IO.IOException ex){",
	:indent,
        "throw ex;",
	:deindent,
        "}",
	:deindent,
        "}", "",


        # DESERIALIZE
        "override",
        "public void deserialize(MemoryStream bais) {",
	:indent,
	"try{",
        :indent,
        "this.struct_version = readInt8(bais);",
        sh.structs.map do |s|
          [
            "if(this.struct_version == #{s.version}) {",
            :indent,
            s.simple_fields.map do |f|
              "this.#{f.name} = #{camelize("read", f.type)}(bais);"
            end,
            s.complex_fields.map do |f|
              [
                "", "// Read #{f.type} '#{f.name}'",
                csharp_deserialize_internal("this.#{f.name}",  f.referenced_types)
              ]
            end,
            "return;",
            :deindent,
            "}"
          ]
        end, "",
        "throw new System.InvalidOperationException(\"Unsupported version \" + this.struct_version + \" for type '#{sh.name}'\");",
        :deindent,
	"}catch (System.IO.IOException ex){",
	:indent,
        "throw ex;",
	:deindent,
        "}",
	:deindent,
        "}", "",


        # END OF CLASS
        :deindent,
        "}"
      ]
        
      format_src(3, 3, code)
    end
    
##
#  Generate default C# data types declaration values corresponding to each DSL types:
#  * DSL Type --> Corresponding Default C# Value
#  * dint63   --> 0 range -> [0 - 9,223,372,036,854,775,807]
#   * 1 byte:  range ->  [0 - 127]
#   * 2 bytes: range ->  [0 - 16,383]
#   * 3 bytes: range ->  [0 - 2,097,151]
#   * 4 bytes: range ->  [0 - 268,435,455]
#   * 5 bytes: range ->  [0 - 34,359,738,367]
#   * 6 bytes: range ->  [0 - 4,398,046,511,103]
#   * 7 bytes: range ->  [0 - 562,949,953,421,311]
#   * 8 bytes: range ->  [0 - 72,057,594,037,927,935]
#   * 9 bytes: range ->  [0 - 9,223,372,036,854,775,807]
#  * int8     --> 0 Range -> [0 - 255]
#  * int16    --> 0 Range -> [0 - 65535]
#  * int32    --> 0 Range -> [0 - 4.294.967.295]
#  * sint32   --> 0 Range -> [-2.147.483.648 - 2.147.483.647]
#  * sint64   --> 0 Range -> [-9.223.372.036.854.775.808, 9.223.372.036.854.775.807]
#  * string   --> ""
#  * ip_number--> ""
#  * binary   --> new byte[0]
#  * list     --> new List<type>()
#  * map      --> new Dictionary<keyType, valueType>()

    def csharp_get_empty_declaration(types, is_reference_type = false)
      if types.respond_to? :referenced_types
        csharp_get_empty_declaration(types.referenced_types)

      elsif types.respond_to?(:first) && types.size > 1
        case types.first
        when :list
          "new #{csharp_get_type_declaration(types, true)}()"
        when :map
          "new #{csharp_get_type_declaration(types, true)}()"
        else
          raise "Missing empty declaration for #{types}"
        end

      elsif types.respond_to?(:first) && types.size == 1
        csharp_get_empty_declaration(types.first, is_reference_type)

      else
        case types
        when :binary
          "new byte[0]"
        when :int8, :int16, :int32, :sint32, :sint64, :dint63
          "0"
        when :string, :ip_number
          "\"\""
        when :bool
          "false"
        else
          if $all_structs[types]
            types
          else
            raise "Unkown field type #{types}"
          end
        end
      end
    end
   
##
#  Generate C# data types declaration corresponding to each DSL type
#  * DSL Type --> Corresponding C# Type
#  * int8     --> byte
#  * int16    --> ushort
#  * int32    --> uint
#  * sint32   --> int
#  * sint64   --> long
#  * string   --> string
#  * ip_number--> string
#  * binary   --> byte[]
#  * list     --> List<type>
#  * map      --> Dictionary<keyType, valueType>
 
    def csharp_get_type_declaration(types, is_reference_type = false)
      if types.respond_to? :referenced_types
        csharp_get_type_declaration(types.referenced_types, is_reference_type)

      elsif types.respond_to?(:first) && types.size > 1
        case types.first
        when :list
          subtypes = csharp_get_type_declaration(types[1], true)
          return "List<#{subtypes}>"
        when :map
          key_type = csharp_get_type_declaration(types[1], true)
          value_type = csharp_get_type_declaration(types[2], true)
          return "Dictionary<#{key_type}, #{value_type}>"
        else
          raise "Missing serialization for #{types}"
        end
        
      elsif types.respond_to?(:first) && types.size == 1
        csharp_get_type_declaration(types.first, is_reference_type)

      else
        case types
        when :binary
          "byte[]"
        when :int8
      	  "byte"
      	when :int16
      	  "ushort"
      	when :int32
          "uint"
        when :sint32
      	  "int"
      	when :sint64, :dint63
          "long"
        when :string, :ip_number
          "string"
        when :bool
          "bool"
        else
          if $all_structs[types]
            types
          else
            raise "Unkown field type #{types}"
          end
        end
      end
    end
 
##
#  Generate the way of serializing different DSL types
#  * *Args*    :
#   - +var+   -> variable name
#   - +types+ -> variable type
    def csharp_serialize_internal(var, types)
      if types.respond_to? :first
        case types.first
        when :list
          nv = get_fresh_variable_name
          idx = get_fresh_variable_name
          return [
                  "writeDint63((long)#{var}.Count, baos);",
                  "for(int #{idx}=0; #{idx}<#{var}.Count; #{idx}++) {",
                  :indent,
                  "#{csharp_get_type_declaration types[1]} #{nv} = #{var}[#{idx}];",
                  csharp_serialize_internal(nv, types[1]),
                  :deindent,
                  "}"
                 ]
        when :map
          nv1 = get_fresh_variable_name      
          nv2 = get_fresh_variable_name
          return [
                  "writeDint63((long)#{var}.Count, baos);",
                  "foreach (#{csharp_get_type_declaration types[1]} #{nv1} in #{var}.Keys) {",
                  :indent,
                  "#{csharp_get_type_declaration types[2]} #{nv2} = #{var}[#{nv1}];",
                  csharp_serialize_internal(nv1, types[1]),
                  csharp_serialize_internal(nv2, types[2]),
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

##
#  Generate the way of deserializing different DSL types
#  * *Args*    :
#   - +var+   -> variable name
#   - +types+ -> variable type

    def csharp_deserialize_internal(var, types)
      if types.respond_to? :first
        case types.first
        when :list
          count = get_fresh_variable_name
          nv = get_fresh_variable_name
          iter = get_fresh_variable_name
          return [
                  "#{"#{csharp_get_type_declaration(types)} " unless var.include? "this."}#{var} = #{csharp_get_empty_declaration(types)};",
                  "uint #{count} = (uint)this.readDint63(bais);",
                  "for(int #{iter}=0; #{iter}<#{count}; #{iter}++) {",
                  :indent,
                  csharp_deserialize_internal(nv, types[1]),
                  "#{var}.Add(#{nv});",
                  :deindent,
                  "}"
                 ]
        when :map
          count = get_fresh_variable_name
          nv1 = get_fresh_variable_name      
          nv2 = get_fresh_variable_name
          iter = get_fresh_variable_name
          return ["#{"#{csharp_get_type_declaration(types)} " unless var.include? "this."}#{var} = #{csharp_get_empty_declaration(types)};",
                  "uint #{count} = (uint)readDint63(bais);",
                  "for(int #{iter}=0; #{iter}<#{count}; #{iter}++) {",
                  :indent,
                  csharp_deserialize_internal(nv1, types[1]),
                  csharp_deserialize_internal(nv2, types[2]),
                  "#{var}.Add(#{nv1}, #{nv2});",
                  :deindent,
                  "}"
                 ]
        else
          raise "Missing serialization for #{var}"
        end
      else
#        case types
#        when :map
#          "#{var} = #{csharp_get_empty_declaration(types)}"
#        when :list
#          "#{var} = #{csharp_get_empty_declaration(types)}"
#        else
          if $all_structs.key? types
            [
             "#{types} #{var} = new #{types}();",
             "#{var}.deserialize(bais);"
            ]
          else
            "#{"#{csharp_get_type_declaration(types)} " unless var.include? "this."}#{var} = #{self.camelize("read", types)}(bais);"
          end
#        end
      end
    end
  end

##
# Responsible for generating Divine and structs classes
#
  class CsharpGenerator < CsharpHelperMethods

##
# Generate csharp class(es)
# * *Args*    :
#   - +structs+ -> Dictionary of structs
#   - +opts+    -> Dictionary that contains generation params [file, debug, parent_class, target_dir]

    def generate_code(structs, opts)
      $debug_csharp = true if opts[:debug]
      base_template = Erubis::Eruby.new(csharp_base_class_template_str)
      keys = structs.keys.sort
      src = keys.map do |k|
        ss = structs[k]
        # Check different aspects the the structs
        vss = sanity_check(ss)
        csharp_class_template(StructHandler.new(vss))
      end
    
      # User defined super class?
      toplevel = opts[:parent_class] || nil
      toplevel = " : #{toplevel}" if toplevel
      
      return [{
               file: opts[:file], 
               src: "#{csharp_get_begin_module(opts)}#{base_template.result({ toplevel_class: toplevel })}\n\n#{src.join("\n\n")} }"
             }]
    end
  
##
# Build header comments and list of imports

    def csharp_get_begin_module(opts)
      str = "#{get_header_comment}\n\n"
      str << get_csharp_imports
      str << "\n\n"
      return str
    end
    
##
# Generate list of imports needed in generated C# classes
#
    def get_csharp_imports
      [
	"System",
	"System.Collections.Generic",
	"System.Text.RegularExpressions",
	"System.IO"
        ].map do |i|
          "using #{i};"
        end.join("\n") 
    end
  end

  $language_generators[:csharp] = CsharpGenerator.new
end
