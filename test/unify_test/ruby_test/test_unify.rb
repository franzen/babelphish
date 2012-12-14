module BabelTest


  class BabelBase < Object
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

    def read_ip_number(data)
      read_short_binary(data).bytes.to_a.join('.')
    end

    ### Write methods ###
    def write_int8(v, out)
      v = v.to_i
      raise_error "Too large int8 number: #{v}" if v > 0xFF  # Max 255
      out << v
    end

    def write_int16(v, out)
      v = v.to_i
      raise_error "Too large int16 number: #{v}" if v > 0xFFFF # Max 65.535 
      write_int8( v >> 8 & 0xFF, out)
      write_int8( v & 0xFF, out)
    end

    def write_int24(v, out)
      v = v.to_i
      raise_error "Too large int24 number: #{v}" if v > 0xFFFFFF # Max 16.777.215
      write_int8( v >> 16 & 0xFF, out)
      write_int16( v & 0xFFFF, out)
    end

    def write_int32(v, out)
      v = v.to_i
      raise_error "Too large int32 number: #{v}" if v > 0xFFFFFFFF # Max 4.294.967.295
      write_int8( v >> 24 & 0xFF, out)
      write_int24( v & 0xFFFFFF, out)
    end

    def write_bool(v, out)
      write_int8(v ? 1 : 0, out)
    end

    def write_string(v, out)
      s = force_to_utf8_string(v)
      raise_error "Too large string: #{s.bytesize} bytes" if s.bytesize > 0xFFFF
      write_int16(s.bytesize, out)
      out << s.bytes.to_a
    end

    def write_binary(v, out)
      if v.is_a?(Array)
        raise_error "Too large binary: #{v.size} (#{v.class.name})" unless v.size < 0xFFFFFFFF 
        write_int32(v.size, out)
        v.each do |x|
          write_int8(x, out)
        end
      elsif v.is_a?(String)
        raise_error "Too large binary: #{v.size} (#{v.class.name})" unless v.size < 0xFFFFFFFF 
        write_int32(v.size, out)
        out << v.bytes.to_a
      else 
        raise_error "Unsupported binary 'nil'" if v == nil
        raise_error "Unsupported binary of type '#{v.class.name}'"
      end
    end

    def write_short_binary(v, out)
      if v.is_a?(Array)
        raise_error "Too large short_binary: #{v.size} (#{v.class.name})" unless v.size < 0xFF
        write_int8(v.size, out)
        v.each do |x|
          write_int8(x, out)
        end
      elsif v.is_a?(String)
        raise_error "To large short_binary: #{v.size} (#{v.class.name})" unless v.size < 0xFF
        write_int8(v.size, out)
        out << v.bytes.to_a
      else 
        raise_error "Unsupported binary 'nil'" if v == nil
        raise_error "Unsupported binary of type '#{v.class.name}'"
      end
    end

    def write_ip_number(v, out)
      if v.is_a?(Array)
        raise_error "Unknown IP v4 number #{v}" unless v.size == 0 || v.size == 4 # Only IPv4 for now 
        write_short_binary(v, out)
      elsif v.is_a?(String)
        ss = v.split(/\./).map do |s|
          s.to_i
        end
        write_ip_number(ss, out)
      else
        raise_error "Unknown IP number '#{v}'"
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
    


  class UnifySer < BabelBase
      attr_accessor :str, :map1

      def initialize()
          super
          @str ||= ""
          @map1 ||= {}
      end

      def serialize_internal(out)
        print "+"
        write_string(str, out)
        # Serialize map 'map1'
      write_int32(map1.size, out)
      map1.each_pair do |var_100, var_101|
         write_int8(var_100, out)
         write_int32(var_101, out)
      end
      end

      def deserialize(data)
        print "-"
        @str = read_string(data)
        # Deserialize map 'map1'
      @map1 = {}
      var_102 = read_int32(data)
      (1..var_102).each do
         var_103 = read_int8(data)
         var_104 = read_int32(data)
         @map1[var_103] = var_104
      end
      end
  end
    

end
