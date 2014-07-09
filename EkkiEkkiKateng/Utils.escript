/* ----------------------------------------------------------------
	This file is part of the EkkiEkkiKateng build tool.
	Copyright (C) 2013-2014 Claudius Jähn (ClaudiusJ@live.de)
	Licensed under the MIT License. See LICENSE file for details.
	https://github.com/ClaudiusJ/EkkiEkkiKateng
   ---------------------------------------------------------------- */

assert(EScript.VERSION>=701); // 0.7.1

static Node = module('./Node');

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
				if(node.isTransient()){
					foreach(node.getNextNodes() as var nextNode)
						todo += nextNode;
				}
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
				if(activePath==rootPath || activePath.back().isTransient()){
					foreach(activePath.back().getNextNodes() as var nextNode){
						var p = activePath.clone();
						p += nextNode;
						todo += p;
					}
				}
		}
	}
};


var Utils = new Namespace;

Utils.traverseWithPath := traverseWithPath;

Utils.collectNextHavingOption := fn([Array,Node] pathOrNode, option){
	if(pathOrNode---|>Node){
		var resultNodes = [];
		traverse(pathOrNode, [resultNodes,option] => fn(resultNodes,option, node){
			if( node.hasLocalOption(option) ){
				resultNodes += node;
				return $BREAK;
			}
		});
		return resultNodes;
	}else{
		var resultPaths = [];
		traverseWithPath(pathOrNode, [resultPaths,option] => fn(resultPaths,option, path){
			if( path.back().hasLocalOption(option) ){
				resultPaths += path.clone();
				return $BREAK;
			}
		});
		return resultPaths;
	}
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
Utils.findOptions := fn([Array,Node] pathOrNode, p...){
	return pathOrNode---|>Node ? findOptions([pathOrNode],p...) : findOptions(pathOrNode,p...);
};
Utils.findOption := fn([Array,Node] pathOrNode, [Identifier,String] key, default=void){
	if(pathOrNode---|>Node){
		return pathOrNode.hasLocalOption(key) ? pathOrNode.getLocalOption(key) : default;
	}else{
		var options = findOptions(pathOrNode,key);
		return options.empty() ? default : options.implode(" ");
	}
};
Utils.setOption := fn([Array,Node] pathOrNode, key, value){
	if(pathOrNode---|>Node){
		pathOrNode.setOption(key,value);
	}else{
		pathOrNode.back().setOption(key,value);
	}
};
Utils.addOption := fn(pathOrNode,p...){
	if(pathOrNode---|>Node){
		pathOrNode.addOption(p...);
	}else{
		pathOrNode.back().addOption(p...);
	}
};
Utils.addOptions := fn(pathOrNode,p...){
	if(pathOrNode---|>Node){
		pathOrNode.addOptions(p...);
	}else{
		pathOrNode.back().addOptions(p...);
	}
};

return Utils;
