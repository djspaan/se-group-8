module util::Trie

import List;


data Trie 
	= \node(map[str, Trie] children, set[value] vs, int depth)
	| \emptyleaf() // leaf exists as a workaround replacing pattern matching on empty maps
	;


Trie newTrie(int depth = 0) = \node((), {}, depth);


Trie insertTrie(\node(cs, vs, depth), list[str] toks, value v){
	switch(toks) {
		case [token, *ts]: {
				Trie child;
	       		if(token notin cs) {
	        		child = newTrie(depth = depth + 1);
	    		}
	    		else {
	        		child = cs[token];
	    		}
				Trie newchild = insertTrie(child, ts, v);
	    		return \node(cs + (token: newchild), vs + {v}, depth);
    		}
    	case []:
    		return \node(cs, vs + {v}, depth);
	}
}

list[list[str]] suffixes(list[str] toks){
	int n = size(toks);
	return [slice(toks, i, n - i) | i <- [0..n]];
}

Trie insertSuffixes(Trie trie, list[str] toks, value v, int minLength = 0){
	int i = 0;
	for(list[str] suffix <- suffixes(toks)){
		if(size(suffix) < minLength) continue;
		trie = insertTrie(trie, suffix, <v, i>);
		i = i + 1;
	}
	return trie;
}

Trie createSuffixTrie(rel[list[str], value] elems, int minSuffixLength = 0){
	Trie trie = newTrie();
	for(<toks, v> <- elems){
		trie = insertSuffixes(trie, toks, v, minLength=minSuffixLength);
	}
	return trie;
}
