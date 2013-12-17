/* ----------------------------------------------------------------
	This file is part of the EkkiEkkiKateng build tool.
	Copyright (C) 2013 Claudius Jähn (claudiusj@users.berlios.de)
	Licensed under the MIT License. See LICENSE file for details.
	https://github.com/ClaudiusJ/EkkiEkkiKateng
   ---------------------------------------------------------------- */

assert(EScript.VERSION>=607); // 0.6.7

static Node = Std.require('EkkiEkkiKateng/Node');
static Constants = Std.require('EkkiEkkiKateng/Constants');
static Utils = Std.require('EkkiEkkiKateng/Utils');

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

var CodeBlocksGenerator = new Namespace;
CodeBlocksGenerator.createProject := fn(Node node){
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
				var pathToBeforeProject = targetPath.slice(projectPath.count());
				var desc_compiler = addTag(desc_target,"Compiler");
				foreach(Utils.findOptions(pathToBeforeProject,Constants.COMPILER_FLAGS) as var flag)
					addTag(desc_compiler,"Add",{"option":flag});
				var desc_linker = addTag(desc_target,"Linker");
				foreach(Utils.findOptions(pathToBeforeProject,Constants.LINKER_LIBRARIES) as var libs)
					addTag(desc_linker,"Add",{"library":libs});
				foreach(Utils.findOptions(pathToBeforeProject,Constants.LINKER_FLAGS) as var flag)
					addTag(desc_linker,"Add",{"option":flag});
			}
		}
		{ // virtual targets
			var vTargetPaths = Utils.collectNodesOfType(projectPath,Constants.NODE_TYPE_VIRTUAL_TARGET);
			var desct_vTargets = addTag(desc_project,"VirtualTargets");
			if(!vTargetPaths.empty()){
				foreach(vTargetPaths as var vTargetPath){
					var targetNames = "";
					foreach(Utils.collectNodesOfType(vTargetPath,Constants.NODE_TYPE_TARGET) as var tPath)
						targetNames += Utils.findOption(tPath,Constants.TARGET_NAME) + ";";
					addTag(desct_vTargets,"Add",{
								"alias" : Utils.findOption(vTargetPath,Constants.VIRTUAL_TARGET_NAME),
								"targets" : targetNames
					});
				}
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
			// add file options
			if( filename.endsWith(".rc") )
				addTag(desc_file,"Option",{"compilerVar":"WINDRES"});
			foreach( Utils.findOptions([fileNode],Constants.COMPILER_VAR) as var option)
				addTag(desc_file,"Option",{"compilerVar":option});
		}
	}
//		print_r(desc_Root);
//		return toXML(desc_Root);
	return toXML(desc_Root);
};

return CodeBlocksGenerator;