defmodule ResourceGroupSpec do
    require JobTemplate

    def resourceChildren job, [] do
        IO.puts "Resources with no instances? Are you sure you wanted this?"
        job
    end

    def resourceChildren job, children do
       Enum.reduce children, job, fn (a,job) -> 
           case a.key.value do
                "instance" ->
                instance = 
                    for i <- a.children do     
                        func = case i.key.value do
                            #"range" -> 
                            #    &ResourceSpec.main/2
                            "vector" ->
                                &ResourceSpec.dimensional/1
                            "array" ->
                                &ResourceSpec.dimensional/1
                            "cube" ->
                                &ResourceSpec.dimensional/1
                            "raw" ->
                                &ResourceSpec.noDimensional/1
                            "folder" ->
                                &ResourceSpec.noDimensional/1
                            "variable" ->
                                &ResourceSpec.noDimensional/1
                            _ ->
                             Statement.err "unknown resource type #{i.key.value}", a.pos
                        end
                        func.(i)
                    end
                    job = Map.merge job, %{resources: [ instance | job.resources ] }
                _ -> 
                   Statement.err "unknown keyword #{a.value} for \"instance\"", a.pos
                   job 
            end
       end 
    end

    def main job, st do 
        unless st.names == [] do
             Statement.err "resources should have no \"names\"", st.pos
        end
        unless st.attribs == [] do
             Statement.err "resources should have no attribs", st.pos
        end
        unless job.resources == [] do
            Statement.err "Resources were already declared", st.pos
        end
        job = resourceChildren( job, st.children )
    end
end
