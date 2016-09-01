class FeatureTagSimilarity < FeatureSpace
  attr_accessor :all_tags, :data

  def name
    "Tag Similarity"
  end

  def map_strategy
    @data = {}
    @all_tags = []
    @original_data["artists"].each do |d|
      @data[d["slug"]] = d["genres"]
      @all_tags += d["genres"]
    end
    @all_tags.flatten.sort.uniq!
    return @data
  end

  # all_tags = ["70", "metal", "pop", "rock"]
  # element1 = ["rock", "metal"]
  # element2 = ["pop", "70"]
  def distance_strategy(element1, element2)
    # plots elements in a tag-space [0, 1, 0, 1], [1, 0, 1, 0]
    t1, t2 = tags_to_point(element1), tags_to_point(element2)
    euclidean_distance(t1, t2)
  end

  def tags_to_point(tags_set)
    all_tags.map{ |c| tags_set.member?(c) ? 1 : 0 }
  end

  def euclidean_distance(a, b)
    sq = a.zip(b).map{|a,b| (a - b) ** 2}
    Math.sqrt(sq.inject(0) {|s,c| s + c})
  end
end
