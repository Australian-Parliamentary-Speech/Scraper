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

function write_root(lines)
    root = XML.Element("root")
    parent_nodes = [root]
    for i in 1:length(lines)-1
        line,current_indent = lines[i][end],lines[i][1]
        next_line,next_indent = lines[i+1][end],lines[i+1][1]
        current_node = XML.Element(line)
        add_text(current_node,line)
        if i == 1
            push!(root,current_node)
            push!(parent_nodes,current_node)
        else
            push!(parent_nodes[end],current_node)
            if current_indent < next_indent
                push!(parent_nodes,current_node)
            elseif current_indent > next_indent
                n = current_indent - next_indent
                parent_nodes = parent_nodes[1:end-n]
            end
        end
    end
    last_node = XML.Element(lines[end][end])
    push!(parent_nodes[end],last_node) 
    XML.write("check.xml",root)
    return root
end

function add_text(node,info)
    push!(node, XML.Text(info))
end
 

function test_main()
    fn = "child_nodes.txt"

    lines = node_indices(fn)
    root = write_root(lines)
#   root = root_(all_indices,root,max_depth)
end
 



