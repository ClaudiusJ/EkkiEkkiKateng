/* ----------------------------------------------------------------
	This file is part of the EkkiEkkiKateng build tool.
	Copyright (C) 2013 Claudius Jähn (claudiusj@users.berlios.de)
	Licensed under the MIT License. See LICENSE file for details.
	https://github.com/ClaudiusJ/EkkiEkkiKateng
   ---------------------------------------------------------------- */
outln("-"*40);
outln("EkkiEkkiKateng! (EScript build system)");
Runtime.setLoggingLevel(Runtime.LOG_PEDANTIC_WARNING);
/*
 external libraries ...
   multiple libs per library node (openCollada)
 Target dependencies ...
 inherit external dependencies from dependent static libraries
 option file
 lpsolve???????????????????????

 
 Minsg extension dependencies (minsg_add_dependencies)

 !!!! Project dependencies!!!!!
 
 
 done:
	Header file dependency????????
	 2x modules ??????
 
*/
loadOnce("./Std/basics.escript"); // load Std lib

static Set = Std.require('Std/Set');
static Traits = Std.require('Std/Traits/basics');

outln("Version: ",Std.require('EkkiEkkiKateng/Version') );
assert(Std.require('EkkiEkkiKateng/Version') >= 0.1);

static CompilerOptions = Std.require('EkkiEkkiKateng/CompilerOptions');
static ExternalLibs = Std.require('EkkiEkkiKateng/ExternalLibs');
static Files = Std.require('EkkiEkkiKateng/Files');
static FileUtils = Std.require('EkkiEkkiKateng/FileUtils');
static LinkerOptions = Std.require('EkkiEkkiKateng/LinkerOptions');
static Node = Std.require('EkkiEkkiKateng/Node');
static Projects = Std.require('EkkiEkkiKateng/Projects');
static Targets = Std.require('EkkiEkkiKateng/Targets');
static VirtualTargets = Std.require('EkkiEkkiKateng/VirtualTargets');

// --------------------------------
// config

var config = new (Std.require('Std/JSONDataStore'))(true);
config.init( __FILE__.substr(0,__FILE__.rFind("."))+".eek.txt", false);

static folder_base = config.get('Project.Folders.base', "D:/PADrend/");
static folder_staticLibs = config.get('Project.Folders.libBuild', ".libs");
static folder_objFiles = config.get('Project.Folders.objFiles', ".obj");
static searchFolders_includes = config.get('Project.Folders.thirdPartyIncludes', [folder_base+"ThirdParty/x86_64-w64-mingw32/include"] );
static searchFolders_libs = config.get('Project.Folders.thirdPartyLibs', [folder_base+"ThirdParty/x86_64-w64-mingw32/lib"]);

// --------------------------
// libs

outln("-"*10);
outln("ThirdParty libraries:");
var simpleFindAndCreateLibNode = fn(String name, String includeSubFolder,String testHeader,Array libFiles, Array includeSearchPaths,Array libSearchPaths){
	var includePath;
	foreach(includeSearchPaths as var p){
		if(IO.isFile(p+"/"+includeSubFolder+"/"+testHeader)){
			includePath = p+"/"+includeSubFolder;
			break;
		}
	}
	if(!includePath)
		return void;
	var foundLibSearchPaths = [];
	var foundLibFiles = [];
	foreach(libFiles as var libFile){
		foreach(libSearchPaths as var p){
			if(IO.isFile(p+"/"+libFile)){
				if(!foundLibSearchPaths.contains(p))
					foundLibSearchPaths += p;
				if(!foundLibFiles.contains(libFile))
					foundLibFiles += libFile;
				break;
			}
		}
	}
	if(foundLibFiles.empty())
		return void;
	var n = ExternalLibs.createNode(name);
	CompilerOptions.addSearchPath(n, includePath);
	foreach(foundLibSearchPaths as var p)
		LinkerOptions.addSearchPath(n, p);
	
	foreach(foundLibFiles as var p)
		LinkerOptions.addLibrary(n, p.substr(0,p.rFind(".")));
	return n;
};
static createSystemLibNode = fn(String name, library){
	var n = ExternalLibs.createNode(name);
	LinkerOptions.addLibrary(n, library );
	return n;
};

