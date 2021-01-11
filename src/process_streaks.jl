"""
`process_streaks`
"""

function process_streaks(df::DataFrames.AbstractDataFrame)
    streak_table = combine(groupby(df, :Trial)) do dd
        dt = DataFrame(
        Num_pokes = size(dd,1),
        Num_Rewards = length(findall(skipmissing(dd[!,:Reward]))),
        Start_Reward = dd[1,:Reward],
        Last_Reward = findlast(dd[!,:Reward]).== nothing ? 0 : findlast(dd[!,:Reward]),
        Prev_Reward = findlast(dd[!,:Reward]).== nothing ? 0 : findprev(dd[!,:Reward], findlast(dd[!,:Reward])-1),
        Poking_duration = (dd[end,:PokeOut]-dd[1,:PokeIn]),
        Trial_duration = (dd[end,:ROI_Out]-dd[1,:ROI_In]),
        Start_poking = (dd[1,:PokeIn]),
        Stop_poking = (dd[end,:PokeOut]),
        Start_trial = (dd[1,:ROI_In]),
        Stop_trial = (dd[end,:ROI_Out]),
        Pre_Interpoke = any(map(!,ismissing.(dd[!,:Pre_Interpoke]))) ? maximum(skipmissing(dd[!,:Pre_Interpoke])) : missing,
        Post_Interpoke = any(map(!,ismissing.(dd[!,:Post_Interpoke]))) ? maximum(skipmissing(dd[!,:Post_Interpoke])) : missing,
        #PokeSequence = [SVector{nrow(dd),Union{Bool,Missing}}(dd[!,:Reward])],
        Protocol = dd[1,:Protocol],
        Side = dd[1,:Side],
        ReverseTrial = dd[1,:ReverseTrial],
        Stim = dd[1,:Stim],
        Stim_Day = dd[1,:Stim_Day],
        Actual_Leaving_Prew = dd[end,:Actual_Prew]
        )
        return dt
    end
    streak_table[!,:Prev_Reward] = [x .== nothing ? 0 : x for x in streak_table[:,:Prev_Reward]]
    streak_table[!,:AfterLast] = streak_table[!,:Num_pokes] .- streak_table[!,:Last_Reward];
    streak_table[!,:BeforeLast] = streak_table[!,:Last_Reward] .- streak_table[!,:Prev_Reward].-1;
    prov = lead(streak_table[!,:Start_poking],default = 0.0) .- streak_table[!,:Stop_poking];
    streak_table[!,:Poking_Travel_to] = [x.< 0 ? 0 : x for x in prov]
    prov = lead(streak_table[!,:Start_trial],default = 0.0) .- streak_table[!,:Stop_trial];
    streak_table[!,:Trial_Travel_to] = [x.< 0 ? 0 : x for x in prov]
    streak_table[!,:Travel_to] = streak_table.Poking_Travel_to + streak_table.Trial_Travel_to
    return streak_table
end
