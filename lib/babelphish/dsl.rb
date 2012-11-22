module Babelphish
  $all_structs = {}

  class StructDefinition
    def initialize(type, args)
      @type = type
      @args = args
    end
  
    def name
      @args.first
    end
  
    def type
      @type
    end
  end

  class SimpleDefinition < StructDefinition
    def simple?; true; end
    def referenced_types
      @type
    end
  end

  class ComplexDefinition < StructDefinition
    def simple?; false; end
    def referenced_types
      fs = referenced_types_internal.map do |t|
        if t.is_a? StructBuilder
          t.fields.map do |f|
            f.referenced_types
          end
        else
          t.to_sym
        end
      end
      return [type] + fs.flatten(1)
    end
  end

  class Integer32Definition < SimpleDefinition
  end

  class Integer24Definition < SimpleDefinition
  end

  class Integer16Definition < SimpleDefinition
  end

  class Integer8Definition < SimpleDefinition
  end

  class BinaryDefinition < SimpleDefinition
  end

  class ShortBinaryDefinition < SimpleDefinition # Shorted than 256 bytes
  end

  class StringDefinition < SimpleDefinition
  end

  class BooleanDefinition < SimpleDefinition
  end

  class IpNumberDefinition < SimpleDefinition
  end


  class ListDefinition < ComplexDefinition
    protected
    def referenced_types_internal
      [@args[1]]
    end
  end

  class MapDefinition < ComplexDefinition
    protected
    def referenced_types_internal
      [@args[1], @args[2]]
    end
  end



  $available_types = {
    int32: Integer32Definition,
    int24: Integer24Definition,
    int16: Integer16Definition,
    int8: Integer8Definition,
    binary: BinaryDefinition,
    short_binary: ShortBinaryDefinition,
    string: StringDefinition,
    bool: BooleanDefinition,
    list: ListDefinition,
    map: MapDefinition,
    ip_number: IpNumberDefinition
  }


  class StructBuilder
    # Name = name of the struct
    # Version = struct version (not currently used)
    # Fields = All defined fields
    attr_reader :name, :version, :fields

    def initialize(name, version)
      @version = version
      @name = name.to_sym
      @fields = []
      unless @name == :_inline_
        $all_structs[@name] ||= []
        $all_structs[@name] << self
      end
    end

    #
    # Get all simple fields, i.e. basic types like string, etc
    #
    def simple_fields
        fields.select(&:simple?)
    end

    #
    # Get all complex fields, i.e. lists and hashmaps
    #
    def complex_fields
        fields.reject(&:simple?)
    end

    def method_missing(m, *args, &block)
      puts "... #{m}"
      type = $available_types[m]
      if type
        if block_given?
          puts ".... recursive definition"
          builder = StructBuilder.new(:_inline_, version)
          Docile.dsl_eval(builder, &block)
          args << builder
        end
        if @name == :_inline_
          # Pad the _inline_ name to anonymous inner types
          @fields << type.new(m, [@name] + args)
        else
          @fields << type.new(m, args)
        end
        #puts "... adding #{m} to #{name}, got #{fields} ..."
      else
        super.send(m, args, block)
      end
    end
  end
end
