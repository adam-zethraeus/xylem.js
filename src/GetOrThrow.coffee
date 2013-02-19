getOrThrow = (obj, field)->
	if not obj[field]?
		throw new ReferenceError("Object doesn't have '" + field + "' field.")
	return obj[field]
