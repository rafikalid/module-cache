###*
 * LRU & TTL fast module cache
###
LRU_TTL= require 'lru-ttl-cache'
Fs=	require 'fs'
MzFs= require 'mz/fs'
Path= require 'path'
Vm= require 'vm'

DEFAULT_OPTIONS=
	timeout: 60000 # 1min

module.exports= class ModuleCache extends LRU_TTL
	###*
	 * LRU & TTL cache
	 * @param  {Integer} options.max		- Max entries in the cache. @default Infinity
	 * @param  {Integer} options.maxBytes	- Cache max size before removing elements. @default Infinity
	 * @param  {Integer} options.ttl		- Timeout before removing entries. @default Infinity
	 * @param  {Integer} options.interval	- TTL check interval. @default options.ttl
	 *
	 * @param {integer} options.timeout  - Module execution timeout in milliseconds, @default 60s
	 * @return {[type]}         [description]
	###
	constructor: (options)->
		if options
			options.timeout ?= DEFAULT_OPTIONS.timeout
		else
			options= DEFAULT_OPTIONS
		super options
		return

	###*
	 * Prevent using "set"
	###
	set: -> throw new Error '"set" not supported. Please use "get" instead.'
	###*
	 * Get entry
	###
	require: (filePath)-> @get(filePath)
	get: (filePath)->
		filePath= Path.resolve filePath
		unless data= super.get filePath
			buffer= await MzFs.readFile filePath
			data= @_get filePath, buffer
		return data

	requireSync: (filePath)-> @getSync(filePath)
	getSync: (filePath)->
		filePath= Path.resolve filePath
		unless data= super.get filePath
			buffer= Fs.readFileSync filePath
			data= @_get filePath, buffer
		return data

	_get: (filePath, buffer)->
		data= buffer.toString('utf8')
		switch Path.extname(filePath).toLowerCase()
			when '.json'
				data= JSON.parse(data)
			when '.js'
				mod=
					exports: null
					require: require
				ctx=
					module: mod
					exports: mod.exports
					require: require
					__filename: filePath
					__dirname: Path.dirname(filePath)

				Vm.runInContext data, (Vm.createContext ctx),
					filename:	filePath
					timeout:	@_timeout
				data= ctx.module.exports
			else
				throw new Error "Unsupported file: #{filePath}"
		# save file to cache
		super.set filePath, data, buffer.length
		# return the result
		return data
	
	###*
	 * Set contig
	###
	setConfig: (options)->
		if options
			try
				super.setConfig options
				if vl= options.timeout
					throw 'Options.timeout expected positive integer' unless (vl is Infinity) or (Number.isSafeInteger(vl) and vl>0)
					@_timeout= vl
			catch err
				err= "Module_CACHE>> #{err}" if typeof err is 'string'
				throw err
		this # chain

