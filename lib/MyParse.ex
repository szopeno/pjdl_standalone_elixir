defmodule MyParse do
 
    #def getStatement( first, list ) when first.name == :key do
    #end

    def getNames [ ] do
        nil # { [], [], [] }
    end
    
    def getNames list do
        [ head | rest ] = list
        #IO.puts "--#{head.value} is #{head.indent} (name #{head.name})"
        
        case head.name do
            :number -> 
                { names, attribs, rest } = getNames rest
                names = [ head ] ++ names
                { names, attribs, rest }
            :name -> 
                { names, attribs, rest } = getNames rest
                names = [ head ] ++ names
                { names, attribs, rest }
            :attrib -> 
                [ param | rest_list ] = rest                 
                { param_value, rest } = case param.name do
                    :number -> 
                        { param.value, rest_list }
                    :name -> 
                        { param.value, rest_list }
                    _ -> 
                        { nil, rest }
                end
                IO.puts "attrib #{head.value}= <#{param_value}>"
                { names, attribs, rest } = getNames rest
                attribs = [ { head, param_value } ] ++ attribs
                #names = [ head ] ++ names
                { names, attribs, rest }
            :indent ->
                { names, attribs, rest } = getNames rest
            :key -> # impossible
                throw :error
            :newline ->
                { [], [], rest }
        end
    end


    def parse list do
        parse list, 0
    end

    def getChildren [] do
        { [], [] }
    end

    def getChildren [], _indent do
        { [], []}
    end
    
    def getChildren list, indent do
        [ head | rest ] = list
        IO.puts "--:#{head.value}: is #{head.indent} (parent #{indent})"
        
        myindent = head.indent
        case head.name do
            :newline ->
                getChildren rest, indent
            :key when myindent > indent ->
                { statement, rest } = parse list
              #IO.puts "--#{head.value} #{indent} C--"
                { children, rest } = getChildren rest, indent
                { [ statement  ] ++ children, rest}
             _ -> 
                #IO.puts "#{head.value} NOT HERE #{myindent} <= #{indent}!"
                { [], list }
        end
    end

    def parse [], _indent  do
    end

    def parse( list, indent )  do
         
        [ head | rest ] = list
        
        case head.name do
            :newline ->
                #IO.puts "ignoring #{head.value} indent #{head.indent} PARSE"
                parse rest, indent
            :key -> 
                #IO.puts "#{head.value} indent #{head.indent} PARSE"
                { names, attribs, rest } = getNames rest
                { children, rest } = getChildren rest, head.indent
        #       IO.puts "#{head.value} indent #{head.indent} END PARSE"
        # TODO: zamienić na tuple??
        #        { { head.value, names, attribs, children }, rest }

                { %Statement{ key: head, names: names, attribs: attribs, children: children, pos: {head.line, head.column} }, rest }
            :error -> 
              IO.puts "parser error: throw #{head.value}"
                      throw :error
            _ -> 
              IO.puts "parser error: throw #{head.value}"
                      throw :error

        end
    end
end
