/* ----------------------------------------------------------------
	This file is part of the EkkiEkkiKateng build tool.
	Copyright (C) 2013 Claudius Jähn (claudiusj@users.berlios.de)
	Licensed under the MIT License. See LICENSE file for details.
	https://github.com/ClaudiusJ/EkkiEkkiKateng
   ---------------------------------------------------------------- */
var LinkerOptions = new Namespace;

static Utils = Std.require('EkkiEkkiKateng/Utils');

LinkerOptions.getOptions := fn(path){	return Utils.findOptions(path, $LINKER_OPTIONS);	};

LinkerOptions.addOption := 	fn(pathOrNode, String value){	Utils.addOption(pathOrNode,$LINKER_OPTIONS,value); };
LinkerOptions.addOptions := 	fn(pathOrNode, Array values){	Utils.addOptions(pathOrNode,$LINKER_OPTIONS,values); };

LinkerOptions.getSearchPaths :=	fn(pathOrNode){		return Utils.findOptions(pathOrNode, $LINKER_OPTIONS_SEARCH_PATH);	};
LinkerOptions.addSearchPath := 	fn(pathOrNode, String folder){	Utils.addOption(pathOrNode,$LINKER_OPTIONS_SEARCH_PATH,folder); };

LinkerOptions.getLibraries :=	fn(pathOrNode){		return Utils.findOptions(pathOrNode, $LINKER_LIBS);	};
LinkerOptions.addLibrary := 	fn(pathOrNode, String lib){	Utils.addOption(pathOrNode,$LINKER_LIBS,lib); };

return LinkerOptions;
