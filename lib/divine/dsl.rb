module Divine
  # Contains all defined structs
  $all_structs = {}

  #
  # Encapsulation basic struct information
  #
  class StructDefinition

    def initialize(owner, type, args)
      @owner = owner
      @type = type
      @args = args
    end
  
    #
    # Get struct's name
    #
    def name
      @args.first
    end

    def type
      @type
    end

    #
    # Get struct's version
    #
    def version 
      @owner.version
    end

    #
    # Represents strut as string
    #
    def to_s
      "#{@owner.name}: #{self.type} #{self.name} (#{self.class.name}, #{@args.inspect})"
    end
  end

  #
  # Encapsulation simple struct information
  #
  class SimpleDefinition < StructDefinition
    #
    # Ask if the struct is simple.
    # * +Return+ : True
    def simple?; true; end
    
    #
    # Get types used in the struct
    #
    def referenced_types
      [@type]
    end
  end

  #
  # Encapsulation complex struct information
  #
  class ComplexDefinition < StructDefinition
    #
    # Ask if the struct is simple.
    # * *Return* : False
    def simple?; false; end

    #
    # Get types used in the struct
    #
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

  #
  # Encapsulation for dynamic integer date type
  #
  class DynamicInteger63Definition < SimpleDefinition
  end

  #
  # Encapsulation for signed integer 64-bit date type
  #
  class SInteger64Definition < SimpleDefinition
  end

  #
  # Encapsulation for signed integer 32-bit date type
  #
  class SInteger32Definition < SimpleDefinition
  end 

  #
  # Encapsulation for unsigned integer 32-bit date type
  #
  class Integer32Definition < SimpleDefinition
  end

  #
  # Encapsulation for unsigned integer 24-bit
  #
  class Integer24Definition < SimpleDefinition
  end

  #
  # Encapsulation for unsigned integer 16-bit data type
  #
  class Integer16Definition < SimpleDefinition
  end

  #
  # Encapsulation for unsigned integer 8-bit data type
  #
  class Integer8Definition < SimpleDefinition
  end

  #
  # Encapsulation for binary data type
  #
  class BinaryDefinition < SimpleDefinition
  end

  #
  # Encapsulation for string data type
  #
  class StringDefinition < SimpleDefinition
  end

  #
  # Encapsulation for boolean data type
  #
  class BooleanDefinition < SimpleDefinition
  end

  #
  # Encapsulation for IP(v4 & v6) data type
  #
  class IpNumberDefinition < SimpleDefinition
  end

  #
  # Encapsulation for list data type
  #
  class ListDefinition < ComplexDefinition
    
    #
    # Return internal types contained in current list
    #
    protected
    def referenced_types_internal
      [@args[1]]
    end
  end

  #
  # Encapsulation for map[dictionary] data type
  #
  class MapDefinition < ComplexDefinition

    #
    # Return internal types contained in current map
    #
    protected
    def referenced_types_internal
      [@args[1], @args[2]]
    end
  end


  # Contains all supported data type
  $available_types = {
    dint63: DynamicInteger63Definition,
    sint64: SInteger64Definition,
    sint32: SInteger32Definition,
    int32: Integer32Definition,
    int24: Integer24Definition,
    int16: Integer16Definition,
    int8: Integer8Definition,
    binary: BinaryDefinition,
    string: StringDefinition,
    bool: BooleanDefinition,
    list: ListDefinition,
    map: MapDefinition,
    ip_number: IpNumberDefinition
  }

  #
  # Responsible for building structs 
  #
  class StructBuilder
    # Name = name of the struct
    # Version = struct version (not currently used)
    # Fields = All defined fields
    attr_reader :name, :properties, :fields

    def initialize(name, ps)
      @properties = ps
      @name = name.to_sym
      @fields = []
      unless @name == :_inline_
        $all_structs[@name] ||= []
        $all_structs[@name] << self
      end
    end

    #
    # Get the version of the struct 
    #
    def version
      if properties && properties[:version]
        properties[:version].to_i
      else
        1
      end
    rescue => e
      raise "Failed to get version number from '#{name}': #{properties.inspect}\n#{e}"
    end
    
    #
    # Is the struct freezed? I.e. no changes are allowed
    #
    def freezed?
      nil != freeze_signature
    end
    
    #
    # Get the freeze signature
    #
    def freeze_signature
      if properties && properties[:freeze]
        properties[:freeze]
      else
        nil
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

    #
    # Get named field
    #
    def get_field(name)
      fields.each do |f|
        return f if f.name == name
      end
      return nil
    end

    def list(*args, &block)
      _process(:list, *args, &block)
    end

    def map(*args, &block)
      _process(:map, *args, &block)
    end
    def dint63(*args, &block)
      _process(:dint63, *args, &block)
    end
    def sint64(*args, &block)
      _process(:sint64, *args, &block)
    end
    def sint32(*args, &block)
      _process(:sint32, *args, &block)
    end
    def int32(*args, &block)
      _process(:int32, *args, &block)
    end
    def int24(*args, &block)
      _process(:int24, *args, &block)
    end
    def int16(*args, &block)
      _process(:int16, *args, &block)
    end
    def int8(*args, &block)
      _process(:int8, *args, &block)
    end
    def binary(*args, &block)
      _process(:binary, *args, &block)
    end
    def string(*args, &block)
      _process(:string, *args, &block)
    end
    def bool(*args, &block)
      _process(:bool, *args, &block)
    end
    def ip_number(*args, &block)
      _process(:ip_number, *args, &block)
    end


    def _process(m, *args, &block)
      #puts "... #{m} #{args.inspect}"
      type = $available_types[m]
      if type
        if block_given?
          #puts ".... recursive definition"
          builder = StructBuilder.new(:_inline_, args)
          Docile.dsl_eval(builder, &block)
          args << builder
        end
        if @name == :_inline_
          # Pad the _inline_ name to anonymous inner types
          @fields << type.new(self, m, [@name] + args)
        else
          @fields << type.new(self, m, args)
        end
        #puts "... adding #{m} to #{name}, got #{fields} ..."
      else
        super.send(m, args, block)
      end
    end

    def method_missing(m, *args, &block)
      _process(m, *args, &block)
    end
  end
end
