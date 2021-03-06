require 'digest/sha1'
require 'fileutils'


module Divine
  $language_generators = {}
  
  #
  # Support methods that help to get fields and fields type from structs 
  #
  class StructHandler
    # name = name of struct
    # latest_version = struct version
    # structs = defined struct
    attr_reader :name, :latest_version, :structs
    
    def initialize(structs)
      @structs = structs
      @name = structs.first.name
      @latest_version = structs.last.version
      @field_hash = structs.map(&:fields).flatten.group_by(&:name)
    end
    
    #
    # Get field of given name
    # * *Args* :
    #  - +name+ -> field's name
    def field(name)
      @field_hash[name]
    end
    
    #
    # Get all fields names
    #
    def field_names
      @field_hash.keys.sort
    end
  end
  
  #
  # Support methods needed when generating source code files
  #
  class BabelHelperMethods
    
    #
    # Handle indentation
    #
    def format_src(first_indent, following_indent, is, spc = " ")
      indent = "#{spc * first_indent}"
      is.flatten.compact.map do |i|
        case i
        when :indent
          indent << spc * following_indent
          nil
        when :deindent
          indent = indent[0..-(following_indent+1)]
          nil
        else
          "#{indent}#{i}"
        end
      end.compact.join("\n")
    end
    
    #
    # Return new variable name
    #
    def get_fresh_variable_name
      @vindex = (@vindex || 0xFF) + 1
      return "var_#{@vindex.to_s(16)}"
    end
    
    #
    # Camelize comming args
    # * *Args* :
    #  - +*str+ -> list of arguments needed to be camelized
    def camelize(*str)
      ss = str.map(&:to_s).join("_").split(/_/).flatten
      "#{ss.first.downcase}#{ss[1..-1].map(&:downcase).map(&:capitalize).join}"
    end
    
    #
    # Return Header comments for generated files
    #
    def get_header_comment_text
      return [
        "",
        "-- DO NOT EDIT THIS FILE --", "",
        "This file was generated by Divine #{Divine::VERSION} (#{Time.now.to_s})", "",
        "-- DO NOT EDIT THIS FILE --", ""
      ]
    end
    
    #
    # Sanity check the different revisions of the struct
    #
    def sanity_check(ss)
      vos = ss.sort do |x,y|
        v1,v2 = [x,y].map(&:version)
        v1 <=> v2
      end

      # Check version numbers
      unless vos.map(&:version).uniq.size == ss.size
        raise "Inconsistent version numbering for '#{ss.first.name}': #{vos.map(&:version).join(', ')}"
      end
      
      # Check that we don't have multiple variables with same name
      vos.each do |s|
        names = s.fields.group_by(&:name)
        names.each_pair do |k, v|
          raise "Multiple fields with same name '#{k}' is defined in '#{s.name}', version #{s.version}" unless v.size == 1
        end
      end
      
      # Check types between versions
      check_field_types(vos)
      
      # Check for changed definitions
      check_freezed_structs(vos)
      
      # Return them ordered by version
      vos
    end
    
    private
    #
    # Check types through all versions, we're not allowed to change the type of a variable between different versions
    #
    def check_field_types(ss)
      types = {}
      ss.each do |x|
        x.fields.each do |f|
          if types[f.name]
            unless same_type(types[f.name], x, f.name)
              raise "Cannot change the field type for struct #{x.name}.#{f.name} between version #{types[f.name].version} and #{x.version}"
            end
          else
            types[f.name] = x
          end
        end
      end
    end
    
    def same_type(t1, t2, field)
      t1.get_field(field).referenced_types == t2.get_field(field).referenced_types
    end
    
    #
    # Check if there is any strcut has changes
    # * *Args* :
    #  - +*ss+ -> list of structs
    def check_freezed_structs(ss)
      ss.each do |s|
        if s.freezed?
          sig = calculate_signature(s)
          unless sig == s.freeze_signature
            raise "Struct '#{s.name}', version #{s.version} has changed! Got signature '#{sig}', expected '#{s.freeze_signature}'"
          end
        end
      end
    end
    
    #
    # Generate signature for given struct
    # * *Args* :
    #  - +*s+ -> struct object
    def calculate_signature(s)
      str = s.fields.map do |f|
        "#{f.name}:#{f.referenced_types.inspect}"
      end.join(",")
      Digest::SHA1.hexdigest("#{s.name}:#{s.version},#{str}")
    end
  end
  
  
  #
  # Support basic methods that generate source code file(s) for target language
  #
  class CodeGenerator
    #
    # generate source code file(s)
    # * *Args* :
    #  - +tagret+ -> target language
    #  - +opts+   -> Dictionary that contains generation params [file, parent_class, target_dir, ...]
    def generate(target, opts)
      gen = $language_generators[target.to_sym]
      raise "Unknown target language: #{target}" unless gen
      puts "Generating code for #{target}"
      src = gen.generate_code($all_structs, opts)
      target_dir = (opts[:target_dir] || ".") + "/"

      if opts[:package]
        path = target_dir + opts[:package].gsub(/\./, "/")
        FileUtils.mkdir_p(path) unless File.exists?(path)
        for cls in src
           file_name = path+"/"+cls[:file]
           writeFile(file_name, cls[:src])
        end
      elsif opts[:file]
        FileUtils.mkdir_p(target_dir) unless File.exists?(target_dir)
        path = target_dir + opts[:file]
        writeFile(path, src[0][:src])
      else
        puts src
      end
    end
    
    #
    # Create file
    # * *Args* :
    #  - +path+    -> the path in which the file will be written
    #  - +content+ -> the content to be written
    def writeFile(path, content)
      File.open(path, 'w+') do |f|
        puts "... writing #{path}"
        f.write(content)
      end
    end
  end
end
