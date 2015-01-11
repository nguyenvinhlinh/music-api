require 'open-uri'
require 'nokogiri'
require 'json'
require 'net/http'
class SearchController < ApplicationController
  #this part, program will take the input from GET 
  def init
    _source_zingmp3 = false
    _source_nhaccuatui = false
    _keyword = params[:keyword]
    if _keyword == nil || _keyword == ""
      Rails.logger.debug "---------------bug here true empty #{_keyword}"
      return
    end
    source = params[:source]
    @song_list = Array.new
    if source.eql?("zing")
      _source_zingmp3 = true
    elsif source.eql?("nhaccuatui")
      _source_nhaccuatui = true
    elsif source.eql?(nil)
      _source_nhaccuatui = true
      _source_zingmp3 = true
    else
      _source_nhaccuatui = false
      _source_zingmp3 = false
    end
    
    Rails.logger.debug "Keyword: #{_keyword}"
    Rails.logger.debug "Zing: #{_source_zingmp3}"
    Rails.logger.debug "Nhaccuatui: #{_source_nhaccuatui}"

    if(_source_zingmp3 == true)
#      @song_list = @song_list + (exploit_zing(_keyword))
      mp3zing_sendRequest(_keyword, 24)
    end
    if(_source_nhaccuatui == true)
    end
  end
  
  def exploit_zing(keyword)
    _word = keyword
    _word.gsub!(' ', '+')
    Rails.logger.debug "Method: exploit_zing -- Keyword: #{_word}"
    _page_doc = Nokogiri::HTML(open('http://m.mp3.zing.vn/tim-kiem/bai-hat.html?q='+ _word))
    #Analyze the data to take name, artist, url
    Rails.logger.debug "Number of results: #{_page_doc.css("div.section-specsong a").size}"
    _song_list = []
    _page_doc.css("div.section-specsong a").each do |node|
      _name = node.css('h3')[0].text
      _artist = node.css('h4')[0].text
      _url = "http://m.mp3.zing.vn"+ node['href']
      _source_mp3 = get_source_zing(_url)
      _song = Song.new
      _song.name = _name
      _song.artist = _artist
      _song.url_page = _url
      _song.url_source = _source_mp3
      _song.provider = "zing mp3"
      _song_list.push(_song)
      #Rails.logger.debug "Name: #{name}, Artist: #{artist}, Url: #{url}, File mp3: #{source_mp3}"
    end
    return _song_list
  end

  def exploit_nct(keyword)
    Rails.logger.debug "Keyword: #{keyword}"
    
  end

  def get_source_zing(url)
    _page_doc = Nokogiri::HTML(open(url))
    _source_xml = _page_doc.css('div#mp3Player').first['xml']
    _page_xml = Nokogiri::HTML(open(_source_xml))
    _content_xml = _page_xml.css('body').first.content
    _json_object = JSON.parse(_content_xml);
    #detach the array within JSON object
    _array_of_data = _json_object['data']
    _s = _array_of_data.to_s
    _i = _s.rindex('http://')
    _j = _s.rindex('"}]')
    _k = _s.rindex('", "hq"=>"require vip"}]')
    
    Rails.logger.debug "first pos: #{_i}, last pos1: #{_j}, last pos2: #{_k}, content: #{_s}, detach: #{_s[_i.._j-1]} "
    #page_fake = Nokogiri::HTML(open(mp3_source_fake))
    #Rails.logger.debug page_fake
    if _k == nil
      _mp3_source_fake = _s[_i.._j-1]
    else
      _mp3_source_fake = _s[_i.._k-1]
    end

  #  return find_direct_url(_mp3_source_fake)
   # Rails.logger.debug "#{s}, #{i}, #{j}, #{mp3_source}"
  end

  def find_direct_url(url)
    _uri = URI(url)
    _response = Net::HTTP.get_response(_uri)
    _statusCode = _response.code
    if _statusCode.eql?("403")
      return url 
    end
    while(_statusCode.eql?("302"))
      _uri = URI(_response['location'])
      _response = Net::HTTP.get_response(_uri)
      _statusCode = _response.code
    end
    return _uri.to_s
    
  end

  def mp3zing_sendRequest(query, numberOfResult = 20)
    _numberOfResultPerPage = 20
    _keyword = query.gsub(' ', '+')
    puts "Number of expected results: #{numberOfResult}"
    puts "Number of pages: #{numberOfResult / _numberOfResultPerPage}, Mod: #{numberOfResult % _numberOfResultPerPage}"
    if (numberOfResult % _numberOfResultPerPage == 0)
      _number_of_page = numberOfResult / _numberOfResultPerPage
    else
      _number_of_page = numberOfResult / _numberOfResultPerPage +1
    end
    puts "Number of pages: #{_number_of_page}"
    for i in 1.._number_of_page
      _url = "http://mp3.zing.vn/tim-kiem/bai-hat.html?q=#{_keyword}&p=#{i}"
      _response = Net::HTTP.get_response(URI(_url))
      
      puts "#{i}, #{_response.code} \n"
      collectingDataFromResponseZing(_response)
    end
  end


  def collectingDataFromResponseZing(response)
    _html_document = Nokogiri::HTML(response.body)
    #song's name
    _songName = _html_document.css('div[class=first-search-song] > h3 > a')
    puts _songName[0].text
    #song's singers
    _songSinger = _html_document.css('div[class=first-search-song] > p > a')
    puts _songSinger[0].text
    #song's page url
    _songPage = "http://mp3.zing.vn#{_songName[0]['href']}" 
    puts _songPage
    #song's source
    puts _html_document.css('div[class = "first-search-song"] > script')[0].text
    
    #solve class first-search-song
    #solve class content-block special-song
  end
end

