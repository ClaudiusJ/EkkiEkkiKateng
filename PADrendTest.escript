/* ----------------------------------------------------------------
	This file is part of the EkkiEkkiKateng build tool.
	Copyright (C) 2013 Claudius Jähn (claudiusj@users.berlios.de)
	Licensed under the MIT License. See LICENSE file for details.
	https://github.com/ClaudiusJ/EkkiEkkiKateng
   ---------------------------------------------------------------- */
outln("EkkiEkkiKateng!");

loadOnce("./Std/basics.escript"); // load Std lib

static Set = Std.require('Std/Set');
static Traits = Std.require('Std/Traits/basics');

static Constants = Std.require('EkkiEkkiKateng/Constants');

assert(Constants.VERSION >= 0.1);

static Node = Std.require('EkkiEkkiKateng/Node');
static Utils = Std.require('EkkiEkkiKateng/Utils');

static ProjectNodeTrait = Std.require('EkkiEkkiKateng/NodeTraits/ProjectNodeTrait');
static ExternalLibraryNodeTrait = Std.require('EkkiEkkiKateng/NodeTraits/ExternalLibraryNodeTrait');
static FileNodeTrait = Std.require('EkkiEkkiKateng/NodeTraits/FileNodeTrait');
static TargetNodeTrait = Std.require('EkkiEkkiKateng/NodeTraits/TargetNodeTrait');
static VirtualTargetNodeTrait = Std.require('EkkiEkkiKateng/NodeTraits/VirtualTargetNodeTrait');

// --------------------------------

var createModuleLibTarget = fn(String targetName,String moduleFolder,String libName){
	var target = new Node;
	Traits.addTrait( target, TargetNodeTrait, targetName);	//! \see EkkiEkkiKateng/TargetNodeTrait
	target.setOption( Constants.TARGET_TYPE, Constants.TARGET_TYPE_STATIC_LIB);
	target.setOption( Constants.TARGET_OUTPUT, folder_staticLibs+"/"+libName);
	target.setOption( Constants.TARGET_OBJ_FOLDER, folder_objFiles);
	target.addOptions( Constants.COMPILER_FLAGS, [ "-g","-O3" ]);

	foreach(Utils.scanFiles( folder_base+moduleFolder, [".cpp",".h",".escript",".txt",".rc"] ) as var filename){
		filename = filename.substr(folder_base.length());
		if(!filename.contains("- Kopie")&&!filename.contains("/tests/")&&!filename.contains("/examples/")){
			var file = new Node;
			Traits.addTrait( file, FileNodeTrait, filename);	//! \see EkkiEkkiKateng/FileNodeTrait
			target += file;
		}
	}
	return target;
};

var createLibNode_SDL2 = fn(Array includeSearchPaths,Array libSearchPaths){
	var includePath;
	foreach(includeSearchPaths as var p){
		if(IO.isFile(p+"/SDL2/SDL.h")){
			includePath = p+"/SDL2";
			break;
		}
	}else{
		return void;
	}
	var libSearchPath;
	foreach(libSearchPaths as var p){
		if(IO.isFile(p+"/libSDL2.a")){
			libSearchPath = p;
			break;
		}
	}else{
		return void;
	}
	
	outln("includePath:", includePath);
	outln("libSearchPath:", libSearchPath);
	var n = new Node;
//	Traits.addTrait( n, ExternalLibraryNodeTrait, "SDL2");	//! \see EkkiEkkiKateng/ExternalLibraryNodeTrait
//	n.setOption( Constants.LINKER_LIBRARY, "libSDL2" );
//	n.setOption( Constants.LINKER_SEARCH_PATH, libSearchPath );
//	n.setOption( Constants.COMPILER_SEARCH_PATH, includePath );
	return n;
};

//
//// scan for preprocessor defines
//	var defines = new Set;
//	var prefix = "UTIL_HAVE_";
//	foreach(Utils.scanFiles( folder_base+"/modules/Util", [".cpp",".h"]) as var filename){
//		var file = IO.loadTextFile(filename);
//		var pos = 0;
//		while(pos = file.find(prefix,pos)){
//			pos+=prefix.length();
//			var s = prefix;
//			for( var c = file[pos]; (c>='A'&&c<='Z') || (c>='a'&&c<='z') ||(c>='0'&&c<='9') || c=='_'; c = file[++pos])
//				s+= file[pos];
//			defines+=s;
////						outln(filename," : ",pos,"\t",s);
//		}
//	}
//	print_r(defines.toArray());

