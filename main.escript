/*
**  Copyright (c) Claudius Jähn (claudiusj@users.berlios.de), 2007-2013
**
**  Permission is hereby granted, free of charge, to any person obtaining a copy of this
**  software and associated documentation files (the "Software"), to deal in the Software
**  without restriction, including without limitation the rights to use, copy, modify,
**  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
**  permit persons to whom the Software is furnished to do so, subject to the following
**  conditions:
**
**  The above copyright notice and this permission notice shall be included in all copies
**  or substantial portions of the Software.
**
**  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
**  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
**  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
**  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
**  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
**  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
outln("EkkiEkkiKateng!");

assert(EScript.VERSION>=607); // 0.6.7

loadOnce("./Std/basics.escript");
//Std.addModuleSearchPath(__DIR__+"/..");


// -----------------------------------------------
Std._registerModule('EkkiEkkiKateng/Constants',{
	var EEK = new Namespace;
	EEK.VERSION @(const) := 0.1;
	EEK.COMPILER_ID @(const) := $COMPILER_ID;
	EEK.COMPILER_FLAGS @(const) := $COMPILER_FLAGS;
	EEK.COMPILER_VAR @(const) := $COMPILER_VAR;
	EEK.LINKER_FLAGS @(const) := $LINKER_FLAGS;
	EEK.LINKER_LIBRARIES @(const) := $LINKER_LIBRARIES;
	EEK.TARGET_NAME @(const) := $TARGET_NAME;
	EEK.TARGET_TYPE @(const) := $TARGET_TYPE;
	EEK.TARGET_TYPE_STATIC_LIB @(const) := $TARGET_TYPE_STATIC_LIB;
	EEK.TARGET_TYPE_CONSOLE_APP @(const) := $TARGET_TYPE_CONSOLE_APP;
	EEK.TARGET_OUTPUT @(const) := $TARGET_OUTPUT;
	EEK.TARGET_OBJ_FOLDER @(const) := $TARGET_OBJ_FOLDER;
	EEK.TARGET_WORKING_DIR @(const) := $TARGET_WORKING_DIR;
	EEK.PROJECT_NAME @(const) := $PROJECT_NAME;
	EEK.FILE_NAME @(const) := $FILE_NAME;
	EEK.NODE_TYPE @(const) := $NODE_TYPE;
	EEK.NODE_TYPE_PROJECT @(const) := $NODE_TYPE_PROJECT;
	EEK.NODE_TYPE_TARGET @(const) := $NODE_TYPE_TARGET;
	EEK.NODE_TYPE_FILE @(const) := $NODE_TYPE_FILE;
	EEK;
});

Std._registerModule('EkkiEkkiKateng/Node',{
	static T = new Type;
	T._printableName @(override) ::= $EkkiEkkiKateng_Node;
	T.options @(init) := Map;
	T.incrementalOptions @(init) := Map;
	T.nextNodes @(init) := Std.require('Std/Set');

	T.addOptions ::= fn([Identifier,String] key,Array values){
		if(!this.incrementalOptions[key])
			this.incrementalOptions[key] = [];
		this.incrementalOptions[key].append(values);
	};
	T.addOption ::= fn([Identifier,String] key,value){
		this.addOptions(key,[value]);
	};

	T.getNextNodes ::= fn(){
		return this.nextNodes;
	};
	T.getLocalOption ::= fn([Identifier,String] key){
		return this.options[key];
	};
	T.setOption ::= fn([Identifier,String] key,value){
		this.options[key] = value;
	};
	T.toDbgString ::= fn(){
		var s = "Node("+ toJSON(this.options,false)+", "+toJSON(this.incrementalOptions,false);
		foreach(this.nextNodes as var n){
			s+="\n-> "+n.toDbgString();
		}
		s+=")";
		return s;
	};
	T."+=" ::= fn(T other){
		this.nextNodes += other;
		return this;
	};
	T;
});

Std._registerModule('EkkiEkkiKateng/_SpecificNodeTrait',{
	var t = new (Std.require('Std/Traits/GenericTrait'))('EkkiEkkiKateng._SpecificNodeTrait');
	static Node = Std.require('EkkiEkkiKateng/Node');
	t.onInit += fn(Node node, [String,Identifier] nodeType){
		var Constants = Std.require('EkkiEkkiKateng/Constants');
		node.setOption( Constants.NODE_TYPE, nodeType);
	};
	t;
});

Std._registerModule('EkkiEkkiKateng/ProjectNodeTrait',{
	var t = new (Std.require('Std/Traits/GenericTrait'))('EkkiEkkiKateng.ProjectNodeTrait');
	static Node = Std.require('EkkiEkkiKateng/Node');
	t.onInit += fn(Node node, String projectName){
		var Constants = Std.require('EkkiEkkiKateng/Constants');
		Std.require('Std/Traits/basics').addTrait(node,Std.require('EkkiEkkiKateng/_SpecificNodeTrait'),Constants.NODE_TYPE_PROJECT);
		node.setOption( Constants.PROJECT_NAME, projectName);
	};
	t;
});


Std._registerModule('EkkiEkkiKateng/FileNodeTrait',{
	var t = new (Std.require('Std/Traits/GenericTrait'))('EkkiEkkiKateng.FileNodeTrait');
	static Node = Std.require('EkkiEkkiKateng/Node');
	t.onInit += fn(Node node, String fileName){
		var Constants = Std.require('EkkiEkkiKateng/Constants');
		Std.require('Std/Traits/basics').addTrait(node,Std.require('EkkiEkkiKateng/_SpecificNodeTrait'),Constants.NODE_TYPE_FILE);
		node.setOption( Constants.FILE_NAME, fileName);
	};
	t;
});


Std._registerModule('EkkiEkkiKateng/TargetNodeTrait',{
	var t = new (Std.require('Std/Traits/GenericTrait'))('EkkiEkkiKateng.TargetNodeTrait');
	static Node = Std.require('EkkiEkkiKateng/Node');
	t.onInit += fn(Node node, String targetName){
		var Constants = Std.require('EkkiEkkiKateng/Constants');
		Std.require('Std/Traits/basics').addTrait(node,Std.require('EkkiEkkiKateng/_SpecificNodeTrait'),Constants.NODE_TYPE_TARGET);
		node.setOption( Constants.TARGET_NAME, targetName);
	};
	t;
});

Std._registerModule('EkkiEkkiKateng/Utils',{
	static Constants = Std.require('EkkiEkkiKateng/Constants');
	
	var ns = new Namespace;
	ns.collectNodesOfType := fn(Array rootPath, type){
		var resultPaths = [];
		var todo = [ rootPath ];
		while(!todo.empty()){
			var activePath = todo.popFront();
			var node = activePath.back();
			if( node.getLocalOption(Constants.NODE_TYPE) == type ){
				resultPaths += activePath.clone();
			}
			foreach(node.getNextNodes() as var nextNode){
				var p = activePath.clone();
				p += nextNode;
				todo += p;
			}
		}
		return resultPaths;
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
	ns.findOptions := findOptions;
	ns.findOption := fn(Array path, [Identifier,String] key, default=void){
		var options = findOptions(path,key);
		return options.empty() ? default : options.implode(" ");
	};
	ns.scanFiles := fn(String sourceDir, [void,Array] endings=void){
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
	ns;
});

Std._registerModule('EkkiEkkiKateng/CodeBlocksGenerator',{
	static Node = Std.require('EkkiEkkiKateng/Node');
	static Constants = Std.require('EkkiEkkiKateng/Constants');
	static Utils = Std.require('EkkiEkkiKateng/Utils');
	var ns = new Namespace;
	static addTag = fn(Map container,name,attributes = void){
		if(!container['children'])
			container['children'] = [];
		var entry = {
			'type' : "Tag",
			'name' : name
		};
		if(attributes)
			entry['attributes'] = attributes.clone();
		container['children'] += entry;
		return entry;
	};
	static addMeta = fn(p...){
		var entry = addTag(p...);
		entry['type'] = "Meta";
		return entry;
	};
	static toXML = fn(Map description){
		static serializeAttributes = fn(description){
			var s = "";
			var attr = description['attributes'];
			if(attr){
				foreach(attr as var key,var value)
					s+=" "+key+'="'+value+'"';
			}
			return s;
		};
		static process = fn(description, result,level ){
			var addClosingTag = false;
			var name = description['name'];
			var children = description['children'];

			if(description['type']=="Meta"){
				result += "\t"*level + "<?" + name + serializeAttributes(description)+"?>";
			}else if(description['type']=="Tag"){
				result += "\t"*level + "<" + name + serializeAttributes(description);
				if(children&&!children.empty()){
					result.back() += ">";
					addClosingTag = true;
				}else{
					result.back() += " />";
				}
			}
			if(children){
				foreach(children as var d){
					process(d,result,name? level+1 : level);
				}
			}
			if(addClosingTag)
				result += "\t"*level + "</"+name+">";
				
		};
		var result = [];
		process(description,result,0);
		return result.implode("\n");
	};
	
	static targetTypeToCBTypeId = {
		Constants.TARGET_TYPE_STATIC_LIB : 2,
		Constants.TARGET_TYPE_CONSOLE_APP : 1
	};
	
	ns.createProject := fn(Node node){
		outln("Code::Blocks...");
		var projectPath;
		{
			var paths = Utils.collectNodesOfType([node],Constants.NODE_TYPE_PROJECT);
			if(paths.count()!=1)
				Runtime.exception("Project description contains "+paths.count()+" projects. 1 is required!");
			projectPath = paths.front();
		}
		outln("Project: ", Utils.findOption(projectPath,Constants.PROJECT_NAME) );
//		print_r(projectPath);
		var pCompilerFlags = Utils.findOptions(projectPath,Constants.COMPILER_FLAGS);
		print_r(pCompilerFlags);
		
		var targetPaths = Utils.collectNodesOfType(projectPath,Constants.NODE_TYPE_TARGET);
//		foreach(targetPaths as var targetPath){
//			outln("Target: ", Utils.findOption(targetPath,Constants.TARGET_NAME) );
//		}
		// collect files
		var files = new Map;  // filename => [ node, [targets] ]
		foreach(targetPaths as var targetPath){
			var targetName = Utils.findOption(targetPath,Constants.TARGET_NAME) ;
			outln("\nTarget: ", targetName);
			var tCompilerFlags = Utils.findOptions(targetPath.slice(projectPath.count()),Constants.COMPILER_FLAGS);
			print_r(tCompilerFlags);
			
			foreach(Utils.collectNodesOfType(targetPath,Constants.NODE_TYPE_FILE) as var fileNodePath){
				var filename = fileNodePath.back().getLocalOption(Constants.FILE_NAME);
				if(!files[filename])
					files[filename] = [fileNodePath.back(),[]];
				files[filename][1] += targetName;
			}
		}
		// build xml-structure
		var desc_Root = new Map;
		addMeta(desc_Root,"xml",{"version":"1.0","encoding":"UTF-8","standalone":"yes" });
		var desc_projectFile = addTag(desc_Root,"CodeBlocks_project_file");
		addTag(desc_projectFile,"FileVersion",{"major":"1","minor":"6"});
		{
			var desc_project = addTag(desc_projectFile,"Project");
			addTag(desc_project,"Option",{"title" : Utils.findOption(projectPath,Constants.PROJECT_NAME)});
			addTag(desc_project,"Option",{"pch_mode" : "2" });
			addTag(desc_project,"Option",{"compiler" : Utils.findOption(projectPath,Constants.COMPILER_ID) });
			{ // build
				var desc_build = addTag(desc_project,"Build");
				foreach(targetPaths as var targetPath){
					var desc_target = addTag(desc_build,"Target",{"title":Utils.findOption(targetPath,Constants.TARGET_NAME)});
					addTag(desc_target,"Option",{"output" : Utils.findOption(targetPath,Constants.TARGET_OUTPUT),"prefix_auto":"1","extension_auto":"1"});
					var workingDir = Utils.findOption(targetPath,Constants.TARGET_WORKING_DIR);
					if(workingDir)
						addTag(desc_target,"Option",{"workingDir" : workingDir });
					addTag(desc_target,"Option",{"object_output" : Utils.findOption(targetPath,Constants.TARGET_OBJ_FOLDER,"obj")});
					addTag(desc_target,"Option",{"type" : targetTypeToCBTypeId[ Utils.findOption(targetPath,Constants.TARGET_TYPE)]});
					addTag(desc_target,"Option",{"compiler" : Utils.findOption(targetPath,Constants.COMPILER_ID) });
					var desc_compiler = addTag(desc_target,"Compiler");
					foreach(Utils.findOptions(targetPath,Constants.COMPILER_FLAGS) as var flag)
						addTag(desc_compiler,"Add",{"option":flag});
					var desc_linker = addTag(desc_target,"Linker");
					foreach(Utils.findOptions(targetPath,Constants.LINKER_LIBRARIES) as var libs)
						addTag(desc_linker,"Add",{"library":libs});
					foreach(Utils.findOptions(targetPath,Constants.LINKER_FLAGS) as var flag)
						addTag(desc_linker,"Add",{"option":flag});
				}
			}
			{ // global compiler and linker
				var desc_compiler = addTag(desc_project,"Compiler");
				foreach(Utils.findOptions(projectPath,Constants.COMPILER_FLAGS) as var flag)
					addTag(desc_compiler,"Add",{"option":flag});
				var desc_linker = addTag(desc_project,"Linker");
				foreach(Utils.findOptions(projectPath,Constants.LINKER_LIBRARIES) as var libs)
					addTag(desc_linker,"Add",{"library":libs});
				foreach(Utils.findOptions(projectPath,Constants.LINKER_FLAGS) as var flag)
					addTag(desc_linker,"Add",{"option":flag});
			}
			// files
			foreach(files as var filename, var arr){
				var fileNode = arr[0];
				var targets = arr[1];
				var desc_file = addTag(desc_project,"Unit",{"filename":filename});
				if(targets.count()<targetPaths.count()){ // file is not present in all targets
					foreach(targets as var targetName)
						addTag(desc_file,"Option",{"target":targetName});
				}
				foreach( Utils.findOptions([fileNode],Constants.COMPILER_VAR) as var option)
					addTag(desc_file,"Option",{"compilerVar":option});
			}
		}
//		print_r(desc_Root);
//		return toXML(desc_Root);
		return toXML(desc_Root);
//		print_r(files);

//		print_r(targetPaths);
		
//		print_r(Utils.collectNodesOfType(node,Constants.NODE_TYPE_TARGET));
	};
	ns;
});
// --------------------------------------------------------------------


static Traits = Std.require('Std/Traits/basics');

var EEK = Std.require('EkkiEkkiKateng/Constants');
var Node = Std.require('EkkiEkkiKateng/Node');
var ProjectNodeTrait = Std.require('EkkiEkkiKateng/ProjectNodeTrait');
var FileNodeTrait = Std.require('EkkiEkkiKateng/FileNodeTrait');
var TargetNodeTrait = Std.require('EkkiEkkiKateng/TargetNodeTrait');
var Utils = Std.require('EkkiEkkiKateng/Utils');

var baseDir = __DIR__+"/..";

var project = new Node;
Traits.addTrait( project, ProjectNodeTrait, "EScript");	//! \see EkkiEkkiKateng/ProjectNodeTrait
project.setOption( EEK.COMPILER_ID, "gcc");
project.addOptions( EEK.COMPILER_FLAGS, [
			"-std=c++0x",
			"-pedantic","-Wall","-Wextra","-Wshadow","-Wcast-qual","-Wcast-align","-Wlogical-op",
			"-Wredundant-decls","-Wdisabled-optimization","-Wstack-protector","-Winit-self","-Wmissing-include-dirs",
			"-Wswitch-default","-Wswitch-enum","-Wctor-dtor-privacy","-Wstrict-null-sentinel","-Wno-non-template-friend",
			"-Wold-style-cast","-Woverloaded-virtual","-Wno-pmf-conversions","-Wsign-promo","-Wmissing-declarations"
]);



var allFiles = new Node;
foreach(Utils.scanFiles( baseDir, [".cpp",".h",".escript",".txt",".rc"] ) as var filename){
	var file = new Node;
	Traits.addTrait( file, FileNodeTrait, filename);	//! \see EkkiEkkiKateng/FileNodeTrait
	if(filename.endsWith(".rc")){ // ???????????????????????????????????
		file.setOption(EEK.COMPILER_VAR, "WINDRES");
	}
	allFiles += file;
}

{
	var target = new Node;
	Traits.addTrait( target, TargetNodeTrait, "StaticLib");	//! \see EkkiEkkiKateng/TargetNodeTrait
	
	target.setOption( EEK.TARGET_TYPE, EEK.TARGET_TYPE_STATIC_LIB);
	target.setOption( EEK.TARGET_OUTPUT, "libEScript");
	target.setOption( EEK.TARGET_OBJ_FOLDER, ".obj/dbgTest");
	target.addOptions( EEK.COMPILER_FLAGS, [ "-g","-O3" ]);
	target += allFiles;
	project += target;
}

{
	var target = new Node;
	Traits.addTrait( target, TargetNodeTrait, "Tests");	//! \see EkkiEkkiKateng/TargetNodeTrait
	
	target.setOption( EEK.TARGET_TYPE, EEK.TARGET_TYPE_CONSOLE_APP);
	target.setOption( EEK.TARGET_OUTPUT, "EScriptTest");
	target.setOption( EEK.TARGET_OBJ_FOLDER, ".obj/test");
	target.setOption( EEK.TARGET_WORKING_DIR, ".");
	target.addOptions( EEK.COMPILER_FLAGS, [ "-g","-O3","-DES_BUILD_TEST_APPLICATION" ]);
	target += allFiles;
	project += target;

//	outln(allFiles.findOption(EEK.COMPILER_FLAGS,[project,target]));

}


var generator = Std.require('EkkiEkkiKateng/CodeBlocksGenerator');
IO.saveTextFile("test.cbp", generator.createProject( project ));

return true;

//print_r(project.toDbgString());
