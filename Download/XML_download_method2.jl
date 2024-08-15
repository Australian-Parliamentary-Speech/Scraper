using HTTP
using Gumbo
using Cascadia
using Downloads
using CSV
using DataFrames
using EzXML
include("utils.jl")

function find_xml_link_from_page(href)
    page_soup = get_soup(href)
    xml_img = eachmatch(sel"img[title~=XML]",page_soup)
    if !isnothing(xml_img)&& length(xml_img)>0 
        xml_link = xml_img[1].parent.attributes["href"]
        return "https://parlinfo.aph.gov.au/$xml_link"
    else
        return "N/A"
    end
end

function get_page_number(soup)
    box = eachmatch(sel"div.numbers",soup)[1]
    number = eachmatch(sel"b",box)[1]
    return number.children[1].text
end

function write_xml_one_page(link,io)
    dates = []
    xml_links = []
    soup = get_soup(link)
    result_soup = eachmatch(sel"ul#results",soup)[1]
    for one_result in eachmatch(sel"div.resultContent",result_soup)
        link_soup = eachmatch(sel"div.sumLink",one_result)[1]
        href = eachmatch(sel"a",link_soup)[1].attributes["href"]
        xml_link = find_xml_link_from_page(href)

        date_soup = eachmatch(sel"div.sumMeta",one_result)[1]
        date_text,collection,ID_text,source = split(date_soup.children[1].text,"-")
        date = match(r"\d{2}/\d{2}/\d{4}", date_text).match

        push!(xml_links,xml_link)
        if isnothing(date)
            date = "N/A"
        end
        @show date
        push!(dates,date)
    end

    for i in 1:length(dates)
        println(io, join([dates[i], xml_links[i], link], " "))
    end
    return soup
end

function next_page_link(soup)
    next_image = eachmatch(sel"img[title~=Next]",soup)[1]
    next_link = next_image.parent.attributes["href"]
    return next_link
end

#this is the function you run
function write_xml_links()
    link = "https://parlinfo.aph.gov.au/parlInfo/search/summary/summary.w3p;adv%3Dyes;orderBy%3D_fragment_number,doc_date-rev;query%3DDataset%3Ahansardr,hansardr80;resCount%3D200"
    maxnumber = 4800
    number = 1
    open("xml_urls_final_.csv", "w") do io
        while number < maxnumber
            soup = write_xml_one_page(link,io)
            link = next_page_link(soup)
            @show link
            number += 1
            @show number
            sleep(50)
        end
    end
end