static libraries = {
	'archive'	: simpleFindAndCreateLibNode("archive",	"","archive.h",["libarchive.dll.a"],searchFolders_includes,searchFolders_libs),
	'bullet'	: simpleFindAndCreateLibNode("bullet",	"bullet","btBulletDynamicsCommon.h",[
								"libBulletCollision.dll.a",
								"libBulletDynamics.dll.a",
								"libLinearMath.dll.a"
						],searchFolders_includes,searchFolders_libs),
	'curl'		: simpleFindAndCreateLibNode("curl",	"","curl/curl.h",["libcurl.dll.a"],searchFolders_includes,searchFolders_libs),
	'detri'		: simpleFindAndCreateLibNode("detri",	"Detri","detri.h",["libDetri.dll.a"],searchFolders_includes,searchFolders_libs),
	'freetype'	: simpleFindAndCreateLibNode("freetype","freetype2","freetype/freetype.h",["libfreetype.dll.a"],searchFolders_includes,searchFolders_libs),
	'gl'		: ExternalLibs.createNode("gl"),
	'glew'		: simpleFindAndCreateLibNode("glew",	"","GL/glew.h",["libglew32.dll.a"],searchFolders_includes,searchFolders_libs),
	'lpsolve'	: simpleFindAndCreateLibNode("lpsolve",	"lpsolve","lp_lib.h",["liblpsolve55.dll.a"],searchFolders_includes,searchFolders_libs),
	'OpenAL'	: simpleFindAndCreateLibNode("OpenAL",	"","AL/al.h",["libOpenAL32.dll.a"],searchFolders_includes,searchFolders_libs),
	'OpenCOLLADA': void, //! \todo 
//		simpleFindAndCreateLibNode("OpenCOLLADA",	"opencollada/GeneratedSaxParser","GeneratedSaxParser",["libOpenAL32.dll.a"],searchFolders_includes,searchFolders_libs),
	'png'		: simpleFindAndCreateLibNode("png",		"","png.h",["libpng.dll.a"],searchFolders_includes,searchFolders_libs),
	'pthread'	: createSystemLibNode("pthread", "pthread"),
//	'pthread'	: void, // ????????????????????
	'sqlite'	: simpleFindAndCreateLibNode("sqlite",	"","sqlite3.h",["libsqlite3.dll.a"],searchFolders_includes,searchFolders_libs),
	'SDL2'		: simpleFindAndCreateLibNode("SDL2",	"SDL2","SDL.h",["libSDL2.dll.a"],searchFolders_includes,searchFolders_libs),
	'SDL2_image': simpleFindAndCreateLibNode("SDL_image","SDL2","SDL_image.h",["libSDL2_image.dll.a"],searchFolders_includes,searchFolders_libs),
	'SDL2_net'	: simpleFindAndCreateLibNode("SDL2_net","SDL2","SDL_net.h",["libSDL2_net.dll.a"],searchFolders_includes,searchFolders_libs),
	'X11'		: void, /* Sorry... windows only at the moment */
	'XML2'		: simpleFindAndCreateLibNode("XML2",	"libxml2","libxml/globals.h",["libXML2.dll.a"],searchFolders_includes,searchFolders_libs),
	'ZIP'		: simpleFindAndCreateLibNode("ZIP",		"","zip.h",["libZIP.dll.a"],searchFolders_includes,searchFolders_libs),
	'zlib'		: simpleFindAndCreateLibNode("zlib",	"","zlib.h",["libz.dll.a"],searchFolders_includes,searchFolders_libs),
};
foreach(libraries as var name,var lib)
	outln(" - ",name.fillUp(30,"."),(lib?"found":"missing"));

//print_r(libraries);
// -------------------------------------------------------


// -------------------------------------------------------------
// Targets
outln("-"*10);
outln("Targets:");

