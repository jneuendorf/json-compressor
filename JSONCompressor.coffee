class window.JSONCompressor
	DEFAULT_KEY	= "__m"

	traverse = (json, callback) ->
		helper = (k, v, obj) =>
			# recursion
			if v instanceof Object
				traverse(v, callback)

			# execute callback function
			callback?(k, v, obj)
			return @
		##############

		# time: 457 ms
		if json instanceof Array
			for val, idx in json
				helper(idx, val, json)

		else if json instanceof Object
			for key, val of json
				helper(key, val, json)
		return @

	# BEGIN - STATIC FUNCTIONS
	# @compress: (json, compressFunc, inPlace = false, key = DEFAULT_KEY) ->
	@compress: (json, inPlace = false, key = DEFAULT_KEY) ->
		# if not modifying the original json -> make a copy
		if inPlace is false
			json	= JSON.parse JSON.stringify(json)

		# get count of each (unique) key
		counts = {}
		traverse json, (k, v, obj) ->
			if obj not instanceof Array
				if counts[k]?
					counts[k]++
				else
					counts[k] = 1
			return true

		# make array and sort it descending
		# this sorting determines how the compression goes (key assignment)
		sorted = []
		for name, count of counts
			sorted.push {name: name, count: count}

		sorted.sort (a, b) ->
			if a.count < b.count
				return 1
			if b.count < a.count
				return -1
			return 0

		# new map / array creation
		map = []
		# charsSaved tells us whether the compression, we are about to make, will make sense; 1 char = 2 bytes
		charsSaved = -4 - key.length # those chars will be lost: ",__m:[]"
		for elem in sorted
			nameLength = elem.name.length
			charsSaved += (nameLength - "#{map.length}".length) * elem.count - nameLength - 1
			map.push elem.name

		# console.log map, charsSaved, key

		# check if current map would really compress the object
		# compression is good => rename the keys
		if charsSaved > 0
			# make replacement
			traverse json, (k, v, obj) ->
				# renameKeys(k, v, obj, map)
				if obj not instanceof Array
					obj[map.indexOf k] = obj[k]
					delete obj[k]
			# json[key] = invertKeyValue map # map is not needed because the mapping is predefined (base62)
			json[key] = map

		# compression is bad => leave json as it is
		return json


	@decompress: (json, inPlace = false, key = DEFAULT_KEY) ->
		# if not modifying the original json -> make a copy
		if inPlace is false
			json	= JSON.parse JSON.stringify(json)

		# mod. indicator is set => actual decompression
		if (map = json[key])?
			traverse json, (k, v, obj) ->
				if k isnt key
					obj[map[k]] = obj[k]
					delete obj[k]

		# else: no decompression
		return json
	# END - STATIC FUNCTIONS


	# CONSTRUCTOR
	constructor: (@inPlace = false, @key = DEFAULT_KEY) ->
		if @inPlace isnt false
			@inPlace = true

		if @key not instanceof String
			@key = DEFAULT_KEY

	# INSTANCE METHODS
	compress: (json) ->
		return JSONCompressor.compress json, @inPlace, @key

	decompress: (json) ->
		return JSONCompressor.decompress json, @inPlace, @key

	test: (n = 100, inPlace = false) ->
		s	= Date.now()
		for i in [0...n]
			compressed		= @compress bigJSON, inPlace
			decompressed	= @decompress compressed, inPlace
		e	= Date.now()
		console.log e-s


	# ALPHABET		= "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	# decToBase62 = (dec) ->
	# 	# find highest power of 62 so that 62^p <= dec
	# 	divisor = 1 # 62^0
	# 	while (temp = divisor * 62) < dec
	# 		divisor = temp

	# 	if dec is 0
	# 		return "0"

	# 	res = ""
	# 	while dec > 0
	# 		digit		= Math.floor dec / divisor
	# 		dec			= dec % divisor
	# 		divisor		/= 62
	# 		res			+= ALPHABET[digit]

	# 	return res

	# base62ToDec = (base62) ->
	# 	res	= 0
	# 	i	= base62.length
	# 	for char in base62
	# 		res += Math.pow(62, --i) * ALPHABET.indexOf(char)

	# 	return res

	# only usable for the mapping hash needed for compressing/decompressing!
	# invertKeyValue = (json) ->
	# 	res = {}
	# 	for k, v of json
	# 		res[v] = k
	# 	return res

	# renameKeys = (k, v, obj, map) ->
	# 	if obj not instanceof Array
	# 		# obj[map[k]] = obj[k] # in case map is a hash
	# 		obj[map.indexOf k] = obj[k]
	# 		delete obj[k]
	# 	return @