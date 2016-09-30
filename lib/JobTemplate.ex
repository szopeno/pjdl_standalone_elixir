defmodule JobTemplate do
    defstruct id: 0, short_description: "", results_visibility: :public, 
              results: "", instantiation: :lazy,
              resources: [], # list of instances
              scripts: [], # list of scripts
              activities: [], # list of activities
              declared: [] # list of atoms (what was already declared)

    def declared? jobTemplate, keyword do
        keyword in jobTemplate.declared
    end
end


defmodule Activity do
    defstruct condition: %{ :type => nil, :body => [] }, # .leaf .xor .and .or .not
              actions: [], # maps
              id: "" # random or given, only for listing
end

"""
    Activity condition, actions
    ConditionTemplate
        type: :empty :leaf , :body => %{ actions | conditions }
            :and :xor :or :not 
        body action :completed :oninit :exists 
            :equals [ :type => :variable | :value | :url, :value => "" ]x2

    Action: :type => :http, :run, :distribute, :ask 
            http: :request_type :request_url :src { :type, :value }, :dst {:type, value}
            run: :script => name, :run_type => sync, async
            ask: :form_name => name, :dst { :type, value }

            distribute:
                :script => name
                instance: [ [ :name, :connection_type] ]
                results: url, :combines => type, :results_verification => type
                events: [ :type, [actions]
"""
