module Duplication

import IO;
import String;
import List;
import Set;
import Map;
import util::Math;

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import analysis::m3::Core;


set[loc] getLocMethods(M3 m3){ 
	return methods(m3);
}

rel[str, loc] methodSrcs(M3 m3){
	return {<readFile(mloc), mloc> | loc mloc <- getLocMethods(m3)};
}

lrel[list[str], loc] methodLines(M3 m3){
	return [<[trim(line)| line <- split("\n", src)], mloc> | <str src, loc mloc> <- methodSrcs(m3)];
}

list[tuple[list[str], loc]] cleanMethodLines(M3 m3){
	return [<[l | l <- lines, validLine(l)], mloc> | <list[str] lines, loc mloc> <- methodLines(m3)];
} 

bool validLine(str line){
	 if(size(line) == 0) return false;
	 return true;
}

lrel[list[str], tuple[loc, int]] methodFragments(list[str] lines, loc methodLoc){
	if(size(lines) < 6){
		return [];
	}
	return [ <slice(lines, i, min(size(lines), 6)), <methodLoc, i>> | int i <- [0..max(1, size(lines) - 6)]];
} 


lrel[list[str], tuple[loc, int]] allFragments(M3 m3){
	fragmentsPerMethod = [ methodFragments(lines, mloc) | <list[str] lines, loc mloc> <- cleanMethodLines(m3)];
	return [<f, mloc> | lrel[list[str], tuple[loc, int]] fragmentSet <- fragmentsPerMethod
					  , <list[str] f, tuple[loc, int] mloc> <- fragmentSet];
}
/*
 * Finds all blocks of length 6 and finds duplicates,
 * includes comments, documentation, etc, and combines them into a 
 * map mapping fragments to locations.
 */
map[list[str], set[tuple[loc, int]]] duplicationMap(M3 m3) {
	map[list[str], rel[loc, int]] fragmentLocMap = toMap(allFragments(m3));
	return (frag: fragmentLocMap[frag] | list[str] frag <- fragmentLocMap, size(fragmentLocMap[frag]) > 1);
}

set[tuple[loc, int]] allDuplicationLines(M3 m3){
	return {<location, offset + line> | duplocs <- range(duplicationMap(m3))
									  , <loc location, int offset> <- duplocs
									  , line <- [0..6] } ;
}

int countDuplications(M3 m3){
	return size(allDuplicationLines(m3));
}

int countDuplicationsForProject(loc project){
	M3 m3 = createM3FromEclipseProject(project);
	return countDuplications(m3);
}


