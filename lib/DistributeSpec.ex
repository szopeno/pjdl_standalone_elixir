defmodule DistributeSpec do
    def handleChildren body, st do
        Statement.ensureChildren st 
        Enum.reduce st.children, body, fn(c, acc) ->
            res = case c.key.value do
                "events" ->
                    unless is_nil(acc.events) do
                        Statement.err "Only one events section may be specified for \"distribute\"", c.pos
                    end
                    DistributeEventsSpec.main acc, c
                "results" ->
                    unless is_nil(acc.results) do
                        Statement.err "Only one results section may be specified for \"distribute\"", c.pos
                    end
                    DistributeResultsSpec.main acc, c
                "instance" ->
                    DistributeInstanceSpec.main acc, c
                _ ->
                    Statement.err "Wrong child node #{c.key.value} for \"distribute\"", c.pos
            end
            Map.merge acc, res
        end
    end

    def main act, st do
        Statement.ensureChildren st
        name = Statement.ensureOneName st
        body = %{ results: nil, events: nil, script: name.value, instances: [] }
             |> handleChildren st
        Map.merge act,  %{actions: [ body | act.actions ] }
    end
end
