require 'open-uri'
require 'nokogiri'
require 'json'
require 'net/http'
class SearchController < ApplicationController
  #this part, program will take the input from GET 
  def init
    @source_zingmp3 = false
    @source_nhaccuatui = false
    @song_list = Array.new
    @keyword = params[:keyword]
    if @keyword == nil || @keyword == ""
      return
    end
    source = params[:source]
    if source.eql?("zing")
      @source_zingmp3 = true
    elsif source.eql?("nhaccuatui")
      @source_nhaccuatui = true
    elsif source.eql?(nil)
      @source_nhaccuatui = true
      @source_zingmp3 = true
    else
      @source_nhaccuatui = false
      @source_zingmp3 = false
    end
    if(@source_zingmp3 == true)
      mp3zing_sendRequest(@keyword, 20)
    end
    if(@source_nhaccuatui == true)
      #puts "nhaccuatui"
      nhaccuatui_sendRequest(@keyword, 37)
    end
  end
  def apindex
    
  end
  def api
    @source_music = params[:source] #compulsory
    @keyword = params[:keyword] #compulsory
    @total= params[:number] #optional
    @song_list = Array.new 
    #source is invalid or valid
    #total number of song, by default is 20
    if @source_music == nil
      render json: "No source provide"
      return
    end
    if @total != nil
      @total = @total.to_i
    else
      @total = 20
    end
    #keywork define
    if @keyword == nil || @keyword.eql?("")
      #no keywork provide
      render json: "No keyword provide #{@keyword}"
      return
    end
    case @source_music
    when "1" #mp3zing
      mp3zing_sendRequest(@keyword, @total)
    when "2" #nhaccuatui
      nhaccuatui_sendRequest(@keyword, @total)
    else
    #ping back to client that wrong music provider
    end
#    render plain: "[API] keyword: #{@keyword}, source: #{@source_music}, total: #{@total}"
    
    render json: @song_list
  end 
  def find_direct_url(url)
    _uri = URI(URI.encode(url))
    _response = Net::HTTP.get_response(_uri)
    _statusCode = _response.code
    if _statusCode.eql?("403")
      return url 
    end
    while(_statusCode.eql?("302"))
      _uri = URI(URI.encode(_response['location']))
      _response = Net::HTTP.get_response(_uri)
      _statusCode = _response.code
    end
    return _uri.to_s
  end
  def mp3zing_sendRequest(query, numberOfResult = 20)
    if numberOfResult > 60
      numberOfResult = 60
    end
    _numberOfResultPerPage = 20
    _keyword = query.gsub(' ', '+')
