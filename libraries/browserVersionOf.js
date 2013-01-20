function browserVersionOf(unprefixedName, parentObject) {
	if (typeof parentObject === "undefined") {
		parentObject = window;
	}
	var msName = "ms" + unprefixedName.charAt(0).toUpperCase() + unprefixedName.substring(1);
	var mozName = "moz" + unprefixedName.charAt(0).toUpperCase() + unprefixedName.substring(1);
	var webkitName = "webkit" + unprefixedName.charAt(0).toUpperCase() + unprefixedName.substring(1);
	var oName = "o" + unprefixedName.charAt(0).toUpperCase() + unprefixedName.substring(1);
	if (typeof parentObject[unprefixedName] !== "undefined" && parentObject[unprefixedName] !== null) {
		return parentObject[unprefixedName];
	} else if (typeof parentObject[msName] !== "undefined" && parentObject[msName] !== null) {
		return parentObject[msName];
	} else if (typeof parentObject[mozName] !== "undefined" && parentObject[mozName] !== null) {
		return parentObject[mozName];
	} else if (typeof parentObject[webkitName] !== "undefined" && parentObject[webkitName] !== null) {
		return parentObject[webkitName];
	} else if (typeof parentObject[oName] !== "undefined" && parentObject[oName] !== null) {
		return parentObject[oName]
	} else {
		throw "Browser lacks support for " + unprefixedName;
	}
}