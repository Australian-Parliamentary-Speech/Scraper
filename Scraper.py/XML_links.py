from bs4 import BeautifulSoup
from requests.exceptions import ConnectionError
import requests
import csv
import sys
import os
import re
import certifi
import urllib3
from selenium import webdriver


def get_soup(url,sele):
    if sele == True:
        driver = webdriver.Chrome() 
        driver.get(url)
        source = driver.page_source
    else:
        source = requests.get(url).text 

    soup = BeautifulSoup(source,'lxml')
    return soup

def get_table_soup(soup):
    table_soups = soup.find_all('table')
    return table_soups

def get_link_from_table(table_soup):
     xml_links = table_soup.find_all('a')
     return [xml_link.get('href') for xml_link in xml_links]

def get_date_from_link(link):
    link_bits = link.split('/')
    return link_bits[-2]

def import_to_dict(dict_,keys,values):
    for i in range(len(keys)):
        dict_[keys[i]] = values[i]
    return dict_

def get_xml(link):
    xml_soup = get_soup(link,True)
    xml_subsoup = xml_soup.find('div',class_ = "hide-for-print medium-3 column")
    print(xml_subsoup)
#    xml_link = xml_soup.find('a',title="View/Save XML")
    all_links = xml_subsoup.find_all('a')
    print([link.get('style href') for link in all_links])

def XML_link():
    url = "https://www.aph.gov.au/Parliamentary_Business/Hansard/Hansreps_2011"
    soup = get_soup(url,False)
    table_soups = get_table_soup(soup)
    date_to_link = {}
    for table_soup in table_soups:
        links = get_link_from_table(table_soup)
        dates = [get_date_from_link(link) for link in links]
        date_to_link = import_to_dict(date_to_link,dates,links)

    for date in list(date_to_link.keys())[1:3]:
        get_xml(date_to_link[date])
    
    
    


XML_link()


