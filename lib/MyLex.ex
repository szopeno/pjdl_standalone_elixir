defmodule MyLex do
    use LexLuthor

    # comments
    defrule ~r/^[ \t]*#[^\n]*/, :notfirst, fn(e) ->  # comment starting with valid statement
            #IO.puts "Comment #{e}"
            :nil end
    defrule ~r/^[ \t]*#[^\n]*/, fn(e) ->  # ignore indentation of empty lines
            #IO.puts "Comment #{e}"
            :ignore end

    # indentation
    defrule ~r/^[ \t]+/, :notfirst, fn(e) -> 
            #IO.puts "ignore indent indent"
            :ignore end
    defrule ~r/^ +/, fn(e) -> 
            #IO.puts "indent"
            { :ignore, { :add_indent, String.length(e) } } end
    defrule ~r/^\t+/, fn(e) -> 
            #IO.puts "TAB indent"
            { :ignore, { :add_indent, 8*String.length(e) } } end
    defrule ~r/^\n/, fn(_) -> 
            #IO.puts "NEWLINE"
            {:newline, "<newline>", 0} end
    defrule ~r/^\\[ \t]*\n/, fn(_) ->
            :ignore end
    defrule ~r/^\\[ \t]*\n/, :notfirst, fn(_) ->
            :ignore end
    defrule ~r/^\n/, :notfirst, fn(_) -> 
            #IO.puts "NEWLINE not first"
            {{:newline, "<newline>", 0}, nil} end
    defrule ~r/^=/, fn(e) -> { :oper, e } end
    defrule ~r/^,/, fn(e) -> { :oper, e } end

    defrule ~r/^"/, fn(_) ->  { :error, "A line should not start with \""}  end
    defrule ~r/^"/, :notfirst, fn(_) ->  
            #IO.puts "STRING STARTED"
            :QUOTED  end
    defrule ~r/^[^"]+/, :QUOTED, fn(e) -> 
            #IO.puts "NAME #{e}"
            { :name, e } end
    defrule ~r/^"/, :QUOTED, fn(_) -> 
            #IO.puts "STRING COMPLETED"
            nil end

    defrule ~r/^(-)?\d+(\.\d+)?/,:notfirst, fn(e) -> { :number, e } end
    defrule ~r/^\d+(\.\d+)?/, fn(e) -> { :error, "A line should not start with a number" } end

    defrule ~r/^[A-Za-z@_]+/, fn(e) -> 
        #IO.puts "KEYWORD #{e}"
        {{ :key, e }, :notfirst} end
    defrule ~r/^[.A-Za-z@_]+/,:notfirst, fn(e) -> 
        #IO.puts "ATTRIB notfirst #{e}"
        { :attrib, e } end
end
