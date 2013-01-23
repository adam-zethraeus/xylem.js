function browserVersionOf(unprefixedName, parentObject) {
	// parentObject is optional and usually omitted, set it to window if it's not specified.
	parentObject = parentObject || window;
	var versions = [unprefixedName],
		i,
		suffix = unprefixedName.charAt(0).toUpperCase() + unprefixedName.substring(1);
	versions.push("ms" + suffix);
	versions.push("moz" + suffix);
	versions.push("webkit" + suffix);
	versions.push("o" + suffix);
	for (i = 0; i < versions.length; i++) {
		if (typeof parentObject[versions[i]] === "function") {
			return parentObject[versions[i]];
		}
	}
	throw "Browser lacks function: "+ unprefixedName;
}