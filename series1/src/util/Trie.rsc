module util::Trie

import List;


data Trie[&Val]
	= \node(map[str, Trie] children, set[&Val] vs, int depth)
	| \leaf(list[str] path, &Val v, int depth)
	| \emptyleaf() // emptyleaf exists as a workaround for rascal not supporting pattern matching on empty maps
	;


Trie[&Val] newTrie(int depth = 0) = \node((), {}, depth);


Trie[&Val] insertTrie(\leaf([], &Val v, int depth), list[str] path, &Val newv){
	return insertTrie(\node((), {v}, depth), path, newv);
}

Trie[&Val] insertTrie(\leaf([str t, *ts], &Val v, int depth), list[str] path, &Val newv){
	newleaf = \leaf(ts, v, depth + 1);
	return insertTrie(\node((t: newleaf), {v}, depth), path, newv);
}

Trie[&Val] insertTrie(\node(cs, vs, depth), list[str] toks, &Val v){
	switch(toks) {
		case [token, *ts]: {
				Trie child;
	       		if(token notin cs) {
	        		child = leaf(ts, v, depth + 1);
	    		}
	    		else {
	        		child = insertTrie(cs[token], ts, v);;
	    		}
	    		return \node(cs + (token: child), vs + {v}, depth);
    		}
    	case []:
    		return \node(cs, vs + {v}, depth);
	}
}

list[list[str]] suffixes(list[str] toks){
	int n = size(toks);
	return [slice(toks, i, n - i) | i <- [0..n]];
}

Trie[tuple[&Val, int]] insertSuffixes(Trie[tuple[&Val, int]] trie, list[str] toks, &Val v, int minLength = 0){
	int i = 0;
	for(list[str] suffix <- suffixes(toks)){
		if(size(suffix) < minLength) continue;
		trie = insertTrie(trie, suffix, <v, i>);
		i = i + 1;
	}
	return trie;
}

Trie[tuple[&Val, int]] createSuffixTrie(rel[list[str], &Val] elems, int minSuffixLength = 0){
	Trie[tuple[&Val, int]] trie = \node((), {}, 0);
	for(<toks, v> <- elems){
		trie = insertSuffixes(trie, toks, v, minLength=minSuffixLength);
	}
	return trie;
}
