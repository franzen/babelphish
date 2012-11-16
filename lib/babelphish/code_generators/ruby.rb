$ruby_base_class_template_str = %q{
class BabelBase<%= toplevel_class %>
  public
  def serialize
    out = []
    serialize_internal(out)
    @data = out.flatten.pack("C*")
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

  def read_bool(data)
    read_int8(data) == 1
  end

  def read_string(data)
    data.read(read_int16(data)).force_encoding('UTF-8')
  end

  def read_binary(data)
    data.read(read_int32(data))
  end

  def read_short_binary(data)
    data.read(read_int8(data))
  end

  def read_ipnumber(data)
    read_short_binary(data).bytes.to_a.join('.')
  end

  ### Write methods ###
  def write_int8(v, out)
    v = v.to_i
    raise "To large int8 number: #{v}, for struct '#{self.class.name}'" if v > 0xFF  # Max 255
    out << v
  end

  def write_int16(v, out)
    v = v.to_i
    raise "To large int16 number: #{v}, for struct '#{self.class.name}'" if v > 0xFFFF # Max 65.535 
    write_int8( v >> 8 & 0xFF, out)
    write_int8( v & 0xFF, out)
  end

  def write_int24(v, out)
    v = v.to_i
    raise "To large int24 number: #{v}, for struct '#{self.class.name}'" if v > 0xFFFFFF # Max 16.777.215
    write_int8( v >> 16 & 0xFF, out)
    write_int16( v & 0xFFFF, out)
  end

  def write_int32(v, out)
    v = v.to_i
    raise "To large int32 number: #{v}, for struct '#{self.class.name}'" if v > 0xFFFFFFFF # Max 4.294.967.295
    write_int8( v >> 24 & 0xFF, out)
    write_int24( v & 0xFFFFFF, out)
  end

  def write_bool(v, out)
    write_int8(v ? 1 : 0, out)
  end

  def write_string(v, out)
    s = force_to_utf8_string(v)
    raise "To long string: #{s.bytesize} bytes for struct '#{self.class.name}'" if s.bytesize > 0xFFFF
    write_int16(s.bytesize, out)
    out << s.bytes.to_a
  end

  def write_binary(v, out)
    if v.is_a?(Array)
      raise "To large binary: #{v.size} (#{v.class.name}) for struct '#{self.class.name}'" unless v.size < 0xFFFFFFFF 
      write_int32(v.size, out)
      v.each do |x|
        write_int8(x, out)
      end
    elsif v.is_a?(String)
      raise "To large binary: #{v.size} (#{v.class.name}) for struct '#{self.class.name}'" unless v.size < 0xFFFFFFFF 
      write_int32(v.size, out)
      out << v.bytes.to_a
    else 
      raise "Unsupported binary 'nil' for struct '#{self.class.name}'" if v == nil
      raise "Unsupported binary of type '#{v.class.name}' for struct '#{self.class.name}'"
    end
  end

  def write_short_binary(v, out)
    if v.is_a?(Array)
      raise "To large short_binary: #{v.size} (#{v.class.name}) for struct '#{self.class.name}'" unless v.size < 0xFF
      write_int8(v.size, out)
      v.each do |x|
        write_int8(x, out)
      end
    elsif v.is_a?(String)
      raise "To large short_binary: #{v.size} (#{v.class.name}) for struct '#{self.class.name}'" unless v.size < 0xFF
      write_int8(v.size, out)
      out << v.bytes.to_a
    else 
      raise "Unsupported binary 'nil' for struct '#{self.class.name}'" if v == nil
      raise "Unsupported binary of type '#{v.class.name}' for struct '#{self.class.name}'"
    end
  end

  def write_ipnumber(v, out)
    if v.is_a?(Array)
      raise "Unknown IP v4 number #{v} for struct '#{self.class.name}'" unless v.size == 4 # Only IPv4 for now 
      write_short_binary(v, out)
    elsif v.is_a?(String)
      ss = v.split(/\./).map do |s|
        s.to_i
      end
      write_ipnumber(ss, out)
    else
      raise "Unknown IP number '#{v}' for struct '#{self.class.name}'"
    end
  end

  private
  def force_to_utf8_string(string)
    if string.encoding != Encoding::UTF_8
      string = string.encode(Encoding::UTF_8)
    end
    return string
  end
end
}

