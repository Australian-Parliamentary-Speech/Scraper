module NodeModule

abstract type Node end

const node_path = joinpath(@__DIR__, "nodes")
for path in readdir(node_path, join=true)
    if isfile(path)
        include(path)
    end
end

function detect_node_type(node)
    name = nodename(node)
    node_struct_name = nodename_to_structname(name)
    node_struct_symbol = Symbol("$(uppercasefirst(node_struct_name))Node")
    node_struct = getfield(NodeModule,node_struct_symbol)
    return node_struct
end


end


