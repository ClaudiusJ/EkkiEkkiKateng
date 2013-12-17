/* ----------------------------------------------------------------
	This file is part of the EkkiEkkiKateng build tool.
	Copyright (C) 2013 Claudius Jähn (claudiusj@users.berlios.de)
	Licensed under the MIT License. See LICENSE file for details.
	https://github.com/ClaudiusJ/EkkiEkkiKateng
   ---------------------------------------------------------------- */

assert(EScript.VERSION>=607); // 0.6.7

static Node = new Type;
Node._printableName @(override) ::= $EkkiEkkiKateng_Node;
Node.options @(init) := Map;
Node.incrementalOptions @(init) := Map;
Node.nextNodes @(init) := Std.require('Std/Set');

Node.addOptions ::= fn([Identifier,String] key,Array values){
	if(!this.incrementalOptions[key])
		this.incrementalOptions[key] = [];
	this.incrementalOptions[key].append(values);
};
Node.addOption ::= fn([Identifier,String] key,value){
	this.addOptions(key,[value]);
};

Node.getNextNodes ::= fn(){
	return this.nextNodes;
};
Node.getLocalOption ::= fn([Identifier,String] key){
	return this.options[key];
};
Node.setOption ::= fn([Identifier,String] key,value){
	this.options[key] = value;
};
Node.toDbgString ::= fn(){
	var s = "Node("+ toJSON(this.options,false)+", "+toJSON(this.incrementalOptions,false);
	foreach(this.nextNodes as var n){
		s+="\n-> "+n.toDbgString();
	}
	s+=")";
	return s;
};
Node."+=" ::= fn(Node other){
	this.nextNodes += other;
	return this;
};

return Node;