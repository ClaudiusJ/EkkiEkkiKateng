/* ----------------------------------------------------------------
	This file is part of the EkkiEkkiKateng build tool.
	Copyright (C) 2013 Claudius Jähn (claudiusj@users.berlios.de)
	Licensed under the MIT License. See LICENSE file for details.
	https://github.com/ClaudiusJ/EkkiEkkiKateng
   ---------------------------------------------------------------- */
var Files = new Namespace;

static Node = Std.require('EkkiEkkiKateng/Node');
static Utils = Std.require('EkkiEkkiKateng/Utils');

Files.createNode := fn(name=void){
	var n = new Node;
	n.setOption( $IS_FILE, true);
	if(name)
		n.setOption( $FILE_NAME, name);
	return n;
};

Files.collect := fn(pathOrNode){	return Utils.collectNextHavingOption(pathOrNode,$IS_FILE);	};
Files.getName := fn(pathOrNode){	return Utils.findOption(pathOrNode, $FILE_NAME);	};

return Files;