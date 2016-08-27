require 'rspotify'
require 'json'
require 'pry'

class MusicGrabber
  attr_accessor :aset400, :triplets, :data
  def initialize
    @aset400 = fetch_aset400
    @triplets = fetch_triplets
    @data = get_data
  end


  def play
    read_artists
    download_music
  end

  def read_artists
    (puts "Skipping artists" ; return) if !@data[:artist_complete]
    puts "Reading artists..."
    achieved = @data[:last_artist].nil?
    @aset400.each_with_index do |artist, idx|
      achieved ||= (artist.last == @data[:last_artist])
      if !achieved
        puts "skip #{artist.last}"
        next
      end
      puts "ok - #{idx}"
      create_artist(artist)
    end
    @data[:artist_complete] = true
    @data.save
    true
  end

  def download_music
    puts "Downloading music"
    (puts "Skipping artists" ; return) if !@data[:music_complete]
    achieved = @data[:last_artist_with_song].nil?
    @aset400.each_with_index do |aset400_artist, idx|
      achieved ||= (aset400_artist.last == @data[:last_artist_with_song])
      if !achieved
        puts "skip #{artist.last}"
        next
      end
      puts "ok - #{idx}"
      artist = @data[:artists].select{|s| s["aset_id"]== 5}.first rescue nil
      download_artist_music(artist) unless artist.nil?
    end
    @data[:music_complete] = true
    @data.save
    true
  end

  def download_artist_music(artist)
    puts "name: #{artist[:name]}"
    `mkdir -p ./data/#{artist[:name]}`
    artist["tracks"].each_with_index do |track, idx|
      #todo: não está fazendo corretamente o download
      `wget #{track['preview_url']} -O ./#{artist[:name]}/#{idx}.mp3`
    end
  end

  def create_artist(aset_artist)
    puts "--- Reading #{aset_artist.last} ---"
    artist = {
      aset_id: aset_artist.first,
      spotify_id: nil,
      slug: aset_artist.last,
      name: nil,
      keywords: [],
      tags: [],
      genres: [],
      href: nil,
      tracks: [],
      followers: 0,
      songs_grabbed: false
    }
    collect_spotify_data(artist)
    persist_artist(artist)
    puts "ok2"
  end

  def persist_artist(artist)
    @data[:artists].push(artist)
    @data[:last_artist] = artist[:slug]
    save_data
  end


  def collect_spotify_data(artist)
    spotify_artist = RSpotify::Artist.search(artist[:slug].tr("_", " ")).first
    if spotify_artist.nil?
      artist[:error] = true
      return
    end

    puts "name: #{spotify_artist.name}, id: #{spotify_artist.id}"
    artist[:name] = spotify_artist.name
    artist[:spotify_id] = spotify_artist.id
    artist[:followers] = spotify_artist.followers["total"]
    artist[:spotify_id] = spotify_artist.id
    artist[:href] = spotify_artist.href
    artist[:genres] = spotify_artist.genres
    tracks = spotify_artist.top_tracks(:US).to_a[0..3]
    tracks.each do |track|
      artist[:tracks] = tracks.map{|s| {preview_url: s.preview_url, name: s.name, id: s.id } }
    end
  end


  def get_data
    puts "collecting grabber data"
    begin
      json = JSON.parse(File.read('music_grabber_data.json'))
      json = json.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      json[:artists].uniq!
      json
    rescue
      reset_data
    end
  end

  def save_data
    puts "(saved)"
    File.open("music_grabber_data.json","w") do |f|
      f.write(@data.to_json)
    end
  end

  def reset_data
    @data = {
      last_artist: nil,
      last_artist_with_song: nil,
      artist_complete: false,
      music_complete: false,
      tags_complete: false,
      text_complete: false,
      artists: []
    }
    save_data
    @data
  end

  def fetch_aset400
    puts "collecting data from ASET400"
    arr = []
    File.read('aset400.3-canon-musicseer.ids').split("\n").map do |rs|
      a = rs.split(" ")
      arr.push([a[1].to_i, a[0]])
    end
    arr
  end
  def fetch_triplets
    puts "collecting triplets"
    File.read('filtered-survey.txt').split("\n").map do |triplet_rs|
      t = triplet_rs.split(" ")[3..5]
    end
  end

end





mg = MusicGrabber.new
binding.pry
