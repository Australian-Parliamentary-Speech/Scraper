using XML: h
using XML


function count_leading_spaces(str::AbstractString)
    leading_spaces = 0
    for char in str
        if char == ' '
            leading_spaces += 1
        else
            break
        end
    end
    return leading_spaces
end

function remove_indent(text::AbstractString)
    lines = split(text, '\n')
    for i in 1:length(lines)
        lines[i] = strip(lines[i])
    end
    return join(lines, '\n')
end

function node_indices(filename::AbstractString)
    file = open(filename, "r")
    line_no = 1
    all = []
    for line in eachline(file)
        indent_level = count_leading_spaces(line)
        push!(all,(indent_level,line_no,remove_indent(line)))
        line_no += 1
    end
    close(file)
    return all
end


function root_(all_indices,root,max_depth)
    depth = 1
    while depth < max_depth
        parent_nodes = [i for i in all_indices if i[1] == depth]
        child_nodes = [i for i in all_indices if i[1] == depth+1]
        for i in 1:length(parent_nodes)-1
            next_parent = parent_nodes[i+1]
            now_parent = parent_nodes[i]
            now_parent_node = XML.Element(now_parent[end])
            push!(root, now_parent_node)
            add_text(now_parent_node,now_parent)
            now_children = [c for c in child_nodes if now_parent[2]<c[2]<next_parent[2]]
            for child in now_children
                child_node = XML.Element(child[end])
                push!(now_parent_node,child_node)
                add_text(child_node,child)
            end
        end

        final_parent = parent_nodes[end]
        final_children = [c[end] for c in child_nodes if final_parent[2]<c[2]]
        final_parent_node = XML.Element(final_parent[end])
        push!(root, final_parent_node)
        add_text(final_parent_node,final_parent)

        for child in final_children
            child_node = XML.Element(child)
            push!(XML.Element(final_parent[end]),child_node)
            add_text(child_node,child)
        end
        depth += 1
    end
    return root
end

function add_text(node,info)
    push!(node, XML.Text(info))
end
 

function test_main()
    fn = "child_nodes.txt"
    all_indices = node_indices(fn)
    root = XML.Element("root")
    max_depth = maximum([i[1] for i in all_indices])
    root = root_(all_indices,root,max_depth)
    XML.write("check_.xml",root)
end
 



