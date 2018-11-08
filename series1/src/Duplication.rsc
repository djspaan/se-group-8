module Duplication

import IO;
import String;
import List;
import Set;
import Map;
import util::Math;

import lang::java::m3::Core;
import lang::java::m3::AST;
import analysis::m3::Core;


set[loc] getLocMethods(loc dir){ 
	return methods(createM3FromDirectory(dir));
}

rel[str, loc] methodSrcs(loc dir){
	return {<readFile(mloc), mloc> | loc mloc <- getLocMethods(dir)};
}

lrel[list[str], loc] methodLines(loc dir){
	return [<[trim(line)| line <- split("\n", src)], mloc> | <str src, loc mloc> <- methodSrcs(dir)];
}

list[tuple[list[str], loc]] cleanMethodLines(loc dir){
	return [<[l | l <- lines, validLine(l)], mloc> | <list[str] lines, loc mloc> <- methodLines(dir)];
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


lrel[list[str], tuple[loc, int]] allFragments(loc dir){
	fragmentsPerMethod = [ methodFragments(lines, mloc) | <list[str] lines, loc mloc> <- cleanMethodLines(dir)];
	return [<f, mloc> | lrel[list[str], tuple[loc, int]] fragmentSet <- fragmentsPerMethod
					  , <list[str] f, tuple[loc, int] mloc> <- fragmentSet];
}
/*
 * Finds all blocks of length 6 and finds duplicates,
 * includes comments, documentation, etc, and combines them into a 
 * map mapping fragments to locations.
 */
map[list[str], set[tuple[loc, int]]] duplicationMap(loc dir) {
	map[list[str], rel[loc, int]] fragmentLocMap = toMap(allFragments(dir));
	return (frag: fragmentLocMap[frag] | list[str] frag <- fragmentLocMap, size(fragmentLocMap[frag]) > 1);
}

set[tuple[loc, int]] allDuplicationLines(loc dir){
	return {<location, offset + line> | duplocs <- range(duplicationMap(dir))
									  , <loc location, int offset> <- duplocs
									  , line <- [0..6] } ;
}

int countDuplications(loc dir){
	return size(allDuplicationLines(dir));
}


