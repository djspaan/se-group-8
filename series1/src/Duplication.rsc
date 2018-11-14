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

import Loc;
import util::Trie;


set[loc] getLocMethods(M3 m3){ 
	return methods(m3);
}

str readMethod(loc mloc){
	return removeComments(readFile(mloc));
}

rel[str, loc] methodSrcs(M3 m3){
	return {<readMethod(mloc), mloc> | loc mloc <- getLocMethods(m3)};
}

/*
 * Split method body to lines;
 */
rel[list[str], loc] methodLines(M3 m3){
	return {<[trim(line)| line <- split("\n", src)], mloc> | <str src, loc mloc> <- methodSrcs(m3)};
}

/*
 * Clean invalid (empty) lines
 */
rel[list[str], loc] cleanMethodLines(M3 m3){
	return {<[l | l <- lines, validLine(l)], mloc> | <list[str] lines, loc mloc> <- methodLines(m3)};
} 

Trie createLinesTrie(M3 m3){
	rel[list[str], loc] lines = cleanMethodLines(m3);
	return createSuffixTrie(lines, minSuffixLength=6);
}

/** prune out all nodes without duplicates */
Trie pruneTrie(Trie trie){
	trie = bottom-up visit(trie){
		case \node(_, {v}, _) => \emptyleaf()
		case \node(cs, vs, d) => \node((k: cs[k] | k <- cs, !(\emptyleaf() := cs[k])), vs, d)
	}	
	return trie;
}

map[set[value], int] getAllDuplications(Trie trie){
	if(\node(cs, vs, d) := trie){
		map[set[value], int] childCounts = ();
		for(k <- cs){
			childCounts = childCounts + getAllDuplications(cs[k]); 	
		}
		if(size(cs) == 0){
			childCounts = childCounts + (vs: d | v <- vs, d >= 6);
		}			
		return childCounts;
	}
	else{
		throw RuntimeException("No.");
	}
}

map[value, int] getDuplications(Trie trie){
	dupes = getAllDuplications(trie);
	flatDupes = (l: dupes[ls] | ls <- dupes, l <- ls);
	blacklist = {};
	for(<method, offset> <- flatDupes){
		count = flatDupes[<method, offset>];
		blacklist = blacklist + {<method, offset - i> | int i <- [1..count]};
	}
	return (k: flatDupes[k] | k <- flatDupes, k notin blacklist);
}


bool validLine(str l) = size(trim(l)) > 0;

/* Finds all duplications of size >= 6, and returns a map of the set of locations where
 * these duplications were found to the number of lines that are duplicated between these
 * locations.
 */
public map[value, int] getDuplicationsForM3(M3 m3){
	Trie trie = createLinesTrie(m3);
	Trie duplicateTrie = pruneTrie(trie);
	return getDuplications(duplicateTrie);
}


public map[value, int] getDuplicationsForProject(loc project){
	M3 m3 = createM3FromEclipseProject(project);
	return getDuplicationsForM3(m3);
}

/** returns the ratio of number of duplications to the total lines considered as a tuple */
public tuple[int, int] countDuplicationsForProject(loc project){
	M3 m3 = createM3FromEclipseProject(project);
	map[value, int] count = getDuplicationsForM3(m3);
	int totalLines = (0 | it + size(lines) | <lines, _> <- cleanMethodLines(m3));
	int duplicateCount = (0 | it + count[locs] | locs <- count);
	return <duplicateCount, totalLines>;
}


