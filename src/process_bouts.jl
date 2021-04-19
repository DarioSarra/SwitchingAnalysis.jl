"""
    `count_case(cases::T) where T <:AbstractVector{Bool}`
    starting from 1 increase the count value after an event signalled on boolvec
    is true
"""
function count_cases(cases::T) where T <:AbstractVector{Bool}
    shifted_cases = vcat([Bool(0)], cases[1:end-1])
    accumulate(+, shifted_cases; init = 1)
end

"""
    `count_bouts!(pokedf::DataFrames.AbstractDataFrame)`
    using a pokes dataframe count reward bouts within each session
"""
function count_bouts!(pokedf::DataFrames.AbstractDataFrame)
    if ((:LastPoke in propertynames(pokedf)) && (:Reward in propertynames(pokedf)))
        return transform!(groupby(pokedf,[:ExpDay,:MouseID]), [:LastPoke, :Reward] => ((l,r) -> count_cases(l .| r)) => :Bout)
    else
        error("Not a pokes dataframe")
    end
end

function process_bouts(pokedf::AbstractDataFrame)
    if !(:Bout in propertynames(pokedf))
        error("No bout information")
    else
        # [:ExpDay, :MouseID, :Day, :Trial, :Poke, :PokeIn, :PokeOut, :Side, :Reward,
        # :ROI_In, :ROI_Out, :Protocol, :Stim, :Poke_within_Trial, :Pre_Interpoke, :Post_Interpoke,
        # :LastPoke, :Poke_Hierarchy, :ReverseTrial, :Correct, :PokeDuration, :Stim_Day, :Phase, :Group,
        # :Treatment, :Injection, :ExpType, :ProtocolDay, :Next_Prew, :Pnextrew, :InstRewRate, :ElapsedTime,
        # :Cumulative_Reward, :AverageRewRate, :TimeFromLeaving, :CumRewTrial, :Bout]

        vals_per_bout = [:Side, :Trial,:Protocol, :Stim,:ROI_In, :ROI_Out]
        vals_per_day = [:Day, :Phase, :Group, :Treatment, :Injection, :ExpType, :ProtocolDay, :Stim_Day];
        bout_table = combine(groupby(pokedf, :Bout)) do dd
            dt = DataFrame(
            Omissions_plus_one = size(dd,1),
            Leave = dd[end,:LastPoke],
            End_Reward = dd[end,:Reward],
            BoutIn = dd[1,:PokeIn],
            BoutOut = dd[end,:PokeOut],
            Bout_duration = (dd[end,:PokeOut]-dd[1,:PokeIn]),
            Next_Prew = dd[end,:Next_Prew],
            Pnextrew = dd[end,:Pnextrew],
            InstRewRate = dd[end,:InstRewRate],
            AverageRewRate = dd[end,:AverageRewRate]
            )

            for v in vals_per_bout
                if v in propertynames(dd)
                    dt[!,v] .= dd[1, v]
                end
            end

            return dt
        end

        for v in vals_per_day
            if v in propertynames(pokedf)
                bout_table[!,v] .= pokedf[1, v]
            end
        end

        return bout_table
    end
end