var createModuleLibTarget = fn(String targetName,String moduleFolder,String libName){
	var targetNode = Targets.createNode(targetName);
	Targets.setObjectFolder( targetNode, folder_objFiles );
	Targets.setOutput( targetNode, folder_staticLibs+"/"+libName );
	Targets.setType_StaticLib( targetNode );
	CompilerOptions.addOptions( targetNode, [ "-g","-O3" ]);

	foreach(FileUtils.scanFiles( folder_base+moduleFolder, [".cpp",".h",".escript",".txt"] ) as var filename){ // ,".rc"
		filename = filename.substr(folder_base.length());
		if(!filename.contains("- Kopie")&&!filename.contains("/tests/")&&!filename.contains("/examples/")){
			targetNode += Files.createNode(filename);
		}
	}
	return targetNode;
};
var createModuleExeTarget = fn(String targetName,String moduleFolder,String exeName){
	var targetNode = Targets.createNode(targetName);
	Targets.setObjectFolder( targetNode, folder_objFiles );
	Targets.setOutput( targetNode, folder_base+"/"+exeName );
	Targets.setType_ConsoleApp( targetNode );
	CompilerOptions.addOptions( targetNode, [ "-g","-O3" ]);

	foreach(FileUtils.scanFiles( folder_base+moduleFolder, [".cpp",".h",".escript",".txt",".rc"] ) as var filename){ // ,".rc"
		filename = filename.substr(folder_base.length());
		if(!filename.contains("- Kopie")&&!filename.contains("/tests/")&&!filename.contains("/examples/")){
			targetNode += Files.createNode(filename);
		}
	}
	return targetNode;
};

var targets = new Map; // the key is used for sorting!

{	// EScript
	outln("Target: EScript");
	targets["EScript"] = createModuleLibTarget("EScript","modules/EScript","libEScript");
}

{	// Geometry
	outln("Target: Geometry");
	targets["Geometry"] = createModuleLibTarget("Geometry","modules/Geometry","libGeometry");
}

{	// E_Geometry
	outln("Target: E_Geometry");
	var target = createModuleLibTarget("E_Geometry","modules/E_Geometry","libE_Geometry");
	CompilerOptions.addSearchPath(target, "modules/EScript");
	CompilerOptions.addSearchPath(target, "modules");
	targets["E_Geometry"] = target;
}

{	// GUI
	outln("Target: GUI");
	var target = createModuleLibTarget("GUI","modules/GUI","libGUI");
	CompilerOptions.addSearchPath(target, "modules");
	if(libraries['glew'])
		target += libraries['glew'];
	else {
		Runtime.warn("LibGLEW not found!");
	}
	targets["GUI"] = target;
}

{	// E_GUI
	outln("Target: E_GUI");
	var target = createModuleLibTarget("E_GUI","modules/E_GUI","libE_GUI");
	CompilerOptions.addSearchPath(target, "modules/EScript");
	CompilerOptions.addSearchPath(target, "modules");
	targets["E_GUI"] = target;
}

{	// Rendering
	outln("Target: Rendering");
	var target = createModuleLibTarget("Rendering","modules/Rendering","libRendering");
	CompilerOptions.addSearchPath(target, "modules");
	
	LinkerOptions.addLibrary(target,"glu32");
	LinkerOptions.addLibrary(target,"opengl32");
		
	if(libraries['glew']){
		target += libraries['glew'];
		CompilerOptions.addDefine( target, "LIB_GLEW");
	}else {
		Runtime.warn("LibGLEW not found!");
	}
	if(libraries['gl']){
		target += libraries['gl'];
		CompilerOptions.addDefine( target, "LIB_GL");
	}else {
		Runtime.warn("LibGL not found!");
	}
	targets["Rendering"] = target;
}

{	// E_Rendering
	outln("Target: E_Rendering");
	var target = createModuleLibTarget("E_Rendering","modules/E_Rendering","libE_Rendering");
	CompilerOptions.addSearchPath(target, "modules/EScript");
	CompilerOptions.addSearchPath(target, "modules");
	targets["E_Rendering"] = target;
}

