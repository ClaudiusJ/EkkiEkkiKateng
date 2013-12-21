/* ----------------------------------------------------------------
	This file is part of the EkkiEkkiKateng build tool.
	Copyright (C) 2013 Claudius Jähn (claudiusj@users.berlios.de)
	Licensed under the MIT License. See LICENSE file for details.
	https://github.com/ClaudiusJ/EkkiEkkiKateng
   ---------------------------------------------------------------- */

assert(EScript.VERSION>=607); // 0.6.7

var Constants = new Namespace;

Constants.VERSION @(const) := 0.1;
Constants.COMPILER_ID @(const) := $COMPILER_ID;
Constants.COMPILER_FLAGS @(const) := $COMPILER_FLAGS;
Constants.COMPILER_VAR @(const) := $COMPILER_VAR;
Constants.LINKER_FLAGS @(const) := $LINKER_FLAGS;
Constants.LINKER_LIBRARIES @(const) := $LINKER_LIBRARIES;
Constants.TARGET_TYPE @(const) := $TARGET_TYPE;
Constants.TARGET_TYPE_STATIC_LIB @(const) := $TARGET_TYPE_STATIC_LIB;
Constants.TARGET_TYPE_CONSOLE_APP @(const) := $TARGET_TYPE_CONSOLE_APP;
Constants.TARGET_OUTPUT @(const) := $TARGET_OUTPUT;
Constants.TARGET_OBJ_FOLDER @(const) := $TARGET_OBJ_FOLDER;
Constants.TARGET_WORKING_DIR @(const) := $TARGET_WORKING_DIR;
Constants.PROJECT_NAME @(const) := $PROJECT_NAME;
Constants.NAME @(const) := $NAME;
Constants.NODE_TYPE @(const) := $NODE_TYPE;
Constants.NODE_TYPE_FILE @(const) := $NODE_TYPE_FILE;
Constants.NODE_TYPE_PROJECT @(const) := $NODE_TYPE_PROJECT;
Constants.NODE_TYPE_TARGET @(const) := $NODE_TYPE_TARGET;
Constants.NODE_TYPE_VIRTUAL_TARGET @(const) := $NODE_TYPE_VIRTUAL_TARGET;
Constants.VIRTUAL_TARGET_NAME @(const) := $VIRTUAL_TARGET_NAME;

return Constants;
