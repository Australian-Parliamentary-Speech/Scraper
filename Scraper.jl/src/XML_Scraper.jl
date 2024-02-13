using EzXML

function test()
    xdoc = readxml("urls/xml_files/2019-09-09.xml")
    primates = root(xdoc)
    for child in eachelement(primates)
        @show typeof(child)
        @show child.content
    end
    # Find texts using XPath query.
    for species_name in nodecontent.(findall("//debate", primates))
#        print("AGGGGGGGGGGGG")
#        println("- ", species_name)
    end
end

