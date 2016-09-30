defmodule ConditionSpec do

    def findEquals {st, param} do
        case st.value do
            "variable" ->
                %{ :type => :variable, :value => param }
            "url" ->
                %{ :type => :url, :value => param }
            "value" -> 
                %{ :type => :value, :value => param }
            _ ->
               Statement.err "Unknown parameter for \"equals\" condition", st.pos
        end
    end

    def getCondition c do
        condition = case c.key.value do
            "completed" ->
               Statement.forbidChildren c
               Statement.forbidAttribs c
               name = Statement.ensureOneName c
               %{ :type => :completed, :value => name.value }
            "oninit" ->
               Statement.forbidChildren c
               Statement.forbidAttribs c
               Statement.forbidNames c
               %{ :type => :oninit}
            "exists" ->
               Statement.forbidChildren c
               Statement.forbidAttribs c
               name = Statement.ensureOneName c
               %{ :type => :exists, :value => name.value }
            "equals" ->
               if c.attribs == [] do
                   Statement.err "Equals requires two attributes!", c.pos
               end
               [ first | rest ] = c.attribs
               if rest == [] do
                   Statement.err "Equals requires two attributes!", c.pos
               end
               [ second | rest ] = rest
               first_param = findEquals first
               second_param = findEquals second
               %{ :type => :equals, :first => first_param, :second => second_param }
            "and" ->
                Statement.ensureChildren c
                conditions = for i <- c.children do
                    getCondition i
                end
                %{ :type => :and, :children => conditions }
            "xor" ->
                Statement.ensureChildren c
                conditions = for i <- c.children do
                    getCondition i
                end
                %{ :type => :xor, :children => conditions }
            "or" ->
                Statement.ensureChildren c
                conditions = for i <- c.children do
                    getCondition i
                end
                %{ :type => :or, :children => conditions }
            "not" ->
                child = Statement.ensureOneChild c
                condition = getCondition child
                %{ :type => :not, :children => condition }
            _ ->
                Statement.err "Unexpected condition", c.pos
        end
    end

    def main activity, st do
        c = Statement.ensureOneChild st
        Statement.forbidNames st
        Statement.forbidAttribs st
        condition = getCondition c
        Map.merge activity, %{condition: condition } 
    end
end
