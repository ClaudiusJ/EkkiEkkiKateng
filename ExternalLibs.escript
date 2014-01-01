/* ----------------------------------------------------------------
	This file is part of the EkkiEkkiKateng build tool.
	Copyright (C) 2013 Claudius J�hn (claudiusj@users.berlios.de)
	Licensed under the MIT License. See LICENSE file for details.
	https://github.com/ClaudiusJ/EkkiEkkiKateng
   ---------------------------------------------------------------- */
var ExternalLibs = new Namespace;

static Node = Std.require('EkkiEkkiKateng/Node');
static Utils = Std.require('EkkiEkkiKateng/Utils');

ExternalLibs.createNode := fn(name=void){
	var n = new Node;
	n.setOption( $IS_EXTERNAL_LIB, true);
	if(name)
		n.setOption( $EXTERNAL_LIB_NAME, name);
	n.setTransient(false);
	return n;
};

ExternalLibs.collect := fn(pathOrNode){	return Utils.collectNextHavingOption(pathOrNode,$IS_EXTERNAL_LIB);	};
ExternalLibs.getName := fn(pathOrNode){	return Utils.findOption(pathOrNode, $EXTERNAL_LIB_NAME);	};

return ExternalLibs;
