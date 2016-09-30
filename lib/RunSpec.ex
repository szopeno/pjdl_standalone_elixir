defmodule RunSpec do
    def getAction st do
        name = Statement.ensureOneName st
        { attrib, param } = Statement.atMostOneAttrib st
        unless is_nil(param) do
            Statement.err "Attrib for \"run\" should have no params", st.pos
        end
        unless is_nil(attrib) do
            attrib = case attrib.value do
                ".sync" -> :sync
                ".async" -> :async
                _ -> Statement.err "Unknown attribute #{attrib.value}", st.pos
            end
        end
        %{ :type => :run, :script => name.value, :attrib => attrib }
    end

    def main act, st do
        action = getAction st
        Map.merge act,  %{actions: [ action | act.actions ] }
    end
end
