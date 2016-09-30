defmodule MyApp do
    def intoMst file do # for tests inside iex -S mix
        {result , contents } = File.read( file )
        {result, list } = MyLex.lex( contents ) 
        { main_statement, _ } = MyParse.parse( list )
        main_statement
    end

    def parse file do # for tests inside iex -S mix
        {result , contents } = File.read( file )
        {result, list } = MyLex.lex( contents ) 
        { main_statement, _ } = MyParse.parse( list )
        JobSpec.main main_statement
    end

    def main (args) do
        [ file | _ ] = args
        {result , contents } = File.read( file )
        {result, list } = MyLex.lex( contents ) 
        #for a <- list do
        #    %LexLuthor.Token{column: c, indent: indent, \
        #            line: line, name: name, pos: p, value: value} = a
        #    IO.puts "TOKEN #{line}:#{c}:#{p} #{name} #{value} #{indent}"
        #end
        { main_statement, _ } = MyParse.parse( list )
        #Statement.printStatements main_statement
        JobSpec.main( main_statement.key.value, main_statement )
    end
end
