module Divine

##
# * +Ruby Helper+ :
# Support base function needed to build Divine enviroment and classes corresponding to DSL structs
#
  class RubyHelperMethods < BabelHelperMethods

    #
    # Return the header comment
    #
    def get_header_comment
      get_header_comment_text.map do |s|
        "# #{s}"
      end.join("\n")
    end
    
##
# Generate the base Divine Ruby Class
# that contains the main methods:
# * serialize
# * serialize Internal
# * deserialize
# * Read Methods
# * Write Methods

    def ruby_base_class_template_str
      %q{
  class Divine<%= toplevel_class %>
    public
    def serialize
      out = []
      serialize_internal(out)
      out.flatten.pack("C*")
    end

    protected
    ### Read methods ###
    def read_int8(data)
      data.getbyte
    end

    def read_int16(data)
      (data.getbyte << 8) | read_int8(data)
    end

    def read_int24(data)
      (data.getbyte << 16) | read_int16(data)
    end

    def read_int32(data)
      (data.getbyte << 24) | read_int24(data)
    end

    def read_sint32(data)
      max = (2** (32 - 1)) - 1
      num = (data.getbyte << 24) | read_int24(data)
      if num > max
        return num - 2** 32
      end
      return num
    end

    def read_sint64(data)
      max = (2** (64 - 1)) - 1
      num = (read_int32(data) << 32) | (read_int32(data) & 0xFFFFFFFF);
      if num > max
        return num - 2** 64
      end
      return num
    end

    def read_dint63(data)
      byte = read_int8(data)
      val  = byte & 0x7F
      while (byte >> 7) == 1
        byte = read_int8(data)
        val = val << 7
        val = val | byte & 0x7F
      end
      val
    end

    def read_bool(data)
      read_int8(data) == 1
    end

    def read_string(data)
      data.read(read_dint63(data)).force_encoding('UTF-8')
    end

    def read_binary(data)
      data.read(read_dint63(data))
    end

    def read_ip_number(data)
      ips = data.read(read_int8(data))
      if ips.size == 4
        read_ipv4_number(ips)
      else
        read_ipv6_number(ips)
      end
    end

    def read_ipv4_number(ips)
      ips.bytes.to_a.join('.')
    end

    def read_ipv6_number(ips)
      ipv6 = []
      ips.bytes.each_slice(2) do |t|
        fst = t[0]
        lst = t[1]
        tmp = ""
        tmp = fst.to_s 16 if fst != 0
        if fst != 0 and lst < 10
          tmp << "0#{lst.to_s 16}"
        elsif fst != 0 and lst > 10 or fst == 0 and lst > 0
          tmp << lst.to_s(16)
        end
        ipv6.push(tmp)
      end
      ipv6.join(':').gsub(/:{2,}/, "::")
    end
    
    ### Write methods ###
    def write_int8(v, out)
      v = v.to_i
      raise_error "Too large int8 number: #{v}" if v > 0xFF  # Max 255
      raise_error "a negative number passed  to int8 number: #{v}" if v < 0
      out << v
    end

    def write_int16(v, out)
      v = v.to_i
      raise_error "Too large int16 number: #{v}" if v > 0xFFFF # Max 65.535 
      raise_error "a negative number passed  to int16 number: #{v}" if v < 0
      write_int8( v >> 8 & 0xFF, out)
      write_int8( v & 0xFF, out)
    end

    def write_int24(v, out)
      v = v.to_i
      raise_error "Too large int24 number: #{v}" if v > 0xFFFFFF # Max 16.777.215
      raise_error "a negative number passed  to int24 number: #{v}" if v < 0 # In Case added to ruby declaration
      write_int8( v >> 16 & 0xFF, out)
      write_int16( v & 0xFFFF, out)
    end

    def write_int32(v, out)
      v = v.to_i
      raise_error "Too large int32 number: #{v}" if v > 0xFFFFFFFF # Max 4.294.967.295
      raise_error "a negative number passed  to int32 number: #{v}" if v < 0
      write_int8( v >> 24 & 0xFF, out)
      write_int24( v & 0xFFFFFF, out)
    end

    def write_sint32(v, out)
      v = v.to_i
      max = (2** (32 - 1)) - 1
      min = (2** (32 - 1) ) - (2** 32)
      raise_error "Too large Sint32 number: #{v} , Max = #{max}" if v > max # Max  2.147.483.647
      raise_error "Too small sInt32 number: #{v} , Min = #{min}" if v < min # Min -2.147.483.648
      write_int8( v >> 24 & 0xFF, out)
      write_int24( v & 0xFFFFFF, out)
    end

    def write_sint64(v, out)
      v = v.to_i
      max = (2** (64 - 1)) - 1
      min = (2** (64 - 1) ) - (2** 64)
      raise_error "Too large Sint64 number: #{v} , Max = #{max}" if v > max # Max  9.223.372.036.854.775.807
      raise_error "Too small sInt64 number: #{v} , Min = #{min}" if v < min # Min -9.223.372.036.854.775.808
      write_int32( v >> 32 & 0xFFFFFFFF, out)
      write_int32( v & 0xFFFFFFFF, out)
    end

    def write_dint63(v, out)
      v = v.to_i
      max = (2** (64 - 1)) - 1
      min = 0
      raise_error "Too large Dynamic int63 number: #{v} , Max = #{max}" if v > max # Max  9.223.372.036.854.775.807
      raise_error "Too small Dynamic int63 number: #{v} , Min = #{min}" if v < min # Min  0
      
      bytes = v.to_s(2).reverse.split(/([01]{7})/).reject{ |t| t == ""}.each_with_index.map{ |t, i| t = t + "0"*(7-t.length) + [i,1].min.to_s}
      bytes.reverse.map{ |t| 
                          val = t.reverse.to_i 2
                          write_int8(val, out)
                       }
    end

    def write_bool(v, out)
      write_int8(v ? 1 : 0, out)
    end

    def write_string(v, out)
      s = force_to_utf8_string(v)
      raise_error "Too large string: #{s.bytesize} bytes" if s.bytesize > 0xFFFF
      write_dint63(s.bytesize, out)
      out << s.bytes.to_a
    end

    def write_binary(v, out)
      if v.is_a?(Array)
        raise_error "Too large binary: #{v.size} (#{v.class.name})" unless v.size < 0xFFFFFFFF 
        write_dint63(v.size, out)
        v.each do |x|
          write_int8(x, out)
        end
      elsif v.is_a?(String)
        raise_error "Too large binary: #{v.size} (#{v.class.name})" unless v.size < 0xFFFFFFFF 
        write_dint63(v.size, out)
        out << v.bytes.to_a
      else 
        raise_error "Unsupported binary 'nil'" if v == nil
        raise_error "Unsupported binary of type '#{v.class.name}'"
      end
    end

    def write_16_binary(v, out)
      if v.is_a?(Array)
        raise_error "Too large 16 binary: #{v.size} (#{v.class.name})" unless v.size*2 < 0xFF
        write_int8(v.size * 2, out) # IPv6 consists of 8 parts each of them has zise of 2 bytes
        v.each do |x|
          write_int16(x, out)
        end
      else 
        raise_error "Unsupported binary 'nil'" if v == nil
        raise_error "Unsupported binary of type '#{v.class.name}'"
      end
    end

    def write_ip_number(v, out)
      if v.is_a?(Array)
        if v.size == 4
          write_ipv4_number(v, out);
        else
          write_ipv6_number(v, out);
        end
      elsif v.is_a?(String)
        if v.include?":"
          write_ipv6_number(v, out);
        else
          write_ipv4_number(v, out);
        end
      else
        raise_error "Unknown IP number '#{v}'"
      end
    end

    def write_ipv4_number(v,out)
      if v.is_a?(Array)
        raise_error "Unknown IP v4 number #{v}" unless v.size == 0 || v.size == 4 # Only IPv4 for now 
        write_int8(v.size, out)
        v.each do |x|
          write_int8(x, out)
        end
      elsif v.is_a?(String)
        ss = v.split(/\./).map do |s|
          s.to_i
        end
        write_ipv4_number(ss, out)
      else
        raise_error "Unknown IP number '#{v}'"
      end
    end

    def write_ipv6_number(v, out)
      if v.is_a?(Array)
        write_16_binary(v, out)
      elsif v.is_a?(String)
        v = v.gsub(" ","") + " " # Temporary: To avoid the split problem when we have : at the end of "v" 
        raise_error "Unknown IPv6 number #{v}" unless v.strip.empty? ||
                                                       v.strip.match(/[^:0-9a-f]+/i) == nil &&  #Should not contains numbers or letters 0-9a-f
                                                       v.strip.match(/[0-9a-f]+/i) != nil &&   #Should contains numbers or letters 0-9a-f
                                                       v.match(":{3,}") == nil && 
                                                       v.split("::").size <= 2
        ss = v.split(/:/).map do |s|
          s = s.strip
	  raise_error "Unknown IPv6 Group #{s}" unless s.size <= 4
          s.to_i 16
        end
        ss = [] if v.strip.empty?
        raise_error "Unknown IPv6 number #{v}" unless (!v.include?("::") && ss.size == 0 || ss.size == 8) || 
						       (v.include?("::") && ss.size > 2 && ss.size < 8)
	write_ipv6_number(ss, out)
      else
        raise_error "Unknown IPv6 number '#{v}'"
      end
    end

    private
    def raise_error(msg)
      raise "[#{self.class.name}] #{msg}" 
    end
    
    def force_to_utf8_string(string)
      if string.encoding != Encoding::UTF_8
        string = string.encode(Encoding::UTF_8)
      end
      return string
    end
  end
    }
    end
