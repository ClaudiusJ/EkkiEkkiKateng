/* ----------------------------------------------------------------
	This file is part of the EkkiEkkiKateng build tool.
	Copyright (C) 2013 Claudius Jähn (claudiusj@users.berlios.de)
	Licensed under the MIT License. See LICENSE file for details.
	https://github.com/ClaudiusJ/EkkiEkkiKateng
   ---------------------------------------------------------------- */

assert(EScript.VERSION>=607); // 0.6.7

var t = new (Std.require('Std/Traits/GenericTrait'))('EkkiEkkiKateng.FileNodeTrait');

static Node = Std.require('EkkiEkkiKateng/Node');
static Constants = Std.require('EkkiEkkiKateng/Constants');

t.attributes.getFilename ::= fn(){
	return this.getLocalOption( Constants.NAME );
};

t.onInit += fn(Node node, String fileName){
	Std.require('Std/Traits/basics').addTrait(node,Std.require('EkkiEkkiKateng/NodeTraits/_SpecificNodeTrait'),Constants.NODE_TYPE_FILE);
	node.setOption( Constants.NAME, fileName);
};
return t;
