defmodule ActivitySpec do

    def main activity, st do
        Statement.ensureChildren st 
        Enum.reduce st.children, activity, fn(c, act) ->
            res = case c.key.value do
                "condition" ->
                    unless is_nil(act.condition.type) do
                        Statement.err "Only one condition for activity may be specified. Group conditions with \"and\", \"or\", \"xor\" when necessary", st.pos
                    end
                    ConditionSpec.main act, c
                "http" ->
                    HttpSpec.main act, c
                "run" ->
                    RunSpec.main act, c
                "ask" ->
                    AskSpec.main act, c
                "distribute" ->        
                    DistributeSpec.main act, c
                _ ->
                    Statement.err "Wrong child node #{c.key.value} for \"activity\"", c.pos
            end
            Map.merge act, res
        end
    end
end
