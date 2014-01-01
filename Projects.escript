/* ----------------------------------------------------------------
	This file is part of the EkkiEkkiKateng build tool.
	Copyright (C) 2013 Claudius Jähn (claudiusj@users.berlios.de)
	Licensed under the MIT License. See LICENSE file for details.
	https://github.com/ClaudiusJ/EkkiEkkiKateng
   ---------------------------------------------------------------- */
var Projects = new Namespace;


static Node = Std.require('EkkiEkkiKateng/Node');
static Utils = Std.require('EkkiEkkiKateng/Utils');

Projects.createNode := fn(name=void){
	var n = new Node;
	n.setOption( $IS_PROJECT, true);
	if(name)
		n.setOption( $PROJECT_NAME, name);
	return n;
};

Projects.collect := fn(pathOrNode){	return Utils.collectNextHavingOption(pathOrNode,$IS_PROJECT);	};
Projects.getName := fn(pathOrNode){	return Utils.findOption(pathOrNode, $PROJECT_NAME);	};

return Projects;