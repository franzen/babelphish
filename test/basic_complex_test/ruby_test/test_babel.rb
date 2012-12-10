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
    


  class Entry < BabelBase

      def serialize_internal(out)
        print "+"
      end

      def deserialize(data)
        print "-"
      end
  end
    


  class TestBasic < BabelBase
      attr_accessor :i8, :i16, :i32, :str, :ip, :guid

      def initialize()
          super
          @i8 ||= 0
          @i16 ||= 0
          @i32 ||= 0
          @str ||= ""
          @ip ||= ""
          @guid ||= []
      end

      def serialize_internal(out)
        print "+"
        write_int8(i8, out)
        write_int16(i16, out)
        write_int32(i32, out)
        write_string(str, out)
        write_ip_number(ip, out)
        write_binary(guid, out)
      end

      def deserialize(data)
        print "-"
        @i8 = read_int8(data)
        @i16 = read_int16(data)
        @i32 = read_int32(data)
        @str = read_string(data)
        @ip = read_ip_number(data)
        @guid = read_binary(data)
      end
  end
    


  class TestComplex < BabelBase
      attr_accessor :list1, :list2, :map1, :map2

      def initialize()
          super
          @list1 ||= []
          @list2 ||= []
          @map1 ||= {}
          @map2 ||= {}
      end

      def serialize_internal(out)
        print "+"
        # Serialize list 'list1'
      write_int32(list1.size, out)
      list1.each do |var_100|
         write_int32(var_100, out)
      end
        # Serialize list 'list2'
      write_int32(list2.size, out)
      list2.each do |var_101|
         write_int8(var_101, out)
      end
        # Serialize map 'map1'
      write_int32(map1.size, out)
      map1.each_pair do |var_102, var_103|
         write_int8(var_102, out)
         write_int32(var_103, out)
      end
        # Serialize map 'map2'
      write_int32(map2.size, out)
      map2.each_pair do |var_104, var_105|
         write_string(var_104, out)
         write_int32(var_105.size, out)
         var_105.each do |var_106|
            var_106.serialize_internal(out)
         end
      end
      end

      def deserialize(data)
        print "-"
        # Deserialize list 'list1'
      @list1 = []
      var_107 = read_int32(data)
      (1..var_107).each do
         var_108 = read_int32(data)
         @list1 << var_108
      end
        # Deserialize list 'list2'
      @list2 = []
      var_109 = read_int32(data)
      (1..var_109).each do
         var_10a = read_int8(data)
         @list2 << var_10a
      end
        # Deserialize map 'map1'
      @map1 = {}
      var_10b = read_int32(data)
      (1..var_10b).each do
         var_10c = read_int8(data)
         var_10d = read_int32(data)
         @map1[var_10c] = var_10d
      end
        # Deserialize map 'map2'
      @map2 = {}
      var_10e = read_int32(data)
      (1..var_10e).each do
         var_10f = read_string(data)
         var_110 = []
         var_111 = read_int32(data)
         (1..var_111).each do
            var_112 = Entry.new
            var_112.deserialize(data)
            var_110 << var_112
         end
         @map2[var_10f] = var_110
      end
      end
  end
    

end