{ // Util and E_Util
	outln("Target: Util & E_Util");
	var target = createModuleLibTarget("Util","modules/Util","libUtil");
	var e_target = createModuleLibTarget("E_Util","modules/E_Util","libE_Util");
	CompilerOptions.addSearchPath(e_target, "modules");
	CompilerOptions.addSearchPath(e_target, "modules/EScript");
			
	LinkerOptions.addLibrary(target,"gdi32");
	LinkerOptions.addLibrary(target,"psapi");
	
	foreach( {
				'archive' : "UTIL_HAVE_LIB_ARCHIVE",
				'curl' : "UTIL_HAVE_LIB_CURL",
				'freetype' : "UTIL_HAVE_LIB_FREETYPE",
				'png' : "UTIL_HAVE_LIB_PNG",
				'sqlite' : "UTIL_HAVE_LIB_SQLITE",
				'SDL2' : "UTIL_HAVE_LIB_SDL2",
				'SDL2_image' : "UTIL_HAVE_LIB_SDL2_IMAGE",
				'SDL2_net' : "UTIL_HAVE_LIB_SDL2_NET",
				'X11' : "UTIL_HAVE_LIB_X11",
				'XML2' : "UTIL_HAVE_LIB_XML2",
				'ZIP' : "UTIL_HAVE_LIB_ZIP",
				'pthread' : "UTIL_HAVE_PTHREAD",
			} as var libId, var libDefine){
		
		var lib = libraries[libId];
		if(lib){
			target += lib;
			e_target += lib;
		}else{
			libDefine = "NO_"+libDefine;
		}
		CompilerOptions.addDefine( target, libDefine);
		CompilerOptions.addDefine( e_target, libDefine);
		outln(" - ",libDefine);
	}
	targets["Util"] = target;
	targets["E_Util"] = e_target;
}

{	// Sound
	outln("Target: Sound");
	var target = createModuleLibTarget("Sound","modules/Sound","libSound");
	CompilerOptions.addSearchPath(target, "modules");
	
	if(libraries['OpenAL']){
		target += libraries['OpenAL'];
	}else {
		Runtime.warn("OpenAL not found!");
	}
	if(libraries['SDL2']){
		target += libraries['SDL2'];
	}else {
		Runtime.warn("SDL2 not found!");
	}
	targets["Sound"] = target;
}

{	// E_Sound
	outln("Target: E_Sound");
	var target = createModuleLibTarget("E_Sound","modules/E_Sound","libE_Sound");
	CompilerOptions.addSearchPath(target, "modules/EScript");
	CompilerOptions.addSearchPath(target, "modules");
	targets["E_Sound"] = target;
}



{	// MinSG
	outln("Target: MinSG & E_MinSG");
	var target = createModuleLibTarget("MinSG","modules/MinSG","libMinSG");
	var e_target = createModuleLibTarget("E_MinSG","modules/E_MinSG","libE_MinSG");
	CompilerOptions.addSearchPath(target, "modules");
	CompilerOptions.addSearchPath(e_target, "modules");
	CompilerOptions.addSearchPath(e_target, "modules/EScript");
	
	// extensions
	var extensions = new Map;
	
	var extensionLibDependency = {
		'MINSG_EXT_MULTIALGORENDERING' : 'lpsolve',
		'MINSG_EXT_TRIANGULATION' : 'detri',
		'MINSG_EXT_LOADERCOLLADA' : 'OpenCOLLADA',
		'MINSG_EXT_PHYSICS' : 'bullet',
		'MINSG_EXT_D3FACT' : 'zlib'
	};
	// if a required library is not found, disable all dependent extensions by default.
	foreach( extensionLibDependency as var extName,var libId){
		var lib = libraries[libId];
		if(!lib)
			extensions[extName] = false;
	}
		
	foreach(FileUtils.scanForKeywords("MINSG_EXT_",folder_base+"/modules/MinSG", [".cpp",".h"]) as var name){
		if( !name.endsWith("_H") && !extensions.containsKey(name)){
			extensions[name] = (name.contains("THESIS") || name.contains("PROFILING") || name.contains("DEBUG")) ? false : true;
		}
	}
	foreach(config.get('MinSG.extensions',new Map) as var name,var enabled){
		if(extensions.containsKey(name))
			extensions[name] = enabled;
	}
	config.set('MinSG.extensions',extensions);
	
	foreach(extensions as var name,var enabled){
		var define = enabled ? name : "NO_"+name;
		CompilerOptions.addDefine( target, define);
		CompilerOptions.addDefine( e_target, define);
		outln(" - ",define);
	}
	CompilerOptions.addDefine( target, "WIN32"); // required for lpsolve
	
	// add required libs
	foreach( extensionLibDependency as var extName,var libId){
		if(extensions[extName]){
			var lib = libraries[libId];
			if(lib){
				target += lib;
			}else{
				Runtime.warn("["+extName+"] required library '"+libId+"' is missing found!");
			}
		}
	}
	
	targets["MinSG"] = target;
	targets["E_MinSG"] = e_target;
}

