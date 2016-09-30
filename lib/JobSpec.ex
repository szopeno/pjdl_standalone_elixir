defmodule JobId do
  @chars "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnoprstuwxyz0123456789_" |> String.split("")

  def id(length) do
    Enum.reduce((1..length), [], fn (_i, acc) ->
      [Enum.random(@chars) | acc]
    end) |> Enum.join("")
  end
end

defmodule JobSpec do
    require JobTemplate
    require ResourceGroupSpec
    require Statement
    alias Statement, as: St
    def jobName [] do
    end

    def jobName job, [] do
        job
    end

    def jobName job, names do
        [ head | rest ] = names
        
        unless rest == [] do
            St.err "\"job\" should have at most one name", { head.line, head.column}
        end
        IO.puts "JOB #{job.id}"
        job = Map.merge job, %{ id: head.value }
    end

    def jobAttribs job, attribs do
        unless attribs == [] do
            throw { :error, "Job should have no \"attributes\"" }
        end
        job
    end

    def jobChildren job, children do
        Enum.reduce children, job, &(
            case &1.key.value do
                "short" -> handleShort &2, &1
                "resources" -> ResourceGroupSpec.main &2, &1
                "results_visibility" -> handleResultsVisibility &2, &1
                "results" -> handleResults &2, &1
                "instantiation" -> handleInstantiation &2, &1
                "scripts" -> handleScripts &2, &1
                "activity" -> handleActivity &2, &1
                _ -> Statement.err "An unknown child node \"#{&1.key.value}\" for \"job\"", &1.pos
            end
        )
    end

    def handleShort job, st do #(key, names, attribs, children, pos ) when key == "short" do
        [ name | rest ] = st.names
        
        job = Statement.ensureDeclaredOnce job, st

        unless rest == [] do
            throw { :error, "Job description should have only one string as an argument" }
        end
        unless st.children == [] do
            throw { :error, "Job description should have no children nodes" }
        end
        Map.merge job, %{ short_description: name.value }
    end

    def handleResults job, st do
        job = Statement.ensureDeclaredOnce job, st
        [ name | rest ] = st.names
        
        unless rest == [] do
            Statement.err "Results should have only one string as an argument", st.pos
        end
        unless st.children == [] do
            Statement.err "Results should have no children nodes", st.pos
        end
        Statement.forbidAttribs st
        Map.merge job, %{ results: name.value }
    end

    def handleResultsVisibility job, st  do
        job = Statement.ensureDeclaredOnce job, st
        unless st.names == [] do
            Statement.err "results_visibility should have no \"names\"", st.pos
        end
        unless st.children == [] do
            Statement.err "results_visibility should have no children nodes", st.pos
        end
        if st.attribs == [] do
            Statement.err "You must specify at least one attribute for results_visibility", st.pos
        end
        [ {attrib,param} | a ] = st.attribs

        unless a == [] do
            Statement.err "You must specify only one attribute for results_visibility", st.pos
        end
        type = case attrib.value do    
              ".public" -> :public
              ".contributors" -> :contributors
              ".team" -> :team
              ".owner" -> :owner
               _ ->
            Statement.err "Unknown attribute for results_visibility", st.pos
        end
        Map.merge job, %{ :results_visibility => type }
    end

    def handleInstantiation job, st do 
        job = Statement.ensureDeclaredOnce job, st
        Statement.forbidNames st
        Statement.forbidChildren st
        {attrib, param } = Statement.ensureOneAttrib st

        type = case attrib.value do    
              ".lazy" -> :lazy
              ".eager" -> :eager
              ".instant" -> :eager
               _ ->
            Statement.err "Unknown attribute for instantiation", st.pos
        end
        Map.merge job, %{ :instantiation => type }
    end

    def handleScripts job,st do 
          Statement.forbidNames st
          Statement.forbidAttribs st
          Statement.ensureChildren st
          unless job.scripts == [] do
            Statement.err "Scripts were already declared", st.pos
          end
          ScriptGroupSpec.scriptsChildren job, st.children
    end

    def activityName [], pos do
        JobId.id(10)
    end

    def activityName names, pos do
        [ head | rest ] = names
        unless rest == [] do
            Statement.err "Only one name can be specified for an activity", pos
        end
        head.value
    end
    
    def handleActivity job, st do
          name = activityName st.names, st.pos
          Statement.forbidAttribs st
          activity = %Activity{ id: name }
                   |> ActivitySpec.main(st)
          Map.merge job, %{ activities: [ activity | job.activities ] }
    end

    def main(key, st) when key == "job" do
        IO.puts "ok"
    
        name = JobId.id(10)
        job = %JobTemplate{ id: name }
                |> jobName(st.names)
                |> jobAttribs(st.attribs)
                |> jobChildren(st.children)
    end
    def main( st ) do
        main st.key.value, st
    end

    def main(key, st ) do
        {line, col} = st.pos
        throw { :error, "Top-level statement should be named \"job\", and not \"#{key}\" (at #{line}:#{col})"}
    end

end