##
#  Generate Ruby Class that corresponding to the struct definition
#  * *Args*    :
#   - +sh+ -> Struct Name

    def ruby_class_template(sh)
      code = [
        "class #{sh.name} < Divine",
        :indent,
        "",
        
        # PROPERTIES
        if sh.field_names.size > 0
          "attr_accessor :struct_version, #{sh.field_names.map {|n| ":#{n}" }.join(', ')}"
        else
          "attr_accessor :struct_version"
        end, "",


        # INITIALIZE
        "def initialize()",
        :indent,
        "super",
        "@struct_version ||= #{sh.latest_version}",
        sh.field_names.map do |fn|
          "@#{fn} ||= #{ruby_get_empty_declaration(sh.field(fn).first)}"
        end,
        :deindent,
        "end", "",
  
        # SERiALIZE INTERNAL
        "def serialize_internal(out)",
        :indent,
        "write_int8(@struct_version, out)",
        sh.structs.map do |s|
          [
            "if @struct_version == #{s.version}",
            :indent,
            s.simple_fields.map do |f|
              "write_#{f.type}(#{f.name}, out)"
            end,
            s.complex_fields.map do |f|
              [
                "", "# Serialize #{f.type} '#{f.name}'",
                ruby_serialize_internal(f.name,  f.referenced_types)
              ]
            end,
            "return",
            :deindent,
            "end", ""
          ]
        end, "",
        "raise \"Unsupported version #\{@struct_version\} for type '#{sh.name}'\"",
        :deindent,
        "end", "",
        
        # DESERIALIZE
        "def deserialize(data)",
        :indent,
        "@struct_version = read_int8(data)",
        sh.structs.map do |s|
          [
            "if @struct_version == #{s.version}",
            :indent,
            s.simple_fields.map do |f|
                "@#{f.name} = read_#{f.type}(data)"
            end,
            s.complex_fields.map do |f|
              [
                "", "# Read #{f.type} '#{f.name}'",
                ruby_deserialize_internal("@#{f.name}",  f.referenced_types)
              ]
            end,
            "return",
            :deindent,
            "end"
          ]
        end, "",
        "raise \"Unsupported version #\{@struct_version\} for type '#{sh.name}'\"",
        :deindent,
        "end", "",
        
        
        # END OF CLASS
        :deindent,
        "end"        
        ]
      format_src(0, 3, code)
    end
