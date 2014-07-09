/* ----------------------------------------------------------------
	This file is part of the EkkiEkkiKateng build tool.
	Copyright (C) 2013-2014 Claudius Jähn (ClaudiusJ@live.de)
	Licensed under the MIT License. See LICENSE file for details.
	https://github.com/ClaudiusJ/EkkiEkkiKateng
   ---------------------------------------------------------------- */

assert(EScript.VERSION>=701); // 0.7.1

static Node = module('./Node');
static Utils = module('./Utils');
static Set = module('Std/Set');

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

static CompilerOptions = module('./CompilerOptions');
static ExternalLibs = module('./ExternalLibs');
static Files = module('./Files');
static LinkerOptions = module('./LinkerOptions');
static Projects = module('./Projects');
static Targets = module('./Targets');
static VirtualTargets = module('./VirtualTargets');


static getTargetOptions = fn(targetPath){
	var compilerSearchFolders = [];
	var librarySearchFolders = [];
	var libraries = [];
	
	foreach(CompilerOptions.getSearchPaths(targetPath) as var folder){
		if(!compilerSearchFolders.contains(folder))
			compilerSearchFolders += folder;
	}

	foreach(LinkerOptions.getSearchPaths(targetPath) as var folder){
		if(!librarySearchFolders.contains(folder))
			librarySearchFolders += folder;
	}
	foreach(LinkerOptions.getLibraries(targetPath) as var lib){
		if(!libraries.contains(lib))
			libraries += lib;
	}

	//! \todo LinkerOptions.getLibraries(...

	// external libraries
	foreach(ExternalLibs.collect(targetPath) as var libPath){
		foreach(CompilerOptions.getSearchPaths(libPath) as var folder){
			if(!compilerSearchFolders.contains(folder))
				compilerSearchFolders += folder;
		}
		foreach(LinkerOptions.getSearchPaths(libPath) as var folder){
			if(!librarySearchFolders.contains(folder))
				librarySearchFolders += folder;
		}
		foreach(LinkerOptions.getLibraries(libPath) as var lib){
			if(!libraries.contains(lib))
				libraries += lib;
		}
	}
	// dependencies on other targets
	foreach(targetPath.back().getNextNodes() as var nextNode){
		foreach(Targets.collect([nextNode]) as var otherTargetPath){
			var otherOptions = getTargetOptions(otherTargetPath);

			// inherit libraries
			foreach(otherOptions.librarySearchFolders as var folder){
				if(!librarySearchFolders.contains(folder))
					librarySearchFolders += folder;
			}
			foreach(otherOptions.libraries as var lib){
				if(!libraries.contains(lib))
					libraries += lib;
			}
			
			var lib = otherOptions.output;
			// split output filename into folder and file; if the ending is missing, 
			//  the lib is not found given a complete path.
			if(lib){ 
				var folder = IO.dirname(lib);
				if(!folder.empty()){
					lib = lib.substr(folder.length()+1);
					if(!librarySearchFolders.contains(folder))
						librarySearchFolders += folder;
				}
				if(!libraries.contains(lib))
					libraries += lib;
			}
		}
	}
	libraries.reverse();// ????????????????

	var output = Targets.getOutput(targetPath);
	var fullOutputFilename = output;
	if( Targets.isType_ConsoleApp(targetPath) ){
		fullOutputFilename += ".exe";
	}else if( Targets.isType_StaticLib(targetPath) ){
		fullOutputFilename += ".a";
	}else{
		Runtime.warn("Unknown target type.");
	}
		
	return new ExtObject({
		$compilerSearchFolders	: compilerSearchFolders,
		$compilerOptions		: CompilerOptions.getOptions(targetPath),
		$linkerOptions			: LinkerOptions.getOptions(targetPath),
		$fullOutputFilename		: fullOutputFilename,
		$librarySearchFolders	: librarySearchFolders,
		$libraries				: libraries,
		$name 					: Targets.getName(targetPath),
		$output					: output,
	});

};


