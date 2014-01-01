/* ----------------------------------------------------------------
	This file is part of the EkkiEkkiKateng build tool.
	Copyright (C) 2013 Claudius Jähn (claudiusj@users.berlios.de)
	Licensed under the MIT License. See LICENSE file for details.
	https://github.com/ClaudiusJ/EkkiEkkiKateng
   ---------------------------------------------------------------- */
outln("EkkiEkkiKateng!");

loadOnce("./Std/basics.escript"); // load Std lib

static Traits = Std.require('Std/Traits/basics');

outln("Version: ",Std.require('EkkiEkkiKateng/Version') );
assert(Std.require('EkkiEkkiKateng/Version') >= 0.1);

var Node = Std.require('EkkiEkkiKateng/Node');
var Utils = Std.require('EkkiEkkiKateng/Utils');

var CompilerOptions = Std.require('EkkiEkkiKateng/CompilerOptions');
var Projects = Std.require('EkkiEkkiKateng/Projects');
var Files = Std.require('EkkiEkkiKateng/Files');
var Targets = Std.require('EkkiEkkiKateng/Targets');
var VirtualTargets = Std.require('EkkiEkkiKateng/VirtualTarget');


var baseDir = __DIR__+"/..";

var project = Projects.createNode("EScript");
CompilerOptions.addOptions(project, [
			"-std=c++11",
			"-pedantic","-Wall","-Wextra","-Wshadow","-Wcast-qual","-Wcast-align","-Wlogical-op",
			"-Wredundant-decls","-Wdisabled-optimization","-Wstack-protector","-Winit-self","-Wmissing-include-dirs",
			"-Wswitch-default","-Wswitch-enum","-Wctor-dtor-privacy","-Wstrict-null-sentinel","-Wno-non-template-friend",
			"-Wold-style-cast","-Woverloaded-virtual","-Wno-pmf-conversions","-Wsign-promo","-Wmissing-declarations"
]);

CompilerOptions.setCompilerId( project, "gcc");

var allFiles = new Node;
foreach(Utils.scanFiles( baseDir, [".cpp",".h",".escript",".txt",".rc"] ) as var filename){
	if(!filename.contains('- Kopie'))
		allFiles += Files.createNode(filename);
}

{
	var targetNode = Targets.createNode("StaticLib");
	Targets.setType_StaticLib( targetNode );
	Targets.setOutput( targetNode,"libEScript");
	Targets.setObjFolder( targetNode,".obj/dbgTest");
	CompilerOptions.addOptions(targetNode, [ "-g","-O3" ]);
	targetNode += allFiles;
	project += targetNode;
}

{
	var targetNode = Targets.createNode("Tests");
	Targets.setType_ConsoleApp( targetNode );
	Targets.setOutput( targetNode, "EScriptTest" );
	Targets.setObjFolder( targetNode, ".obj/test");
	Targets.setWorkingDir( targetNode, ".");
	CompilerOptions.addOptions(targetNode,[ "-g","-O3","-DES_BUILD_TEST_APPLICATION" ]);
	targetNode += allFiles;
	project += targetNode;

}

{
	var vTarget = VirtualTargets.createNode("All");
	foreach( Targets.collect( project ) as var target)
		vTarget += target;

	project += vTarget;
	outln( vTarget.toDbgString() );
}




var generator = Std.require('EkkiEkkiKateng/CodeBlocksGenerator');
IO.saveTextFile("test.cbp", generator.createProject( project ));

return true;

//print_r(project.toDbgString());