#    puts "Number of expected results: #{numberOfResult}"
#    puts "Number of pages: #{numberOfResult / _numberOfResultPerPage}, Mod: #{numberOfResult % _numberOfResultPerPage}"
    if (numberOfResult % _numberOfResultPerPage == 0)
      _number_of_page = numberOfResult / _numberOfResultPerPage
    else
      _number_of_page = numberOfResult / _numberOfResultPerPage + 1
    end
    _song_list = Array.new
    for i in 1.._number_of_page
      _url = "http://mp3.zing.vn/tim-kiem/bai-hat.html?q=#{_keyword}&p=#{i}"
      _response = Net::HTTP.get_response(URI(URI.encode(_url)))
      _result = collectingDataFromResponseZing(_response)
      if _result != nil
        _song_list +=  _result
      end
    end
    for i in 0...numberOfResult
      if _song_list[i].nil?
        break
      end
      @song_list << _song_list[i]
    end
  end
  def collectingDataFromResponseZing(response)
    _song_list = Array.new
    _html_document = Nokogiri::HTML(response.body)
    #1.solve class first-search-song
    #song's name
    _songName = _html_document.css('div[class=first-search-song] > h3 > a')
    if _songName.size == 0
      return
    end
    #puts _songName[0].text
    #song's singers
    _songSinger = _html_document.css('div[class=first-search-song] > p > a')
    #puts _songSinger[0].text
    #song's page url
    _songPage = "http://mp3.zing.vn#{_songName[0]['href']}" 
    #puts _songPage
    #song's source
    _songSource =  _html_document.css('div[class = "first-search-song"] > script')[0].text
    _songSource = detachURLFromScript(_songSource)
    _song_list.push(Song.new(_songName[0].text, _songSinger[0].text, "no lyric", _songPage, _songSource, "Zing MP3"))
    #2.solve class content-block special-sonasdasdg
    _contentBlock = _html_document.css('div.content-item.ie-fix')
 #   puts _contentBlock.size
    for i in 0..._contentBlock.size
      _songName = _contentBlock[i].css('h3 > a')[0].text
      begin
        _songSinger = _contentBlock[i].css('p > a')[0].text
      rescue
        _songSinger = "unknown"
      end
      _songPage =  "http://mp3.zing.vn#{_contentBlock[i].css('h3 > a')[0]['href']}"
      _songSource = detachURLFromScript(_contentBlock[i].css('script')[0].text)
      #_songSource = find_direct_url(_songSource)
      _song_list.push(Song.new(_songName, _songSinger, "no lyric", _songPage, _songSource, "Zing MP3"))
      #puts "song name: #{_songName}, singer: #{_songSinger}, page: #{_songPage}, source: #{_songSource}"
    end
    return _song_list
  end
  def detachURLFromScript(text)
    _startIndex =  text.index('href="')
    _endIndex = text.index('"', _startIndex+6)
    return text[_startIndex+6, _endIndex - _startIndex - 6]
  end  
  def nhaccuatui_sendRequest(query, numberOfResult = 37)
    if numberOfResult > 111
      numberOfResult = 111
    end
    
    _numberOfResultPerPage = 37
    _keyword = query.gsub(' ', '+')
    _song_list = Array.new
    #number of page finder
    if (numberOfResult % _numberOfResultPerPage == 0)
      _number_of_page = numberOfResult / _numberOfResultPerPage
    else
      _number_of_page = numberOfResult / _numberOfResultPerPage + 1
    end
    #Collecting data form number of page, sending request here
    for i in 1.._number_of_page
      _url = "http://www.nhaccuatui.com/tim-kiem/bai-hat?q=#{_keyword}&page=#{i}"
      _response = Net::HTTP.get_response(URI(URI.encode(_url)))
      _result = collectingDataFromResponseNhaccuatui(_response)
      if _result != nil
        _song_list +=  _result
      end
    end
    for i in 0...numberOfResult
      if _song_list[i].nil?
        break
      end
      @song_list << _song_list[i]
    end
  end

  def collectingDataFromResponseNhaccuatui (response)
    _song_list = Array.new
    _html_document = Nokogiri::HTML(response.body)
    _search_returns_list = _html_document.css('ul[class = "search_returns_list"] > li[class = "list_song"]')
    #size of _search_return_list, maximum result per page is 37
    #puts _search_returns_list.size

    for i in 0..._search_returns_list.size
      _info_song =  _search_returns_list[i].css('div[class = "info_song"]')[0]
      ##detach song name
      _songName = _info_song.css('a[class="name_song"]')[0].text
      #puts _songName
      _singerList = _info_song.css('a[class="name_singer"]')
      _songSinger = ""
      ##detach singer
      for i in 0..._singerList.size
        _songSinger += _singerList[i].text
        if _singerList[i+1] != nil
          _songSinger += ", "
        end
      end
      #puts _songSinger
      ##detach song page
      _songPage = _info_song.css('a[class="name_song"]')[0]['href']
      #puts _songPage
      ##detach url download
      _songID = _search_returns_list[i].css('div[class="box_song_action_search"] > a[class="button_download"]')[0]['key']
      _songSource = "http://m.nhaccuatui.com/song-download?songkey=#{_songID}"
      #puts _songSource
      _song_list.push(Song.new(_songName, _songSinger, "no lyric", _songPage, _songSource, "Nhaccuatui"))
     # puts "============================="
    end
    return _song_list
  end
end


