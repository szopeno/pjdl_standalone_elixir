defmodule DistributeInstanceSpec do
    def handleInstance c do
        name = Statement.ensureOneName c
        {attrib, param} = Statement.atMostOneAttrib c
        case c.key.value do
            "resource" -> 
                type = case attrib.value do
                    ".raw" -> :raw
                    ".inject" -> :inject
                    ".websockets" -> :ws
                    ".get" -> :get
                    _ ->
                    Statement.err "Unknown attribute for \"resource\"", c.pos
                end
                %{ name: name.value, type: type }
            _ ->
                Statement.err "Unknown child node for \"instance\"", c.pos
        end
    end

    def main dist, st do
        Statement.forbidAttribs st
        name = Statement.atMostOneName st
        if is_nil(name) do
            instances = for c <- st.children do
                handleInstance c
            end
        else
          unless name.name == :number do
              Statement.err "An \"instance\" may have only given a number as a param", st.pos
          end
          Statement.forbidChildren st # when number given, no children should appear
          instances = [ %{ type: :number, number: name } ]
        end
        Map.merge dist,  %{instances: [ instances | dist.instances ] }
    end
end
