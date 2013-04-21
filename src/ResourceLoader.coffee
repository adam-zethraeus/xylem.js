class ResourceLoader
    
    #TODO: add failure callback

    constructor: ()->
        @barrier = new CallbackBarrier()
        @resources = {}
        @failures = false

    load: (loadRules, resourceReturnCallback)->
        for rule in loadRules
            if rule["type"] is "image"
                @loadImage(rule.name, rule.url, @barrier.getCallback())
            else if rule["type"] is "text"
                @loadText(rule.name, rule.url, @barrier.getCallback())
            else if rule["type"] is "json"
                @loadJSON(rule.name, rule.url, @barrier.getCallback())
            else 
                throw "Invalid load rule type."
        @barrier.finalize(()=>
            resourceReturnCallback(@resources, not @failures)
        )

    #TODO: register failure case.
    loadImage: (name, url, callback)->
        image = new Image()
        image.onload = ()=>
            @resources[name] = image
            callback()
        image.onerror = ()=>
            @resources[name] = null
            @failures = true
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
                    @resources[name] = null
                    @failures = true
                    callback()
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
                    @resources[name] = null
                    @failures = true
                    callback()
        )
        httpRequest.open("GET", url, true)
        httpRequest.send()
