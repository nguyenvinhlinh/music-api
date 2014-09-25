require 'open-uri'
require 'nokogiri'
require 'json'
class SearchController < ApplicationController

  @song_list = Array.new
  #this part, program will take the input from GET 
  def init
    keyword = ""
    source_zingmp3 = false
    source_nhaccuatui = false
    keyword = params[:keyword]
    source = params[:source]
    
    if source.eql?("zing")
      source_zingmp3 = true
    elsif source.eql?("nhaccuatui")
      source_nhaccuatui = true
    elsif source.eql?(nil)
      source_nhaccuatui = true
      source_zingmp3 = true
    else
      source_nhaccuatui = false
      source_zingmp3 = false
    end
    
    Rails.logger.debug "Keyword: #{keyword}"
    Rails.logger.debug "Zing: #{source_zingmp3}"
    Rails.logger.debug "Nhaccuatui: #{source_nhaccuatui}"

    exploit_zing(keyword)
   # exploit_nct(keyword)
  end

  def exploit_zing(keyword)
    word = keyword
    word.gsub!(' ', '+')
    Rails.logger.debug "Method: exploit_zing -- Keyword: #{word}"
    page_doc = Nokogiri::HTML(open('http://m.mp3.zing.vn/tim-kiem/bai-hat.html?q='+ keyword))
    #Analyze the data to take name, artist, url
    Rails.logger.debug "Number of results: #{page_doc.css("div.section-specsong a").size}"
    page_doc.css("div.section-specsong a").each do |node|
      name = node.css('h3')[0].text
      artist = node.css('h4')[0].text
      url = "http://m.mp3.zing.vn"+ node['href']
      source_mp3 = get_source_zing(url)
      Rails.logger.debug "Name: #{name}, Artist: #{artist}, Url: #{url}, File mp3: #{source_mp3}"
    end
  end

  def exploit_nct(keyword)
    Rails.logger.debug "Keyword: #{keyword}"
  end

  def get_source_zing(url)
    page_doc = Nokogiri::HTML(open(url))
    source_xml = page_doc.css('div#mp3Player').first['xml']
    page_xml = Nokogiri::HTML(open(source_xml))
    content_xml = page_xml.css('body').first.content
    json_object = JSON.parse(content_xml);
    #detach the array within JSON object
    array_of_data = json_object['data']
    s = array_of_data.to_s
    i = s.rindex('http://')
    j = s.rindex('="')
    mp3_source_fake = s[i..j]
    #page_fake = Nokogiri::HTML(open(mp3_source_fake))
    #Rails.logger.debug page_fake
    
   # Rails.logger.debug "#{s}, #{i}, #{j}, #{mp3_source}"
    return mp3_source_fake
  end
  
  
end
