require 'graphviz'

module Divine

  #
  # Responsible for drawing ERD diagram corresponding to structs
  #
  class GraphGenerator

    #
    # Draw Graph for current structs on $all_structs 
    # * *Args* :
    #  -path- -> target path
    def draw(path = "", file_name = "graph", format = "jpg")
      @relations = {}
      @nodes_map = {}
      @graph = GraphViz.new( :G, :type => :digraph )
      $all_structs.keys.each do |k|
          name = "Struct: #{k}"
          content = "Temp Contents"
          simple_fields = ""
          complex_fields = ""
          $all_structs[k][0].simple_fields.each  { |f|
            simple_fields  << "#{f.name}: #{f.type}\n"
          }
          $all_structs[k][0].complex_fields.each { |f|
            type = f.referenced_types.to_s.gsub(':','').gsub("[list,", "list[").gsub("[map,", "map[").gsub(/[\s]*/, "").gsub("[", "&lt;").gsub("]", "&gt;")
            $all_structs.keys.each do |l|
              if type.include?(l.to_s)
                addRelation(l, k)
              end
            end
            complex_fields << "#{f.name}: #{type}\n"
          }
          content = simple_fields + complex_fields
          @nodes_map[k] = addNode(name, content)
      end
      
      addLinks()

      # Generate output image
      @graph.output( format.to_sym => File.join(path, "#{file_name}.#{format}") )
    end
  

    #
    # Add node to the graph
    # * *Args* :
    #  -struct_name- -> struct name
    #  -struct_content- -> struct contents "Fields"
    def addNode(struct_name, struct_content)
      @graph.add_nodes( "{ #{struct_name} | #{struct_content} }", "shape" => "record", "style" => "rounded")
    end
 

    #
    # Build links from relation map
    # 
    def addLinks()
      @relations.each_pair do |src, trgs|
        trgs.each { |trg|
          @graph.add_edges( @nodes_map[trg], @nodes_map[src] )
        }
      end
    end
    
    #
    # Add relation between nodes
    # * *Args* :
    #  -src- -> the source struct
    #  -trg- -> the target struct
    def addRelation(src, trg)
      if @relations.keys.include?(src)
        @relations[src].push(trg)
      else
        @relations[src] = [trg]
      end
    end
  end

end
