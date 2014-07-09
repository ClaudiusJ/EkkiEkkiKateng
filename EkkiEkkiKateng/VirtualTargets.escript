/* ----------------------------------------------------------------
	This file is part of the EkkiEkkiKateng build tool.
	Copyright (C) 2013-2014 Claudius Jähn (ClaudiusJ@live.de)
	Licensed under the MIT License. See LICENSE file for details.
	https://github.com/ClaudiusJ/EkkiEkkiKateng
   ---------------------------------------------------------------- */
var VirtualTargets = new Namespace;

static Node = module('./Node');
static Utils = module('./Utils');

VirtualTargets.createNode := fn(name=void){
	var n = new Node;
	n.setOption( $IS_VIRTUAL_TARGET, true);
	if(name)
		n.setOption( $VIRTUAL_TARGET_NAME, name);
	n.setTransient(false);
	return n;
};

VirtualTargets.collect := fn(pathOrNode){	return Utils.collectNextHavingOption(pathOrNode,$IS_VIRTUAL_TARGET);	};
VirtualTargets.getName := fn(pathOrNode){	return Utils.findOption(pathOrNode, $VIRTUAL_TARGET_NAME);	};

return VirtualTargets;