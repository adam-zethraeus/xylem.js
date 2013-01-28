class ResourceLoader
	
	#TODO: add failure callback

	constructor: (loadRules, resourceReturnCallback)->
		@barrier = new Barrier()
		@resources = {}
		for rule in loadRules
			if rule["type"] is "image"
				this.loadImage(rule.name, rule.url, @barrier.getCallback())
			else if rule["type"] is "text"
				this.loadText(rule.name, rule.url, @barrier.getCallback())
			else if rule["type"] is "json"
				this.loadJSON(rule.name, rule.url, @barrier.getCallback())
			else 
				throw "Invalid load rule type."
		@barrier.finalize(()=>
			resourceReturnCallback(@resources)
		)

	#TODO: register failure case.
	loadImage: (name, url, callback)->
		image = new Image()
		image.onload = ()=>
			@resources[name] = image
			callback()
		image.src = url


	loadText: (name, url, callback)->
		httpRequest = new XMLHttpRequest()
		httpRequest.addEventListener(
			"readystatechange"
			() =>
				return null if httpRequest.readyState isnt 4
				if httpRequest.status is 200
					@resources[name] = httpRequest.responseText
					callback()
				else
					throw "Resource "+url+" could not be downloaded."
		)
		httpRequest.open("GET", url, true)
		httpRequest.send()

	loadJSON: (name, url, callback)->
		httpRequest = new XMLHttpRequest()
		httpRequest.addEventListener(
			"readystatechange"
			() =>
				return null if httpRequest.readyState isnt 4
				if httpRequest.status is 200
					@resources[name] = JSON.parse(httpRequest.responseText)
					callback()
				else
					throw "Resource "+url+" could not be downloaded."
		)
		httpRequest.open("GET", url, true)
		httpRequest.send()