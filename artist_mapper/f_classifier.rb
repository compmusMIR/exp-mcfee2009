require './feature_space.rb'
Dir["./feature_spaces/*.rb"].each {|file| require file }
require 'ai4r'
require 'som'
require 'benchmark'
require 'json'
require 'pry'

class FClassifier
  attr_accessor :data, :feature_spaces, :distances, :weights, :element_space, :som

  def initialize(data_path)
    @data_path = data_path
    @weights = {}
    @feature_spaces = []
    load_elements
  end

  def load_elements
    puts "Loading data"
    @data = JSON.parse(File.read(@data_path))
    @data["artists"] = @data["artists"].select{|s| s["genres"].count > 2} # TODO: remover
    puts "loaded #{ @data["artists"].count }"
  end

  def load_feature_spaces(feature_spaces_keys)
    puts "Loading feature spaces"
    feature_spaces_keys.each{|fs| @feature_spaces.push("feature_#{fs.to_s}".camelize.constantize.new(@data)) }
  end

  def compute_feature_space_distances
    puts "Computing feature space distances"
    Benchmark.bm do |benchmark|
      @feature_spaces.each do |fs|
        benchmark.report("#{fs.name.to_s}") { fs.compute_distances }
      end
    end
  end

  def compute_overall_distance
    puts "Computing overall distances"
    # fs1["abba_metallica"] = 0.23 ;  fs2["abba_metallica"] = 0.81 ...
    @distances = {}
    keys = @feature_spaces.first.computed_distances.keys
    # calculates a weighted avg for all distances
    keys.each do |key|
      @distances[key] = @feature_spaces.map{ |fs| fs.computed_distances[key][:normalised] * weight(fs) }.first
    end
    @distances
  end

  def weight(feature_space)
    feature_space_slug = feature_space.class.name.underscore.gsub("feature_", "").to_sym
    (weights[feature_space_slug] || 1).to_f
  end

  def calculate_element_space
    @element_space = {}
    @data["artists"].each do |i|
      @element_space[i["slug"]] = @data["artists"].map do |j|
        slugs = [i["slug"], j["slug"]].sort
        @distances["#{slugs.first}$$$#{slugs.last}"]
      end
    end
    @element_space
  end

  def make_som
    content = @element_space.keys.map{|s| @element_space[s]}
    @som = Ai4r::Som::Som.new @data["artists"].count, @data["artists"].count, Ai4r::Som::TwoPhaseLayer.new(@data["artists"].count)
    @som.initiate_map
    puts "Training SOM..."
    @som.train content
    puts "done"
  end

end


class String
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end

  def camelize
    self.split('_').map {|w| w.capitalize}.join
  end

  def constantize
    Object::const_get(self)
  end
end
