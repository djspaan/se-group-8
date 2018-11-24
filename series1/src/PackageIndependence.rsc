module PackageIndependence

import IO;
import String;
import List;
import Set;
import String;
import Map;
import util::Math;

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import analysis::m3::Core;

import Loc;


map[str, loc] listTypes(set[Declaration] asts){
	map[str, loc] knownTypes = ();
	set[str] usedTypes = {};
	for(unit <- asts){
		if(\compilationUnit(pkg, imports, types) := unit){
			for(cls <- types){
				knownTypes += (getType(pkg, cls): unit.src);
			}
		}
	}
	return knownTypes;
}

real meanIndependenceScoreForM3(M3 project){
	int locs = 0;
	int publicLocs = 0;
	if(<_, set[Declaration] asts> := createM3sAndAstsFromFiles(files(project))){
		map[str, loc] knownTypes = listTypes(asts);
		set[str] usedTypes = {};
		for(unit <- asts){
			locs += countLinesForLocation(unit.src);
		}
		
		for(\compilationUnit(pkg, imports, types) <- asts){
			if(/(\.test|\.junit)/ := getPkgName(pkg)) 
				continue;
			
			set[str] importPkgs = {k | \import(str i) <- imports, str k <- knownTypes, startsWith(k, i)};
			names = (split(".", pkg)[-1]: pkg | str pkg <- importPkgs);
			visit(types){
				case Type t: top-down visit(t){ 
					case \simpleName(str name): if(name in names) usedTypes += names[name];
				}
			}
		}
		publicUnits = { knownTypes[k] | k <- usedTypes };
		publicLocs = sum({countLinesForLocation(unit) | unit <- publicUnits });
		return publicLocs / toReal(locs);
	}
	return 0.0;
}

real meanTestScoreForM3(M3 project){
	int locs = 0;
	int publicLocs = 0;
	if(<_, set[Declaration] asts> := createM3sAndAstsFromFiles(files(project))){
		map[str, loc] knownTypes = listTypes(asts);
		set[str] usedTypes = {};
		for(unit <- asts){
			locs += countLinesForLocation(unit.src);
		}
		
		for(\compilationUnit(pkg, imports, types) <- asts){
			if(!(/(\.test|\.junit)/ := getPkgName(pkg))) 
				continue;
			
			set[str] importPkgs = {k | \import(str i) <- imports, str k <- knownTypes, startsWith(k, i)};
			names = (split(".", pkg)[-1]: pkg | str pkg <- importPkgs);
			visit(types){
				case Type t: top-down visit(t){ 
					case \simpleName(str name): if(name in names) usedTypes += names[name];
				}
			}
		}
		publicUnits = { knownTypes[k] | k <- usedTypes };
		publicLocs = sum({countLinesForLocation(unit) | unit <- publicUnits });
		return publicLocs / toReal(locs);
	}
	return 0.0;
}

str getRankForIndependenceScore(real independence){
	return independence > 0.142 ? "-" : "+";
}

str getPkgName(\package(name)) = name;
str getPkgName(\package(parentPackage,name)) = "<getPkgName(parentPackage)>.<name>";

str getType(pkg, cls){
	pname = getPkgName(pkg);
	switch(cls){
		case \class(name, _, _, _): return "<pname>.<name>";
		case \interface(name, _, _, _): return "<pname>.<name>";
	}
	return "huh";
}
