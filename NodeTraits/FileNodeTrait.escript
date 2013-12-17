/* ----------------------------------------------------------------
	This file is part of the EkkiEkkiKateng build tool.
	Copyright (C) 2013 Claudius J�hn (claudiusj@users.berlios.de)
	Licensed under the MIT License. See LICENSE file for details.
	https://github.com/ClaudiusJ/EkkiEkkiKateng
   ---------------------------------------------------------------- */

assert(EScript.VERSION>=607); // 0.6.7

var t = new (Std.require('Std/Traits/GenericTrait'))('EkkiEkkiKateng.FileNodeTrait');

static Node = Std.require('EkkiEkkiKateng/Node');

t.onInit += fn(Node node, String fileName){
	var Constants = Std.require('EkkiEkkiKateng/Constants');
	Std.require('Std/Traits/basics').addTrait(node,Std.require('EkkiEkkiKateng/NodeTraits/_SpecificNodeTrait'),Constants.NODE_TYPE_FILE);
	node.setOption( Constants.FILE_NAME, fileName);
};
return t;