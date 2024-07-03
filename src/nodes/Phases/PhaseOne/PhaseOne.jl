# Define like this to ensure TestPhase exists before including node overrides

abstract type PhaseOne <: AbstractPhase end

# Get TestPhase Node Overrides
const testphase_node_path = joinpath(@__DIR__, "nodes")
for path in readdir(testphase_node_path, join=true)
    if isfile(path)
        include(path)
    end
end

# Uncomment to test
upperbound = date_to_float(2011,4,0)
date_to_phase[(1901.0,upperbound)] = PhaseOne
