using LightXML

function test()
    xdoc = parse_file("urls/xml_files/2019-02-12.xml")
    xroot = root(xdoc)
    for c in child_nodes(xroot)
        if is_elementnode(c)
            @show name(c)
        end
        for i in child_nodes(c)
            if is_elementnode(i)
                @show name(i)
            end
        end    
    end
end

function write_child_nodes_recursive(root,file,depth,indent_level::Int = 0)
    indent = repeat("  ", indent_level)    
    if depth <= 0
        return
    end
    
    for child in child_nodes(root)
        if is_elementnode(child)
            write(file, "$indent $(name(child)) \n")
            print("$indent $(name(child)) \n")
            write_child_nodes_recursive(child, file,depth - 1, indent_level + 1)
        end
    end
end

function write_main()
    xdoc = parse_file("urls/xml_files/2019-02-12.xml")
    xroot = root(xdoc)
    open("child_nodes.txt", "w") do file
        write_child_nodes_recursive(xroot,file,3,0)
    end
end
 

