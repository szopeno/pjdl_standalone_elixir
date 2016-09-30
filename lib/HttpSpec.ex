defmodule HttpSpec do
    def findArg body,ch do
        Enum.reduce ch, body, fn(c,b) ->
            { attrib, param } = Statement.ensureOneAttrib c
            if is_nil(param) do
                Statement.err "Attribute #{attrib.value} requires a parameter", c.pos
            end
            type = case attrib.value do
                "value" -> :value
                "url" -> :url
                "resource" -> :resource
                _ -> 
                Statement.err "Unknown attribute #{attrib.value} for #{c.key.value}", c.pos
            end
            case c.key.value do
                "src" ->
                     Map.merge b, %{ from: param, from_type: type  }
                "from" -> # TODO jak łączyć wyrażenia w case?
                     Map.merge b, %{ from: param, from_type: type  }
                "to" ->
                     Map.merge b, %{ to: param, to_type: type  }
                "result" ->
                     Map.merge b, %{ to: param, to_type: type  }
                _ -> Statement.err "Unknown child node #{attrib.value}", c.pos
            end
        end
    end
    def getAction st do
        Statement.ensureChildren st
        { attrib, param } = Statement.ensureOneAttrib st
        type = case attrib.value do
              "get" -> :get
              "put" -> :put
              "delete" -> :delete
              "post" -> :post
              _ -> Statement.err "Unknown attribute #{attrib.value}", st.pos
        end
        body = %{ type: :http, request_type: type, dest_url: param, from: nil }
             |> findArg st.children
        if ((type==:get) || (type == :delete)) do
            Statement.forbidChildren st
        end
        if is_nil(body.from) and ((type == :put) || ( type== :post)) do
            Statement.err "HTTP PUT and HTTP POST require \"from\" child node", st.pos
        end
        body
    end

    def main act, st do
        body = getAction st
        Map.merge act,  %{actions: [ body | act.actions ] }
    end
end
