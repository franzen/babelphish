module Babelphish
  $language_generators = {}
  def generate_code(target, opts)
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