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


set[loc] getUnitLocs(M3 m3){ 
	return files(m3);
}

str readJavaFile(loc mloc){
	return removeComments(readFile(mloc));
}

rel[str, loc] srcs(M3 m3){
	return {<readJavaFile(mloc), mloc> | loc mloc <- files(m3)};
}

/*
 * Split method body to lines;
 */
rel[list[str], loc] lines(M3 m3){
	return {<[trim(line)| line <- split("\n", src)], mloc> | <str src, loc mloc> <- srcs(m3)};
}

/*
 * Clean invalid (empty) lines
 */
rel[list[str], loc] cleanLines(M3 m3){
	return {<[l | l <- ls, validLine(l)], mloc> | <list[str] ls, loc mloc> <- lines(m3)};
} 

bool validLine(str l) = size(l) > 0 && ! (/^import\s+/ := l);

Trie createLinesTrie(rel[list[str], loc] lines){
	t0 = getMilliTime();
	trie = createSuffixTrie(lines, minSuffixLength=0);
	t1 = getMilliTime();
	//println(" Building trie took <t1 - t0> ms");
	return trie;
}

/** prune out all nodes without duplicates */
Trie pruneTrie(Trie trie){

	// 1 bottom-up visit with all 3 cases would have the same effect, but is slower.
	trie = top-down visit(trie){
		case \leaf(_, _, _) => \emptyleaf()
		case \node(_, {v}, _) => \emptyleaf()
	}
	trie = bottom-up visit(trie){
		case \node(cs, vs, d) => \node((k: cs[k] | k <- cs, !(\emptyleaf() := cs[k])), vs, d)
	}
	return trie;
}


Trie fixLineNumbers(Trie trie){
	return bottom-up visit(trie){
		case \node(cs, vs, d) => \node(cs, {<l, n + d>| <loc l, int n> <- vs} , d)
	}
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

map[value, int] getUniqueDuplications(Trie trie){
	dupes = getAllDuplications(trie);
	flatDupes = (l: dupes[ls] | ls <- dupes, l <- ls);
	for(l <- sort({s | s <- flatDupes})){ println(l);}
	blacklist = {};
	for(<loc file, int offset> <- flatDupes){
		count = flatDupes[<file, offset>];
		blacklist = blacklist + {<file, offset - i> | int i <- [1..count]};
	}
	return (k: flatDupes[k] | k <- flatDupes, k notin blacklist);
}




/* Finds all duplications of size >= 6, and returns a set of the lines 
 * where these locations were found.
 */
public rel[loc, int] getDuplicationsForM3(M3 m3){
	rel[list[str], loc] lines = cleanLines(m3);
	
	Trie trie = createLinesTrie(lines);
	Trie duplicateTrie = pruneTrie(trie);
	duplicateTrie = fixLineNumbers(duplicateTrie);
	set[tuple[loc, int]] duplicateLines = {};
	visit(duplicateTrie){
		case \node(cs, vs, d): 
			if(d == 6){
				for(<loc f, int l> <- vs){
					// add the line as well as  the previous 5 lines
					duplicateLines += {<f, l + i> | i <- [-5..1]}; 
				}
			}
			else if(d > 6) {
				// add just the line
				duplicateLines += {<f, l> | <loc f, int l> <- vs};
			}
	}
	return duplicateLines;
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
	rel[loc, int] dups = getDuplicationsForM3(m3);
	int totalLines = (0 | it + size(lines) | <list[str] lines, _> <- cleanLines(m3));
	int duplicateCount = size(dups);
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
