class Song 
  @name = ""
  @artist = ""
  @lyric = ""
  @url_page = ""
  @url_source = ""
  @provider = ""
  attr_accessor :name, :artist, :lyric, :url_page, :url_source,  :provider

  def def initialize(name, artist, lyric, page, source, provider)
    @name = name
    @artist = artist
    @lyric = lyric
    @url_page = page
    @url_source = source
    @provider = provider
  end
  
end