var CodeBlocksGenerator = new Namespace;
CodeBlocksGenerator.createProject := fn(Node root){
	outln("Code::Blocks...");
	var projectPath;
	{
		var paths = Projects.collect([root]);
		if(paths.count()!=1)
			Runtime.exception("Project description contains "+paths.count()+" projects. 1 is required!");
		projectPath = paths.front();
	}
	outln("Project: ", Projects.getName(projectPath));

	var targetPaths = Targets.collect(projectPath);

	// collect files
	var files = new Map;  // filename => [ node, [targets] ]
	foreach(targetPaths as var targetPath){
		var targetName = Targets.getName(targetPath);
		outln("Target: ", targetName);

		
		foreach(Files.collect(targetPath) as var filePath){
			var filename = Files.getName(filePath);
			if(!files[filename])
				files[filename] = [filePath.back(),new Set];
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
		addTag(desc_project,"Option",{"title" : Projects.getName(projectPath)});
		addTag(desc_project,"Option",{"pch_mode" : "2" });
		addTag(desc_project,"Option",{"compiler" : CompilerOptions.getCompilerId(projectPath)});
		
		{ // build (targets)
			var desc_build = addTag(desc_project,"Build");
			foreach(targetPaths as var targetPath){
				var pathToBeforeProject = targetPath.slice(projectPath.count());
				var options = getTargetOptions(pathToBeforeProject);

				var desc_target = addTag(desc_build,"Target",{"title": options.name});
				addTag(desc_target,"Option",{
						"output" : options.output,
						"prefix_auto":"1",
						"extension_auto":"1"
				});
				var workingDir = Targets.getWorkingDir(targetPath);
				if(workingDir)
					addTag(desc_target,"Option",{"workingDir" : workingDir });
				addTag(desc_target,"Option",{"object_output" : Targets.getObjectFolder(targetPath,"obj")});

				if( Targets.isType_ConsoleApp(targetPath) ){
					addTag(desc_target,"Option",{"type" : "1"});
				}else if( Targets.isType_StaticLib(targetPath) ){
					addTag(desc_target,"Option",{"type" : "2"});
				}else{
					Runtime.warn("Unknown target type.");
				}
								
				addTag(desc_target,"Option",{
						"compiler" : CompilerOptions.getCompilerId(targetPath) 
				});
		

				// compiler options
				var desc_compiler = addTag(desc_target,"Compiler");
				foreach(options.compilerOptions as var flag)
					addTag(desc_compiler,"Add",{"option":flag});
				foreach(options.compilerSearchFolders as var folder)
					addTag(desc_compiler,"Add",{"directory":folder});
				
				
				// linker options
				var desc_linker = addTag(desc_target,"Linker");
				foreach(options.linkerOptions as var flag)
					addTag(desc_linker,"Add",{"option":flag});
				foreach(options.librarySearchFolders as var folder)
					addTag(desc_linker,"Add",{"directory":folder});
				foreach(options.libraries as var lib)
					addTag(desc_linker,"Add",{"library":lib});

//				outln(options.name);
//				print_r(options.libraries);
				
//////////								<ResourceCompiler>
//////////					<Add directory="modules/EScript" />
//////////				</ResourceCompiler>
				
			}
		}
		{ // virtual targets
			var vTargetPaths = VirtualTargets.collect(projectPath);
			var desct_vTargets = addTag(desc_project,"VirtualTargets");
			if(!vTargetPaths.empty()){
				foreach(vTargetPaths as var vTargetPath){
					var vTargetName = VirtualTargets.getName(vTargetPath);
					var targetNames = "";
					foreach( Targets.collect(vTargetPath) as var tPath)
						targetNames += Targets.getName(tPath) + ";";
					outln("vTarget: ", vTargetName," (",targetNames,")");
					addTag(desct_vTargets,"Add",{
								"alias" : vTargetName,
								"targets" : targetNames
					});
				}
			}
		}
		{ // global compiler and linker
			var desc_compiler = addTag(desc_project,"Compiler");
			foreach(CompilerOptions.getOptions(projectPath) as var flag)
				addTag(desc_compiler,"Add",{"option":flag});
			foreach(CompilerOptions.getSearchPaths(projectPath) as var folder)
				addTag(desc_compiler,"Add",{"directory":folder});
			
			var desc_linker = addTag(desc_project,"Linker");
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
			// add file options
			if( filename.endsWith(".rc") )
				addTag(desc_file,"Option",{"compilerVar":"WINDRES"});
		}
	}
//		print_r(desc_Root);
//		return toXML(desc_Root);
	return toXML(desc_Root);
};

return CodeBlocksGenerator;