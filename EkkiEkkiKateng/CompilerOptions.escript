/* ----------------------------------------------------------------
	This file is part of the EkkiEkkiKateng build tool.
	Copyright (C) 2013-2014 Claudius Jähn (ClaudiusJ@live.de)
	Licensed under the MIT License. See LICENSE file for details.
	https://github.com/ClaudiusJ/EkkiEkkiKateng
   ---------------------------------------------------------------- */
var CompilerOptions = new Namespace;

static Utils = module('./Utils');

CompilerOptions.getOptions := fn(path){	return Utils.findOptions(path, $COMPILER_OPTIONS);	};

CompilerOptions.addOption := 	fn(pathOrNode, String value){	Utils.addOption(pathOrNode,$COMPILER_OPTIONS,value); };
CompilerOptions.addOptions := 	fn(pathOrNode, Array values){	Utils.addOptions(pathOrNode,$COMPILER_OPTIONS,values); };

CompilerOptions.addDefine := 	fn(pathOrNode, String define){	Utils.addOption(pathOrNode,$COMPILER_OPTIONS,"-D"+define); };

CompilerOptions.getSearchPaths :=	fn(pathOrNode){		return Utils.findOptions(pathOrNode, $COMPILER_OPTIONS_INCLUDE_PATH);	};
CompilerOptions.addSearchPath := 	fn(pathOrNode, String folder){	Utils.addOption(pathOrNode,$COMPILER_OPTIONS_INCLUDE_PATH,folder); };


CompilerOptions.getCompilerId := fn(pathOrNode,p...){	return Utils.findOption(pathOrNode, $COMPILER_ID, p...);	};
CompilerOptions.setCompilerId := fn(pathOrNode,String id){	return Utils.setOption(pathOrNode, $COMPILER_ID, id);	};

return CompilerOptions;