// --------------------------------



static folder_base = "D:/PADrend/";
static folder_staticLibs = ".libs";
static folder_objFiles = ".obj";
static searchFolders_includes = [folder_base+"ThirdParty/x86_64-w64-mingw32/include"];
static searchFolders_libs = [folder_base+"ThirdParty/x86_64-w64-mingw32/lib"];

outln( createLibNode_SDL2(searchFolders_includes,searchFolders_libs).toDbgString());
//return;



var project = new Node;
Traits.addTrait( project, ProjectNodeTrait, "PADrend");	//! \see EkkiEkkiKateng/ProjectNodeTrait
project.setOption( Constants.COMPILER_ID, "gcc");
project.addOptions( Constants.COMPILER_FLAGS, [
			"-std=c++11",
			"-pedantic","-Wall","-Wextra","-Wshadow","-Wcast-qual","-Wcast-align","-Wlogical-op",
			"-Wredundant-decls","-Wdisabled-optimization","-Wstack-protector","-Winit-self","-Wmissing-include-dirs",
			"-Wswitch-default","-Wswitch-enum","-Wctor-dtor-privacy","-Wstrict-null-sentinel","-Wno-non-template-friend",
			"-Wold-style-cast","-Woverloaded-virtual","-Wno-pmf-conversions","-Wsign-promo","-Wmissing-declarations"
]);



{	// Geometry
	var target = createModuleLibTarget("Geometry","modules/Geometry","libGeometry");

	project += target;
}

{	// Util
	var target = createModuleLibTarget("Util","modules/Util","libUtil");

	

	project += target;
}
//
//var allFiles = new Node;
//foreach(Utils.scanFiles( folder_base, [".cpp",".h",".escript",".txt",".rc"] ) as var filename){
//	if(filename.contains('- Kopie'))
//		continue;
//	var file = new Node;
//	Traits.addTrait( file, FileNodeTrait, filename);	//! \see EkkiEkkiKateng/FileNodeTrait
//	allFiles += file;
//}
//
//{
//	var target = new Node;
//	Traits.addTrait( target, TargetNodeTrait, "StaticLib");	//! \see EkkiEkkiKateng/TargetNodeTrait
//	
//	target.setOption( Constants.TARGET_TYPE, Constants.TARGET_TYPE_STATIC_LIB);
//	target.setOption( Constants.TARGET_OUTPUT, "libEScript");
//	target.setOption( Constants.TARGET_OBJ_FOLDER, ".obj/dbgTest");
//	target.addOptions( Constants.COMPILER_FLAGS, [ "-g","-O3" ]);
//	target += allFiles;
//	project += target;
//} 
//
//{
//	var target = new Node;
//	Traits.addTrait( target, TargetNodeTrait, "Tests");	//! \see EkkiEkkiKateng/TargetNodeTrait
//	
//	target.setOption( Constants.TARGET_TYPE, Constants.TARGET_TYPE_CONSOLE_APP);
//	target.setOption( Constants.TARGET_OUTPUT, "EScriptTest");
//	target.setOption( Constants.TARGET_OBJ_FOLDER, ".obj/test");
//	target.setOption( Constants.TARGET_WORKING_DIR, ".");
//	target.addOptions( Constants.COMPILER_FLAGS, [ "-g","-O3","-DES_BUILD_TEST_APPLICATION" ]);
//	target += allFiles;
//	project += target;
//
////	outln(allFiles.findOption(Constants.COMPILER_FLAGS,[project,target]));
//}
//

{ // all
	var vTarget = new Node;
	Traits.addTrait( vTarget, VirtualTargetNodeTrait, "All");	//! \see EkkiEkkiKateng/VirtualTargetNodeTrait
	foreach( Utils.collectNodesByType( project, Constants.NODE_TYPE_TARGET ) as var target)
		vTarget += target;
	
	project += vTarget;
//	outln( vTarget.toDbgString() );
}




var generator = Std.require('EkkiEkkiKateng/CodeBlocksGenerator');
IO.saveTextFile(folder_base+"/PADrend.cbp", generator.createProject( project ));

return true;

//print_r(project.toDbgString());
