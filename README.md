# json-compressor
===

This is a tool for compressing and decompressing JSON objects. The compression is made in order to generate a smaller stringified version of the JSON object.

Compression is done in such a way that all (or none) keys will be replaced by numbers. The information how to undo that replacement is stored in an array which is added to the JSON and has a special key.

If the compression would cause the JSON to become bigger no compression is done.


## Usage


### Static

`JSONCompressor.compress(JSON json, bool inPlace = false, String key)`

`JSONCompressor.decompress(JSON json, bool inPlace = false, String key)`

#### Description

Parameters:

1. `JSON` json
   
   A JSON object that's supposed to be compressed or decompressed relatively.
   
2. `bool` inPlace
	
   If `false` the original JSON will be untouched. So in that case the compression is done with a copy of the passed argument.
   
   Otherwise the passed JSON object will be modified.
   
3. `String` key
   
   That parameter defines the *special key* from above. The default key is `__m` so if you know what you're doing you can use a shorter key to save 2 more characters. ;)


### Object-like


#### Constructor

`new JSONCompressor(bool inPlace = false, String key)`

#### Description

Creates a new JSONCompressor instance. One might think it is pointless to create an instance that basically executes static methods but if you want different types of compression you could consider it. This let's you have control over `inPlace` and `key` - so in case you want to have different keys for example things should get more comfortable for you.


#### Methods

`jsonCompressor.compress(JSON json)`

`jsonCompressor.decompress(JSON json)`

#### Description

The 2 instance methods are just calling their corresponding static method. `json` is just passed and for `inPlace` and `key` the object's properties are used.


## Notes

When `inPlace = true` compressing a JSON will be about 99.5% faster.