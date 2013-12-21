/* ----------------------------------------------------------------
	This file is part of the EkkiEkkiKateng build tool.
	Copyright (C) 2013 Claudius Jähn (claudiusj@users.berlios.de)
	Licensed under the MIT License. See LICENSE file for details.
	https://github.com/ClaudiusJ/EkkiEkkiKateng
   ---------------------------------------------------------------- */

assert(EScript.VERSION>=607); // 0.6.7

static Node = Std.require('EkkiEkkiKateng/Node');
static Constants = Std.require('EkkiEkkiKateng/Constants');
static Traits = Std.require('Std/Traits/basics');

/*! (internal) if callback(node) returns...
		$BREAK, the traversal of the subtree is stopped.
		$EXIT, the traversal is stopped.
		something else, the traversal continues.	*/
static traverse = fn(Node rootNode, callback){
	var todo = [ rootNode ];
	while(!todo.empty()){
		var node = todo.popFront();
		switch(callback(node)){
			case $BREAK:
				continue;
			case $EXIT:
				return;
			default:
				foreach(node.getNextNodes() as var nextNode)
					todo += nextNode;
		}
	}
};
/*! (internal) if callback(path) returns...
		$BREAK, the traversal of the subtree is stopped.
		$EXIT, the traversal is stopped.
		something else, the traversal continues.	*/
static traverseWithPath = fn(Array rootPath, callback){
	var todo = [ rootPath ];
	while(!todo.empty()){
		var activePath = todo.popFront();
		switch(callback(activePath)){
			case $BREAK:
				continue;
			case $EXIT:
				return;
			default:
				foreach(activePath.back().getNextNodes() as var nextNode){
					var p = activePath.clone();
					p += nextNode;
					todo += p;
				}
		}
	}
};


var Utils = new Namespace;

Utils.collectNodePathsOfType := fn(Array rootPath, type){
	var resultPaths = [];
	traverseWithPath(rootPath, [resultPaths,type] => fn(resultPaths,type, path){
		if( path.back().getLocalOption(Constants.NODE_TYPE) == type )
			resultPaths += path.clone();
	});
	return resultPaths;
};

Utils.collectNodePathsByTrait := fn(Array rootPath, Traits.Trait trait){
	var resultPaths = [];
	traverseWithPath(rootPath, [resultPaths,trait] => fn(resultPaths,trait, path){
		if( Traits.queryTrait(path.back(), trait) )
			resultPaths += path.clone();
	});
	return resultPaths;
};

Utils.collectNodesByTrait := fn(Node rootNode, Traits.Trait trait){
	var resultNodes = [];
	traverse(rootNode, [resultNodes,trait] => fn(resultNodes,trait,node){ if(Traits.queryTrait(node,trait)) resultNodes += node; });
	return resultNodes;
};

Utils.collectNodesByType := fn(Node rootNode, type){
	var resultNodes = [];
	traverse(rootNode, [resultNodes,type] => fn(resultNodes,type,node){ if(node.getLocalOption(Constants.NODE_TYPE)==type) resultNodes += node; });
	return resultNodes;
};

static findOptions = fn(Array path, [Identifier,String] key){
	var options = [];
	path = path.clone();
	for(var node = path.popBack(); node; node = path.popBack()){
		if(node.options.containsKey(key)){
			options.pushFront(node.options[key]);
			break;
		}else if(node.incrementalOptions.containsKey(key)){
			options = node.incrementalOptions[key].clone().append(options);
		}
	}
	return options;
};
Utils.findOptions := findOptions;
Utils.findOption := fn(Array path, [Identifier,String] key, default=void){
	var options = findOptions(path,key);
	return options.empty() ? default : options.implode(" ");
};
Utils.scanFiles := fn(String sourceDir, [void,Array] endings=void){
	sourceDir = IO.condensePath(sourceDir);
	if(sourceDir.empty())
		sourceDir = ".";
	var allFiles = IO.dir(sourceDir,IO.DIR_RECURSIVE|IO.DIR_FILES).map(
					fn(key,path){return path.beginsWith("./") ? path.substr(2):path; });
	if(!endings)
		return allFiles;

	var files = [];
	foreach(allFiles as var file){
		foreach(endings as var e){
			if(file.endsWith(e)){
				files += file;
				break;
			}
		}
	}
	return files;
};

return Utils;