# Create template
$ruby_class_template_str = %q{
class <%= c.name %> < BabelBase
<% unless c.fields.empty? %>
    attr_accessor <%= c.fields.map { |x| ":#{x.name}" }.join(', ') %>

    def initialize()
        super
<% c.complex_fields.each do |f| %>
        @<%= f.name %> ||= <%= ruby_get_empty_declaration(f) %>
<% end %>
    end
<% end %>

    def serialize_internal(out)
      print "+"
      <% c.simple_fields.each do |f| %>
      write_<%= f.type %>(<%= f.name %>, out)
      <% end %>
      <% c.complex_fields.each do |f| %>
<%= ruby_serialize_complex f %>
      <% end %>
    end

    def deserialize(data)
      print "-"
      <% c.simple_fields.each do |f| %>
      @<%= f.name %> = read_<%= f.type %>(data)
      <% end %>
      <% c.complex_fields.each do |f| %>
<%= ruby_deserialize_complex f %>
      <% end %>
    end
end
}

def ruby_get_empty_declaration(field)
  case field.type
  when :list
    "[]"
  when :map
    "{}"
  else
    raise "Unkown field type #{field.type}"
  end
end

def get_fresh_variable_name
  @vindex = (@vindex || 0xFF) + 1
  return "var_#{@vindex.to_s(16)}"
end

def ruby_format_as_src(first_indent, following_indent, is)
  indent = "#{" " * first_indent}"
  is.flatten.map do |i|
    case i
    when :indent
      indent << " " * following_indent
      nil
    when :deindent
      indent = indent[0..-(following_indent+1)]
      nil
    else
      "#{indent}#{i}"
    end
  end.compact.join("\n")
end

def ruby_serialize_complex(field)
  types = field.referenced_types
  as = [
        "# Serialize #{field.type} '#{field.name}'",
        ruby_serialize_internal(field.name, types)
       ]
  ruby_format_as_src(6, 3, as)
end

def ruby_serialize_internal(var, types)
  if types.respond_to? :first
    case types.first
    when :list
      nv = get_fresh_variable_name
      return [
              "write_int32(#{var}.size, out)",
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
              "write_int32(#{var}.size, out)",
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

def ruby_deserialize_complex(field)
  types = field.referenced_types
  as = [
        "# Deserialize #{field.type} '#{field.name}'",
        ruby_deserialize_internal("@#{field.name}", types)
       ]
  ruby_format_as_src(6, 3, as)
end

def ruby_deserialize_internal(var, types)
  if types.respond_to? :first
    case types.first
    when :list
      count = get_fresh_variable_name
      nv = get_fresh_variable_name
      return [
              "#{var} = []",
              "#{count} = read_int32(data)",
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
              "#{count} = read_int32(data)",
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
    when :lisy
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



class RubyGenerator
  @debug = true
  
  def generate_code(structs, opts)
    pp opts
    base_template = Erubis::Eruby.new($ruby_base_class_template_str.strip)
    class_template = Erubis::Eruby.new($ruby_class_template_str.strip)
    keys = structs.keys.sort
    src = keys.map do |k|
      ss = structs[k]
      # TODO: Should we merge different versions and deduce deprecated methods, warn for incompatible changes, etc?
      raise "Duplicate definitions of struct #{k}" if ss.size > 1
      class_template.result( c: ss.first )
    end
    
    # User defined super class?
    toplevel = opts[:parent_class] || nil
    toplevel = " < #{toplevel}" if toplevel 
    return "#{ruby_get_begin_module(opts)}#{base_template.result({ toplevel_class: toplevel })}\n\n#{src.join("\n\n")}#{ruby_get_end_module(opts)}"
  end
  
  def ruby_get_begin_module(opts)
    if opts[:module]
      "module #{opts[:module]}\n\n"
    else 
      ""
    end
  end

  def ruby_get_end_module(opts)
    if opts[:module]
      "\n\nend\n"
    else
      ""
    end
  end
end


$language_generators[:ruby] = RubyGenerator.new
