/* ----------------------------------------------------------------
	This file is part of the EkkiEkkiKateng build tool.
	Copyright (C) 2013-2014 Claudius Jähn (ClaudiusJ@live.de)
	Licensed under the MIT License. See LICENSE file for details.
	https://github.com/ClaudiusJ/EkkiEkkiKateng
   ---------------------------------------------------------------- */
var Targets = new Namespace;


static Node = module('./Node');
static Utils = module('./Utils');

Targets.createNode := fn(name=void){
	var n = new Node;
	n.setOption( $IS_TARGET, true);
	if(name)
		n.setOption( $TARGET_NAME, name);
	n.setTransient(false);
	return n;
};
Targets.collect :=				fn(pathOrNode){			return Utils.collectNextHavingOption(pathOrNode,$IS_TARGET);	};

Targets.getName :=				fn(pathOrNode,p...){	return Utils.findOption(pathOrNode, $TARGET_NAME,p...);	};
Targets.getObjectFolder :=		fn(pathOrNode,p...){	return Utils.findOption(pathOrNode, $TARGET_OBJ_FOLDER,p...);	};
Targets.getOutput :=			fn(pathOrNode,p...){	return Utils.findOption(pathOrNode, $TARGET_OUTPUT,p...);	};
Targets.getWorkingDir :=		fn(pathOrNode,p...){	return Utils.findOption(pathOrNode, $TARGET_WORKING_DIR,p...);	};

Targets.isType_ConsoleApp :=	fn(pathOrNode){			return Utils.findOption(pathOrNode, $TARGET_TYPE) == $TARGET_TYPE_CONSOLE_APP;	};
Targets.isType_StaticLib :=		fn(pathOrNode){			return Utils.findOption(pathOrNode, $TARGET_TYPE) == $TARGET_TYPE_STATIC_LIB;	};
Targets.isType_StaticLib :=		fn(pathOrNode){			return Utils.findOption(pathOrNode, $TARGET_TYPE) == $TARGET_TYPE_STATIC_LIB;	};


Targets.setObjectFolder :=		fn(pathOrNode, String folder){	Utils.setOption(pathOrNode, $TARGET_OBJ_FOLDER, folder);	};
Targets.setOutput :=			fn(pathOrNode, String file){	Utils.setOption(pathOrNode, $TARGET_OUTPUT, file);	};
Targets.setType_ConsoleApp :=	fn(pathOrNode){					Utils.setOption(pathOrNode, $TARGET_TYPE, $TARGET_TYPE_CONSOLE_APP);	};
Targets.setType_StaticLib :=	fn(pathOrNode){					Utils.setOption(pathOrNode, $TARGET_TYPE, $TARGET_TYPE_STATIC_LIB);	};
Targets.setWorkingDir :=		fn(pathOrNode, String folder){	Utils.setOption(pathOrNode, $TARGET_WORKING_DIR, folder);	};


return Targets;