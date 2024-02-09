using LightXML

function test()
    xdoc = parse_file("urls/test1.xml")
    @show typeof(xdoc)
    xroot = root(xdoc)
    for c in child_nodes(xroot)
        @show name(c)
        @show length(content(c))
    end
end
