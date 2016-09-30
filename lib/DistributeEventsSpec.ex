defmodule DistributeEventsSpec do
    def handleAction children do
        for c <- children do
            case c.key.value do
                "http" -> 
                    HttpSpec.getAction c
                "run" -> 
                    RunSpec.getAction c
                "complete" -> 
                    Statement.forbidChildren c
                    Statement.forbidAttribs c
                    name = Statement.ensureOneName c
                    %{ type: :complete_goal, goal_name: name }
                "fail_job" -> 
                    Statement.forbidChildren c
                    Statement.forbidAttribs c
                    Statement.forbidNames c
                    %{ type: :fail }
                "fail" -> 
                    Statement.forbidChildren c
                    Statement.forbidAttribs c
                    Statement.forbidNames c
                    %{ type: :fail }
                "retry" -> 
                    Statement.forbidChildren c
                    Statement.forbidAttribs c
                    Statement.forbidNames c
                    %{ type: :retry }
                "wait_and_retry" -> 
                    Statement.forbidChildren c
                    Statement.forbidAttribs c
                    period = Statement.ensureOneName c
                    unless period.name == :number do
                        Statement.err "Argument for \"wait_and_retry\" must be a number", c.pos
                    end
                    %{ type: :retry, wait: period.value }
                _ -> # c.key.value
                    Statement.err "Unknown action #{c.key.value}", c.pos
            end
        end
    end

    def handleChildren ev, children do
        Enum.reduce children, ev, fn(c,ev) ->
            Statement.ensureChildren c
            actions = handleAction c.children
            case c.key.value do
                "task_completed" -> 
                    unless is_nil( ev.task_completed) do
                        Statement.err "Event #{c.key.value} already defined", c.pos
                    end
                    Map.merge ev, %{ task_completed: actions }
                "task_failed" ->  
                    unless is_nil( ev.task_failed) do
                        Statement.err "Event #{c.key.value} already defined", c.pos
                    end
                    Map.merge ev, %{ task_failed: actions }
                "task_started" ->  
                    unless is_nil( ev.task_started) do
                        Statement.err "Event #{c.key.value} already defined", c.pos
                    end
                    Map.merge ev, %{ task_started: actions }
                "job_completed" ->
                    unless is_nil( ev.job_completed) do
                        Statement.err "Event #{c.key.value} already defined", c.pos
                    end
                    Map.merge ev, %{ job_completed: actions }
                "job_failed" ->
                    unless is_nil( ev.job_failed) do
                        Statement.err "Event #{c.key.value} already defined", c.pos
                    end
                    Map.merge ev, %{ job_failed: actions }
                "job_started" ->
                    unless is_nil( ev.job_started) do
                        Statement.err "Event #{c.key.value} already defined", c.pos
                    end
                    Map.merge ev, %{ job_started: actions }
                "verification_failed" ->
                    unless is_nil( ev.verification_failed) do
                        Statement.err "Event #{c.key.value} already defined", c.pos
                    end
                    Map.merge ev, %{ verification_failed: actions }
                _ ->
                    Statement.err "Unknown event node #{c.key.value} for \"events\"",c.pos
            end
        end
    end

    def main dist, st do
        Statement.forbidNames st
        Statement.forbidAttribs st
        res = %{ task_completed: nil, task_failed: nil, task_started: nil,
                 job_completed: nil, job_failed: nil, job_started: nil,
                 verification_failed: nil }
              |> handleChildren(st.children)
        Map.merge dist, %{ events: res }
    end
end
