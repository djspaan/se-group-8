module tests::util::Trie

import util::Trie;
import List;
import IO;

set[str] getValues(\leaf(lpath, v, _), list[str] path){
	if(path == lpath) return {v};
	else return {};
}

set[str] getValues(\node(children, vs, _), [str token, *path]){
	if(token in children) return getValues(children[token], path);
	else return {};
}

set[str] getValues(\node(_, vs, _), []) = vs;
set[str] getValues(Trie _, list[str] _) = {};


test bool testInsertTrie(rel[list[str], str] keyValuePairs){
	Trie trie = \node((), {}, 0);
	for(<k, v> <- keyValuePairs){
		trie = insertTrie(trie, k, v);
	}
	for(<k, v> <- keyValuePairs){
		if(v notin getValues(trie, k)){
			println(trie);
			return false;
		}
	}
	return true;
}

/**
 * Test if single values are inserted as a single leaf, rather than N nodes.
 */
test bool testInsertLeaf(list[str] k, str val){
	switch(k){
		case []: return true;
		case [_]: return true;
		case [a, *bc]:{
			Trie trie = \node((), {}, 0);
			\node(cs, _, _) = insertTrie(trie, [a, *bc], val);
			return (\leaf(bc, _, _) := cs[a]);
		}
	}
}

/**
 * Test if leafs are expanded into nodes
 */
test bool testInsertIntoLeaf(list[str] k, str val){
	switch(k){
		case []: return true;
		case [_]: return true;
		case [a, *bc, d]:{
			Trie trie0 = \node((), {}, 0);
			trie1 = insertTrie(trie0, [a, *bc], val);
			\node(cs, _, _) = insertTrie(trie1, [a, *bc, d], "<val>2");
			return (\node(_, _, _) := cs[a]);
		}
	}
}