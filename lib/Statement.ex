defmodule Statement do
    #TODO wywalić i zostawić tuple, będzie chyba wygodniej obsługiwać?
    defstruct key: "", names: nil, attribs: nil , children: [], pos: { 0, 0}

    def printStatements nil do
    end

    def printStatements statement do
        IO.puts "MAIN: #{statement.key}"
        
        for a <- statement.names do
            IO.puts "name #{a.name} : #{a.value}"
        end
        for a <- statement.attribs do
            IO.puts "attribs #{a.name} : #{a.value}"
        end
        for a <- statement.children do
            IO.puts " CHILD"
            printStatements a
        end
        IO.puts "KONIEC!"
    end
    
    def err(string, {line, col}) do
        throw { :error, "Syntax error: #{string} (at #{line}, #{col})" }
    end
    
    def forbidNames st do
        unless st.names == [] do
            err "The node #{st.key.value} should have no \"names\"", st.pos
        end
    end


    def attribs [],st do
        { nil, nil }
    end

    def attribs attribs,st do
        [ attrib_tuple | rest ] = st.attribs
        unless rest == [] do
            err "The node #{st.key.value} should have at most one attributes", st.pos
        end
        attrib_tuple
    end

    def atMostOneAttrib st do
        attribs st.attribs, st
    end

    def names [],st do
        nil
    end

    def names names,st do
        [ name | rest ] = st.names
        unless rest == [] do
            err "The node #{st.key.value} should have at most one name", st.pos
        end
        name
    end

    def atMostOneName st do
        names st.names, st
    end

    def ensureOneAttrib st do
        if st.attribs == [] do
            err "The node #{st.key.value} must have at least one attrib", st.pos
        end
        [ head | rest] = st.attribs
        unless rest == [] do
            err "The node #{st.key.value} should have only one attrib", st.pos
        end
        head
    end

    def ensureOneName st do
        if st.names == [] do
            err "The node #{st.key.value} must have at least one name", st.pos
        end
        [ head | rest] = st.names
        unless rest == [] do
            err "The node #{st.key.value} should have only one name", st.pos
        end
        head
    end

    def ensureOneChild st do
        if st.children == [] do
            err "The node #{st.key.value} must have at least one child", st.pos
        end
        [ head | rest] = st.children
        unless rest == [] do
            err "The node #{st.key.value} should have only one child", st.pos
        end
        head
    end

    def ensureChildren st do
        if st.children == [] do
            err "The node #{st.key.value} must have at least one child", st.pos
        end
    end

    def forbidAttribs st do
        unless st.attribs == [] do
            err "The node #{st.key.value} should have no attributes", st.pos
        end
    end

    def forbidChildren st do
        unless st.children == [] do
            err "The node #{st.key.value} should have no children", st.pos
        end
    end

    def ensureDeclaredOnce job, st do
        if JobTemplate.declared? job, st.key.value do
            Statement.err "The #{st.key.value} should be declared only once", st.pos
        end
        Map.merge job, %{ declared: [ st.key.value | job.declared ] }
    end
end
    