{	// PADrend main

	var containerNode = new Node;
	
	containerNode += targets["EScript"];
	containerNode += targets["Geometry"];
	containerNode += targets["Util"];
	containerNode += targets["Rendering"];
	containerNode += targets["GUI"];
	containerNode += targets["Sound"];
	containerNode += targets["MinSG"];
	containerNode += targets["E_Geometry"];
	containerNode += targets["E_Util"];
	containerNode += targets["E_Rendering"];
	containerNode += targets["E_GUI"];
	containerNode += targets["E_Sound"];
	containerNode += targets["E_MinSG"];
	
	outln("Scanning for script files...");
	foreach(FileUtils.scanFiles( folder_base, [".escript",".sfn",".vs",".fs"] ) as var filename){
		filename = filename.substr(folder_base.length());
		containerNode += Files.createNode(filename);
	}
	
	
	{
		outln("Target: PADrend main (debug)");
		var target = createModuleExeTarget("PADrend (debug)","PADrend","PADrend_Dbg");
		// todo add scripts!
		CompilerOptions.addSearchPath(target, "modules");
		CompilerOptions.addSearchPath(target, "modules/EScript");
		CompilerOptions.addDefine( target, "PADREND_HAVE_LIB_E_SOUND");

		target += containerNode;
		targets["~PADrendDbg"] = target;
	}
	{
		outln("Target: PADrend main (release)");
		var target = createModuleExeTarget("PADrend (release)","PADrend","PADrend");
		// todo add scripts!
		CompilerOptions.addSearchPath(target, "modules");
		CompilerOptions.addSearchPath(target, "modules/EScript");
		CompilerOptions.addDefine( target, "PADREND_HAVE_LIB_E_SOUND");
		LinkerOptions.addOption( target, "-s"); // strip symbols

		target += containerNode;
		targets["~PADrend"] = target;
	}
	// ----
	
}

//---------------------------

{ // all
	var vTarget = VirtualTargets.createNode("All");
	foreach( targets as var target)
		vTarget += target;
	
	targets["All"] = vTarget;
//	outln( vTarget.toDbgString() );
}

//---------------------------

var project = Projects.createNode( config.get('Project.name',"PADrend") );

CompilerOptions.setCompilerId( project, config.get('Project.compilerId',"gcc") );
CompilerOptions.addOptions( project, config.get('Project.compilerOptions',[
			"-std=c++11",
			"-pedantic","-Wall","-Wextra","-Wshadow","-Wcast-qual","-Wcast-align","-Wlogical-op",
			"-Wredundant-decls","-Wdisabled-optimization","-Wstack-protector","-Winit-self","-Wmissing-include-dirs",
			"-Wswitch-default","-Wswitch-enum","-Wctor-dtor-privacy","-Wstrict-null-sentinel","-Wno-non-template-friend",
			"-Wold-style-cast","-Woverloaded-virtual","-Wno-pmf-conversions","-Wsign-promo","-Wmissing-declarations"
]));
foreach( targets as var target)
	project += target;

// ------------------------------------
outln("-"*10);
outln("Generating Code::Blocks project file...");
var generator = Std.require('EkkiEkkiKateng/CodeBlocksGenerator');
//generator.createProject( project );
IO.saveTextFile(folder_base+"/PADrend.cbp", generator.createProject( project ));

return true;

//print_r(project.toDbgString());
