module Duplication

import IO;
import String;
import List;
import Set;
import Map;
import Exception;
import util::Math;
import util::Benchmark;

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import analysis::m3::Core;

import Loc;
import util::Trie;


set[loc] getMethodLocs(M3 m3){ 
	return methods(m3);
}

str readMethod(loc mloc){
	return removeComments(readFile(mloc));
}

rel[str, loc] methodSrcs(M3 m3){
	return {<readMethod(mloc), mloc> | loc mloc <- getMethodLocs(m3)};
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

Trie createLinesTrie(rel[list[str], loc] lines){
	t0 = getMilliTime();
	trie = createSuffixTrie(lines, minSuffixLength=6);
	t1 = getMilliTime();
	println(" Building trie took <t1 - t0> ms");
	return trie;
}

/** prune out all nodes without duplicates */
Trie pruneTrie(Trie trie){

	// 1 bottom-up visit with all 3 cases would have the same effect, but is slower.
	trie = top-down visit(trie){
		case \leaf(_, _, _) => \emptyleaf()
		case \node(_, {v}, _) => \emptyleaf()
	}
	trie = top-down visit(trie){
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
		throw IllegalArgument("Non-\\node type trie nodes must be pruned before applying getAllDuplications.");
	}
}

map[value, int] getDuplications(Trie trie){
	dupes = getAllDuplications(trie);
	flatDupes = (l: dupes[ls] | ls <- dupes, l <- ls);
	blacklist = {};
	for(<loc method, int offset> <- flatDupes){
		count = flatDupes[<method, offset>];
		blacklist = blacklist + {<method, offset - i> | int i <- [1..count]};
	}
	return (k: flatDupes[k] | k <- flatDupes, k notin blacklist);
}


bool validLine(str l) = size(l) > 0;

/* Finds all duplications of size >= 6, and returns a map of the set of locations where
 * these duplications were found to the number of lines that are duplicated between these
 * locations.
 */
public map[value, int] getDuplicationsForM3(M3 m3){
	rel[list[str], loc] lines = cleanMethodLines(m3);
	t0 = getMilliTime();
	Trie trie = createLinesTrie(lines);
	t1 = getMilliTime();
	//println("Time spent building trie: <t1 - t0> ms"); // = negligible :)
	Trie duplicateTrie = pruneTrie(trie);
	return getDuplications(duplicateTrie);
}


public map[value, int] getDuplicationsForProject(loc project){
	M3 m3 = createM3FromEclipseProject(project);
	return getDuplicationsForM3(m3);
}

public tuple[int, int] countDuplicationsForProject(loc project){
	M3 m3 = createM3FromEclipseProject(project);
	return countDuplicationsForM3(m3);
}

/** returns the ratio of number of duplications to the total lines considered as a tuple */
public tuple[int, int] countDuplicationsForM3(M3 m3){
	map[value, int] count = getDuplicationsForM3(m3);
	int totalLines = (0 | it + size(lines) | <list[str] lines, _> <- cleanMethodLines(m3));
	int duplicateCount = (0 | it + count[locs] | locs <- count);
	return <duplicateCount, totalLines>;
}

public str getDuplicationScore(real duplicatepct){
	scores = [s | <int n, str s> <- [
		<5, "++">,
		<10, "+">,
		<15, "o">,
		<25, "-">,
		<-1, "--">
	], n >= duplicatepct || n < 0];
	return scores[0];
} 
