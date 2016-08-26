require 'rspotify'

class MusicGrabber
  def initialize

  end


  def read_artists
    artists = File.open('aset400.txt')
    artists.each do |artist|
      download_artist_tracks(artist)
    end
  end

  def download_artist_tracks(artist_name)
    artist = RSpotify::Artist.search(artist_name.tr("_", " ")).first
    puts "Pegou #{artist_name}"
    puts "Achou #{artist.name}, id: #{artist.id}"
    puts "tracks: #{artist.top_tracks(:US).count}"
  end

end


mg = MusicGrabber.new
mg.read_artists