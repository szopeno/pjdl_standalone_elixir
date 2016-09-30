defmodule DistributeResultsSpec do
    def handleChild res, children do
        Enum.reduce children, res, fn(c,res) ->
            case c.key.value do
                "url" ->
                     unless is_nil(res.url) do
                        Statement.err "An \"url\" already given", c.pos
                     end
                     name = Statement.ensureOneName c
                     Map.merge res, %{ url: name.value }
                "combines" ->
                    {attrib, param} = Statement.ensureOneAttrib c
                    type = case attrib.value do
                        "self" -> :self
                        ".min"  -> :min
                        ".max"  -> :max
                        ".avg"  -> :avg
                        ".sum"  -> :sum
                        ".nomerge" -> :nomerge
                        ".vector"  -> :vector
                        ".array"   -> :array
                    end
                    if not is_nil(param) and not (type == :self) do
                        Statement.err "Only \"self\" requires a parameter", c.pos
                    end
                    if is_nil(param) and (type == :self) do
                        Statement.err "\"self\" requires a parameter", c.pos
                    end

                    Map.merge res, %{ combines: type, script: param }
                "result_verification" ->
                    {attrib, param} = Statement.ensureOneAttrib c
                    type = case attrib.value do
                        "self" -> :self
                        ".none"  -> :none
                        ".majority_voting"  -> :majority_voting
                        ".weighted_voting"  -> :weighted_voting
                        ".spot_checking"  -> :spot_checking
                    end
                    if not is_nil(param) and not (type == :self) do
                        Statement.err "Only \"self\" requires a parameter", c.pos
                    end
                    if is_nil(param) and (type == :self) do
                        Statement.err "\"self\" requires a parameter", c.pos
                    end
                    Map.merge res, %{ results_verification: type, script: param }
                _ ->
                    Statement.err "Unknown children node for \"results\"", c.pos
            end
        end
    end

    def main dist, st do
        Statement.forbidNames st
        Statement.forbidAttribs st
        res = %{ url: nil, combines: :array, verification: :none, script: nil }
        |> handleChild st.children
        Map.merge dist, %{ results: res }
    end
end

