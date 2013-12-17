/* ----------------------------------------------------------------
	This file is part of the EkkiEkkiKateng build tool.
	Copyright (C) 2013 Claudius Jähn (claudiusj@users.berlios.de)
	Licensed under the MIT License. See LICENSE file for details.
	https://github.com/ClaudiusJ/EkkiEkkiKateng
   ---------------------------------------------------------------- */
outln("EkkiEkkiKateng!");

loadOnce("./Std/basics.escript"); // load Std lib

static Traits = Std.require('Std/Traits/basics');

var Constants = Std.require('EkkiEkkiKateng/Constants');

assert(Constants.VERSION >= 0.1);

var Node = Std.require('EkkiEkkiKateng/Node');
var Utils = Std.require('EkkiEkkiKateng/Utils');

var ProjectNodeTrait = Std.require('EkkiEkkiKateng/NodeTraits/ProjectNodeTrait');
var FileNodeTrait = Std.require('EkkiEkkiKateng/NodeTraits/FileNodeTrait');
var TargetNodeTrait = Std.require('EkkiEkkiKateng/NodeTraits/TargetNodeTrait');
var VirtualTargetNodeTrait = Std.require('EkkiEkkiKateng/NodeTraits/VirtualTargetNodeTrait');


var baseDir = __DIR__+"/..";

var project = new Node;
Traits.addTrait( project, ProjectNodeTrait, "EScript");	//! \see EkkiEkkiKateng/ProjectNodeTrait
project.setOption( Constants.COMPILER_ID, "gcc");
project.addOptions( Constants.COMPILER_FLAGS, [
			"-std=c++11",
			"-pedantic","-Wall","-Wextra","-Wshadow","-Wcast-qual","-Wcast-align","-Wlogical-op",
			"-Wredundant-decls","-Wdisabled-optimization","-Wstack-protector","-Winit-self","-Wmissing-include-dirs",
			"-Wswitch-default","-Wswitch-enum","-Wctor-dtor-privacy","-Wstrict-null-sentinel","-Wno-non-template-friend",
			"-Wold-style-cast","-Woverloaded-virtual","-Wno-pmf-conversions","-Wsign-promo","-Wmissing-declarations"
]);



var allFiles = new Node;
foreach(Utils.scanFiles( baseDir, [".cpp",".h",".escript",".txt",".rc"] ) as var filename){
	if(filename.contains('- Kopie'))
		continue;
	var file = new Node;
	Traits.addTrait( file, FileNodeTrait, filename);	//! \see EkkiEkkiKateng/FileNodeTrait
	allFiles += file;
}

{
	var target = new Node;
	Traits.addTrait( target, TargetNodeTrait, "StaticLib");	//! \see EkkiEkkiKateng/TargetNodeTrait
	
	target.setOption( Constants.TARGET_TYPE, Constants.TARGET_TYPE_STATIC_LIB);
	target.setOption( Constants.TARGET_OUTPUT, "libEScript");
	target.setOption( Constants.TARGET_OBJ_FOLDER, ".obj/dbgTest");
	target.addOptions( Constants.COMPILER_FLAGS, [ "-g","-O3" ]);
	target += allFiles;
	project += target;
}

{
	var target = new Node;
	Traits.addTrait( target, TargetNodeTrait, "Tests");	//! \see EkkiEkkiKateng/TargetNodeTrait
	
	target.setOption( Constants.TARGET_TYPE, Constants.TARGET_TYPE_CONSOLE_APP);
	target.setOption( Constants.TARGET_OUTPUT, "EScriptTest");
	target.setOption( Constants.TARGET_OBJ_FOLDER, ".obj/test");
	target.setOption( Constants.TARGET_WORKING_DIR, ".");
	target.addOptions( Constants.COMPILER_FLAGS, [ "-g","-O3","-DES_BUILD_TEST_APPLICATION" ]);
	target += allFiles;
	project += target;

//	outln(allFiles.findOption(Constants.COMPILER_FLAGS,[project,target]));
}

{
	var vTarget = new Node;
	Traits.addTrait( vTarget, VirtualTargetNodeTrait, "All");	//! \see EkkiEkkiKateng/VirtualTargetNodeTrait
	foreach( Utils.collectNodesOfType( [project], Constants.NODE_TYPE_TARGET ) as var targetPath)
		vTarget += targetPath.back();
	
	project += vTarget;
	outln( vTarget.toDbgString() );
}




var generator = Std.require('EkkiEkkiKateng/CodeBlocksGenerator');
IO.saveTextFile("test.cbp", generator.createProject( project ));

return true;

//print_r(project.toDbgString());
