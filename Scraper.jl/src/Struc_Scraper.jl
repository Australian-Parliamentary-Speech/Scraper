using LightXML

function test()
    xdoc = parse_file("urls/xml_files/2019-02-12.xml")
    xroot = root(xdoc)
    for c in child_elements(xroot)
        if is_elementnode(c)
            for ele in get_elements_by_tagname(c, "answers.to.questions") 
                @show content(ele)
            end
            if name(c) == "answers.to.questions"
                debates = collect(child_elements(c))
                for debate in debates
                    for subdebates in child_elements(debate)
                        if name(subdebates)=="debate.text"
                            @show content(subdebates)
                        end
                    end
                end
            end
        end
    end
end


function write_child_nodes_recursive(root,file,depth,indent_level::Int = 0)
    indent = repeat(" ", indent_level)    
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
        write_child_nodes_recursive(xroot,file,7,0)
    end
end
 

