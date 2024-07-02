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
year_to_phase[2022] = PhaseOne
