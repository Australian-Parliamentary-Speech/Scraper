# Define like this to ensure TestRangePhase exists before including node overrides

abstract type TestRangePhase <: AbstractPhase end

# Get TestRangePhase Node Overrides
const testrangephase_node_path = joinpath(@__DIR__, "nodes")
for path in readdir(testrangephase_node_path, join=true)
    if isfile(path)
        include(path)
    end
end

# Uncomment to test
#range_to_phase[(2022, 2024)] = TestRangePhase
