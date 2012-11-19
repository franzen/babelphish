module Babelphish
  $language_generators = {}
  
  class BabelHelperMethods
    def format_src(first_indent, following_indent, is)
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
    
    def get_fresh_variable_name
      @vindex = (@vindex || 0xFF) + 1
      return "var_#{@vindex.to_s(16)}"
    end
  end
  
  class CodeGenerator
    def generate(target, opts)
      gen = $language_generators[target.to_sym]
      raise "Unknown taget language: #{target}" unless gen
      puts "Generating code for #{target}"
      src = gen.generate_code($all_structs, opts)
      if opts[:file]
        filename = opts[:file]
        File.open(filename, 'w+') do |f|
          puts "... writing #{filename}"
          f.write(src)
        end
      else
        puts src
      end
    end
  end
end