/* ----------------------------------------------------------------
	This file is part of the EkkiEkkiKateng build tool.
	Copyright (C) 2013-2014 Claudius Jähn (ClaudiusJ@live.de)
	Licensed under the MIT License. See LICENSE file for details.
	https://github.com/ClaudiusJ/EkkiEkkiKateng
   ---------------------------------------------------------------- */

assert(EScript.VERSION>=701); // 0.7.1

static Node = new Type;
Node._printableName @(override) ::= $EkkiEkkiKateng_Node;
Node.options @(init) := Map;
Node.incrementalOptions @(init) := Map;
Node.nextNodes @(init) := module('Std/Set');
Node.sortedNextNodes @(init) := Array;
Node.transient := true;

Node.addOptions ::= fn([Identifier,String] key,Array values){
	if(!this.incrementalOptions[key])
		this.incrementalOptions[key] = [];
	this.incrementalOptions[key].append(values);
};
Node.addOption ::= fn([Identifier,String] key,value){
	this.addOptions(key,[value]);
};

Node.getNextNodes ::= fn(){
	return this.sortedNextNodes;
};
Node.getLocalOption ::= fn([Identifier,String] key){
	return this.options[key];
};
Node.hasLocalOption ::= fn([Identifier,String] key){
	return this.options.containsKey(key);
};
Node.setOption ::= fn([Identifier,String] key,value){
	this.options[key] = value;
};
Node.isTransient ::= fn(){
	return this.transient;
};
Node.toDbgString ::= fn(){
	var s = "Node("+ toJSON(this.options,false)+", "+toJSON(this.incrementalOptions,false)+","+this.nextNodes.count()+" children";
//	foreach(this.nextNodes as var n){
//		s+="\n-> "+n.toDbgString();
//	}
	s+=")";
	return s;
};
Node.setTransient ::= fn(Bool b){
	this.transient = b;
};
Node."+=" ::= fn(Node other){
	if(!this.nextNodes.contains(other)){
		this.nextNodes += other;
		this.sortedNextNodes += other;
	}
	return this;
};

return Node;