
module Divine
  $language_generators = {}
  
  class BabelHelperMethods
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
    
    def get_fresh_variable_name
      @vindex = (@vindex || 0xFF) + 1
      return "var_#{@vindex.to_s(16)}"
    end
    
    def camelize(*str)
      ss = str.map(&:to_s).join("_").split(/_/).flatten
      "#{ss.first.downcase}#{ss[1..-1].map(&:downcase).map(&:capitalize).join}"
    end
  end
  
  class CodeGenerator
    def generate(target, opts)
      gen = $language_generators[target.to_sym]
      raise "Unknown taget language: #{target}" unless gen
      puts "Generating code for #{target}"
      src = gen.generate_code($all_structs, opts)
      target_dir = getTargetDir(opts[:target_dir])

      puts opts[:package]
      if opts[:package]
        require 'fileutils'
        path = target_dir + opts[:package].gsub(/\./, "/")
        FileUtils.mkdir_p(path) unless File.exists?(path)
        for cls in src
           file_name = path+"/"+cls[:file]
           writeFile(file_name, cls[:src])
        end
      elsif opts[:file]
        path = target_dir + opts[:file]
        writeFile(path, src[0][:src])
      else
        puts src
      end
    end

    def getTargetDir(dir)
      # check if the path is relative or absolute if exist
      if dir && File.directory?(dir)
        return dir + "/"
      elsif dir && File.directory?(Dir.pwd + "/" + dir)
        return Dir.pwd + dir + "/"
      end
      return Dir.pwd
    end
    
    def writeFile(path, content)
      File.open(path, 'w+') do |f|
        puts "... writing #{path}"
        f.write(content)
      end
    end
  end
end
