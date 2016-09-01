require './f_classifier.rb'

obj = FClassifier.new('../music_grabber_data.json')

obj.load_feature_spaces([:tag_similarity])
obj.weights[:tag_similarity] = 1.0
obj.weights[:other_feature_space] = 1.0 	# as a pertinence degree for each feature space

obj.compute_feature_space_distances
obj.compute_overall_distance
obj.calculate_element_space
obj.make_som
binding.pry
