module UnitComplexity

import IO;
import Set;
import List;
import util::Math;

import lang::java::jdt::m3::Core;
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

real avgUnitComplexityForProject(loc project){
	M3 m3 = createM3FromEclipseProject(project);
}

real avgUnitComplexityForM3(M3 m3){
	asts = toList(getASTs(m3));
	return avgComplexity(asts);
}


bool declIsMethod(Declaration d){
	return (  \method(_, _, _, _) := d) 
		   || (\method(_, _, _, _, _) := d)
		   || (\constructor(_, _, _, _) := d);
}

set[Declaration] getASTs(M3 m3){
	set[M3] m3s;
	set[Declaration] fileasts;	
	<m3s, fileasts> = createM3sAndAstsFromFiles(files(m3));
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
	if(size(asts) == 0) return 0.0;
	return (0| it + c | c <- getComplexities(asts)) / toReal(size(asts));
}


public str getComplexityScore(real complexity){
	scores = [s | <int n, str s> <- [
		<5, "++">,
		<10, "+">,
		<15, "o">,
		<25, "-">,
		<-1, "--">
	], n >= complexity || n < 0];
	return scores[0];
}
