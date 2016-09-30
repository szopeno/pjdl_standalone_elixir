defmodule ScriptGroupSpec do
    require JobTemplate

    def scriptsChildren job, [] do
        IO.puts "Scripts with no instances? Are you sure you wanted this?"
        job
    end

    def scriptSpec st do
        name = Statement.ensureOneName st
        script = %{ :id => name.value, :type => :embedded, :location => "", :lang => :js  }
        Enum.reduce st.attribs, script, fn( {attrib, param }, script ) ->
           case attrib.value do
                "embedded" ->
                    Map.merge script, %{ :location => param }
                "remote" ->
                    Map.merge script, %{ :type => :remote, :location => param }
                ".cpp" ->
                    Map.merge script, %{ :lang => :cpp }
                ".js" ->
                    Map.merge script, %{ :lang => :js }
                ".ex" ->
                    Map.merge script, %{ :lang => :ex }
           end
        end
    end

    def scriptsChildren job, children do
        scripts = for sc <- children do     
                    case sc.key.value do
                      "script" ->
                          scriptSpec sc
                      _ ->
                          Statement.err "unknown keyword #{sc.value} for \"scripts\"", sc.pos
               end
         end
         job = Map.merge job, %{scripts: scripts }
    end 
end
