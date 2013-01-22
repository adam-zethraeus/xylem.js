function browserVersionOf(unprefixedName, parentObject) {
	// parentObject is optional and usually omitted, set it to window if it's not specified.
	parentObject = parentObject || window;
	var browserVersions = [], i;
	browserVersions.push(unprefixedName);
	browserVersions.push("ms" + unprefixedName.charAt(0).toUpperCase() + unprefixedName.substring(1));
	browserVersions.push("moz" + unprefixedName.charAt(0).toUpperCase() + unprefixedName.substring(1));
	browserVersions.push("webkit" + unprefixedName.charAt(0).toUpperCase() + unprefixedName.substring(1));
	browserVersions.push("o" + unprefixedName.charAt(0).toUpperCase() + unprefixedName.substring(1));
	for (i = 0; i < browserVersions.length; i++) {
		if (typeof parentObject[browserVersions[i]] === "function") {
			return parentObject[browserVersions[i]];
		}
	}
	throw "Browser lacks function: "+ unprefixedName;
}