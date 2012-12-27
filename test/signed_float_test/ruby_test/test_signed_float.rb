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
     
    def read_float32(data)
      v = data.read(4) # read 4 bytes for 32-bit float number
      v.bytes.map { |byte| byte.to_i.chr }.reverse.join.unpack('f')[0].round(6)
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
      ips = read_short_binary(data)
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
      raise_error "Too large Sint32 number: #{v} , Max = #{max}" if v > max # Max  2.147.483.647
      raise_error "Too small sInt32 number: #{v} , Min = #{min}" if v < min # Min -2.147.483.648
      write_int32( v >> 32 & 0xFFFFFFFF, out)
      write_int32( v & 0xFFFFFFFF, out)
    end

    def write_float32(v, out)
      v = v.to_f
      bytes = [v].pack('f') # return each byte as hex
      write_int32( ( (bytes[3].ord << 24) | (bytes[2].ord << 16) | (bytes[1].ord << 8) | (bytes[0].ord) ), out)
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
        write_short_binary(v, out)
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
    


  class SignedFloat < BabelBase
      attr_accessor :list1

      def initialize()
          super
          @list1 ||= []
      end

      def serialize_internal(out)
        print "+"
        # Serialize list 'list1'
      write_int32(list1.size, out)
      list1.each do |var_100|
         write_float32(var_100, out)
      end
      end

      def deserialize(data)
        print "-"
        # Deserialize list 'list1'
      @list1 = []
      var_101 = read_int32(data)
      (1..var_101).each do
         var_102 = read_float32(data)
         @list1 << var_102
      end
      end
  end
    

end