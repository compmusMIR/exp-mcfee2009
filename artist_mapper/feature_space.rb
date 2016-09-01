class FeatureSpace
  attr_accessor :original_data, :data, :computed_distances

  def name
    "nil"
  end

  def initialize(original_data)
    @original_data = original_data
    @data = map_strategy
  end

  def filename
    return self.class.name.underscore
  end

  def map_strategy
    raise "Needs to be overriden"
  end

  def distance_strategy(element1, element2)
    raise "Needs to be overriden"
  end

  def distance(element1_key, element2_key, normalized=false)
    keys = [element1_key, element2_key].sort
    @computed_distances["#{keys.first}_#{keys.last}"]
  end

  def compute_distances
    minabsval, maxabsval = 1000000, -10000000
    @computed_distances = {}
    c = @data.keys.count
    @data.keys.each_with_index do |element_a, idx|
      @data.keys.each_with_index do |element_b, idx2|
        sorted_keys = [element_a, element_b].sort
        d = distance_strategy(@data[element_a], @data[element_b])
        minabsval = [d, minabsval].min
        maxabsval = [d, maxabsval].max
        @computed_distances["#{sorted_keys.first}$$$#{sorted_keys.last}"] = { absolute: d }
      end
      puts "Progress for feature space: #{name}: #{((idx/c.to_f)*100).to_i}%"
    end

    compute_normalised_distances(minabsval, maxabsval)
  end

  def compute_normalised_distances(minabsval, maxabsval)
    puts "... calculating normalized values..."
    xmin =  10000
    xmax = -10000

    @computed_distances.keys.each do |key|
      xmin = [@computed_distances[key][:absolute], xmin].min
      xmax = [@computed_distances[key][:absolute], xmax].max
    end
    @computed_distances.keys.each do |key|
      @computed_distances[key][:normalised] = normalise(@computed_distances[key][:absolute], xmin, xmax)
    end
  end

  def normalise(x, xmin, xmax)
    (x - xmin) / (xmax - xmin)
  end

end

# {abba: ["pop", "70"], metallica: ["rock", "metal"] }


