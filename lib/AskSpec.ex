defmodule AskSpec do
    def main act, st do
        name = Statement.ensureOneName st
        { attrib, param } = Statement.atMostOneAttrib st
        unless is_nil(attrib) do
            attrib = case attrib.value do
                "to_url" -> :url
                "to_resource" -> :resource
                _ -> Statement.err "Unknown attribute #{attrib.value}", st.pos
            end
        end
        Map.merge act,  %{actions: [ %{ :type => :ask, :form => name.value, :attrib => attrib } | act.actions ] }
    end
end
