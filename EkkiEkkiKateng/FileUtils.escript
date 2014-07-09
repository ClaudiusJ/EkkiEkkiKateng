/* ----------------------------------------------------------------
	This file is part of the EkkiEkkiKateng build tool.
	Copyright (C) 2013-2014 Claudius Jähn (ClaudiusJ@live.de)
	Licensed under the MIT License. See LICENSE file for details.
	https://github.com/ClaudiusJ/EkkiEkkiKateng
   ---------------------------------------------------------------- */

assert(EScript.VERSION>=701); // 0.7.1

var FileUtils = new Namespace;

static scanFiles = fn(String sourceDir, [void,Array] endings=void){
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
FileUtils.scanFiles := scanFiles;

FileUtils.scanForKeywords := fn(String prefix, String path, Array endings){
	var defines = new (module('Std/Set'));
	foreach(scanFiles(path, endings) as var filename){
		var file = IO.loadTextFile(filename);
		var pos = 0;
		while(pos = file.find(prefix,pos)){
			pos+=prefix.length();
			var s = prefix;
			for( var c = file[pos]; (c>='A'&&c<='Z') || (c>='a'&&c<='z') ||(c>='0'&&c<='9') || c=='_'; c = file[++pos])
				s+= file[pos];
			defines+=s;
		}
	}
	return defines.toArray();
};

return FileUtils;
