module UnitComplexity

import IO;
import Set;
import List;
import util::Math;

import lang::java::m3::Core;
import lang::java::m3::AST;
import analysis::m3::Core;
 


value runForSmallSQL(){
	M3 m3 = createM3FromDirectory(|home:///se-group-8/projects/smallsql|);
	asts = toList(getASTs(m3));
	return avgComplexity(asts);
}


value runForHSqlDb(){
	M3 m3 = createM3FromDirectory(|home:///se-group-8/projects/hsqldb|);
	asts = toList(getASTs(m3));
	return avgComplexity(asts);
}


bool declIsMethod(Declaration d){
	return (  \method(x, y, z, u) := d) 
		   || (\method(x, y, z, u, v) := d)
		   || (\constructor(x, y, z, u) := d);
}

set[Declaration] getASTs(M3 m3){
	mthds = methods(m3);
	<m3, fileasts> = createM3sAndAstsFromFiles(mthds);
	set[Declaration] decls = {};
	visit(fileasts){
		case Declaration s: decls = decls + s;
	}
	return {decl | decl <- decls, declIsMethod(decl)};
}

int getComplexity(node ast){
	int i = 1;
	visit(ast){
		case \foreach(_, _, _): i = i + 1;
		case \for(_, _, _): i = i + 1;
		case \for(_, _, _, _): i = i + 1;
		case \while( _, _): i = i + 1; 
		case \do( _, _): i = i + 1; 
		case \if( _, _): i = i + 1;
		case \if(_, _, _): i = i + 1;
		// the case for \case is not entirely correct for exhaustive cases,
		// because it also counts the path for a non-existent default case.
		// Exhaustive cases are difficult to check using static analysis, so
		// this is a deliberate compromise.
		case \case(_): i = i + 1; 
		case \catch(_, _): i = i + 1;
	}
	
	return i;
}

list[int] getComplexities(list[node] asts){
	return [getComplexity(ast) | ast <- asts];
}

real avgComplexity(list[Declaration] asts){
	if(size(asts) == 0) throw Exception("#methods is 0");
	return (0| it + c | c <- getComplexities(asts)) / toReal(size(asts));
}