##
#  Generate default Ruby data types declaration values corresponding to each DSL types:
#  * DSL Type --> Corresponding Default Ruby Value
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
#  * binary   --> []
#  * list     --> []
#  * map      --> {}

    def ruby_get_empty_declaration(field)
      case field.type
      when :list, :binary
        "[]"
      when :map
        "{}"
      when :dint63, :int8, :int16, :int32, :sint32, :sint64
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

    def ruby_serialize_internal(var, types)
      if types.respond_to? :first
        case types.first
        when :list
          nv = get_fresh_variable_name
          return [
                  "write_dint63(#{var}.size, out)",
                  "#{var}.each do |#{nv}|",
                  :indent,
                  ruby_serialize_internal(nv, types[1]),
                  :deindent,
                  "end"
                 ]
        when :map
          nv1 = get_fresh_variable_name      
          nv2 = get_fresh_variable_name
          return [
                  "write_dint63(#{var}.size, out)",
                  "#{var}.each_pair do |#{nv1}, #{nv2}|",
                  :indent,
                  ruby_serialize_internal(nv1, types[1]),
                  ruby_serialize_internal(nv2, types[2]),
                  :deindent,
                  "end"
                 ]
        else
          raise "Missing serialization for #{var}"
        end
      else
        if $all_structs[types]
          "#{var}.serialize_internal(out)"
      
        elsif $available_types[types] && $available_types[types].ancestors.include?(SimpleDefinition)
          "write_#{types}(#{var}, out)"
      
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

    def ruby_deserialize_internal(var, types)
      if types.respond_to? :first
        case types.first
        when :list
          count = get_fresh_variable_name
          nv = get_fresh_variable_name
          return [
                  "#{var} = []",
                  "#{count} = read_dint63(data)",
                  "(1..#{count}).each do",
                  :indent,
                  ruby_deserialize_internal(nv, types[1]),
                  "#{var} << #{nv}",
                  :deindent,
                  "end"
                 ]
        when :map
          count = get_fresh_variable_name
          nv1 = get_fresh_variable_name      
          nv2 = get_fresh_variable_name
          return ["#{var} = {}",
                  "#{count} = read_dint63(data)",
                  "(1..#{count}).each do",
                  :indent,
                  ruby_deserialize_internal(nv1, types[1]),
                  ruby_deserialize_internal(nv2, types[2]),
                  "#{var}[#{nv1}] = #{nv2}",
                  :deindent,
                  "end"
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
             "#{var} = #{types}.new",
             "#{var}.deserialize(data)"
            ]
          else
            "#{var} = read_#{types}(data)"
          end
        end
      end
    end
  end
    

