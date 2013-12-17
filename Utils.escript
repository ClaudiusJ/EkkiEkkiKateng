/* ----------------------------------------------------------------
	This file is part of the EkkiEkkiKateng build tool.
	Copyright (C) 2013 Claudius Jähn (claudiusj@users.berlios.de)
	Licensed under the MIT License. See LICENSE file for details.
	https://github.com/ClaudiusJ/EkkiEkkiKateng
   ---------------------------------------------------------------- */

assert(EScript.VERSION>=607); // 0.6.7

static Constants = Std.require('EkkiEkkiKateng/Constants');

var Utils = new Namespace;
Utils.collectNodesOfType := fn(Array rootPath, type){
	var resultPaths = [];
	var todo = [ rootPath ];
	while(!todo.empty()){
		var activePath = todo.popFront();
		var node = activePath.back();
		if( node.getLocalOption(Constants.NODE_TYPE) == type ){
			resultPaths += activePath.clone();
		}
		foreach(node.getNextNodes() as var nextNode){
			var p = activePath.clone();
			p += nextNode;
			todo += p;
		}
	}
	return resultPaths;
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
