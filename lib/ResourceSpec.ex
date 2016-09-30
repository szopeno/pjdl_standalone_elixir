defmodule ResourceSpec do
    def commonAttribs resource, st do
      Enum.reduce st.attribs, resource, fn ( {a,param}, resource ) ->
        case a.value do
            "value" -> 
                  unless resource[:type] == :variable do
                    Statement.err "Value may be specified only for variable resources", st.pos
                  end  
                  Map.merge resource, %{ :value => param }
            ".copy" -> 
                  Map.merge resource, %{ :oninstance => :copy }
            ".shared_rw" ->
                  Map.merge resource, %{ :oninstance => :shared_rw }
            ".shared_ro" ->
                  Map.merge resource, %{ :oninstance => :shared_ro }
            ".ask" ->
                  Map.merge resource, %{ :oninstance => :ask }
            "embedded" ->
                  Map.merge resource, %{ :location_type => :embedded, :location => param }
            "remote" ->
                  Map.merge resource, %{ :location_type => :remote, :location => param }
            _ ->
              Statement.err "Wrong attribute for a resource", st.pos
        end
      end
    end

    def rangeAttribs range, st do
      for {a, param} <- st.attribs do
        case a.value do
            "from" -> 
                  Map.merge range, %{ :from => :remote }
            "to" ->
                  Map.merge range, %{ :to => :remote }
            _ ->
              Statement.err "Wrong attribute for a resource", st.pos
        end
      end
    end

    def resourceName resource, st, [] do
        Statement.err "A resource should have a name", st.pos
    end

    def resourceName resource, st, names do
        [ head | rest ] = names
           
        unless rest == [] do
             Statement.err "Specify only one \"name\"", st.pos
        end
        Map.merge resource, %{ :id => head.value }
    end

    def dimensions resource, st, no_dims do
        if st.children == [] do
             Statement.err "You have to declare dimensions for a resource", st.pos
        end
        [ head | rest ] = st.children
        unless rest == [] do
             Statement.err "Statement requires only one child", st.pos
        end
        case head.key.value do
            "dimensions" ->
              infile = false
              if head.attribs != [] do 
                [ { attrib, param } | rest ] = head.attribs
                unless attrib.value == ".infile" do
                  Statement.err "Only .infile attribute allowed for dimensions", head.pos
                end
                no_dims = 0
                
                infile = true
              end

              dims = for a <- head.names do #TODO
                a.value
              end
              if length(dims) != no_dims do
                  if infile do
                    Statement.err "When attribute .infile is specified, do not specify the dimensions", head.pos
                  else
                    Statement.err "Wrong number of dimensions.", head.pos
                  end
              end
              dims = [ infile | dims ] 
              
              Map.merge resource, %{ :dimensions => dims }
            _ ->
             Statement.err "This statement can have only \"dimensions\" child", st.pos
        end
    end

    def dimensional st do
        { type, dims } = case st.key.value do
            "vector" -> {:vector, 1}
            "array"  -> {:array,  2}
            "cube"   -> {:cube,   3}
            _        -> {:error, -1}
        end
        resource = %{ :type => type, :location_type => :embedded, :location => "",
            :oninstance => :copy, :dimensions => [ 0 ] } 
          |>  resourceName( st, st.names)
          |>  commonAttribs( st ) 
          |>  dimensions( st, dims )
    end

    def noDimensional st do
        { type, dims } = case st.key.value do
            "raw" -> {:raw, 1}
            "folder"  -> {:folder,  2}
            "variable"   -> {:variable,   3}
            _        -> {:error, -1}
        end
        resource = %{ :type => type, :location_type => :embedded, :location => "",
            :oninstance => :copy } 
          |>  resourceName( st, st.names)
          |>  commonAttribs( st ) 
    end

end