##
# Responsible for generating Divine and structs classes
#
  class RubyGenerator < RubyHelperMethods
    @debug = true
##
# Generate Ruby class(es)
# * *Args*    :
#   - +structs+ -> Dictionary of structs
#   - +opts+    -> Dictionary that contains generation params [file, module, parent_class, target_dir]

    def generate_code(structs, opts)
      base_template = Erubis::Eruby.new(ruby_base_class_template_str)
      keys = structs.keys.sort
      src = keys.map do |k|
        ss = structs[k]
        # Check different aspects the the structs
        vss = sanity_check(ss)
        ruby_class_template(StructHandler.new(vss))
      end
    
      # User defined super class?
      toplevel = opts[:parent_class] || nil
      toplevel = " < #{toplevel}" if toplevel 
      return [{file: opts[:file], src: "#{get_header_comment}\n#{ruby_get_begin_module(opts)}#{base_template.result({ toplevel_class: toplevel, this: self })}\n\n#{src.join("\n\n")}#{ruby_get_end_module(opts)}"}]
    end
  
##
# Build module name
# * *Args*    :
#   - +opts+ -> Dictionary contains module name in key module

    def ruby_get_begin_module(opts)
      if opts[:module]
        "module #{opts[:module]}\n\n"
      else 
        nil
      end
    end
##
# Ending the module
    def ruby_get_end_module(opts)
      if opts[:module]
        "\n\nend\n"
      else
        nil
      end
    end
  end


  $language_generators[:ruby] = RubyGenerator.new
end
