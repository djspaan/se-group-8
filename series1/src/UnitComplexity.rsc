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
	return complexityScore(asts);
}

value runForHSqlDb(){
	M3 m3 = createM3FromDirectory(|home:///se-group-8/projects/hsqldb|);
	asts = toList(getASTs(m3));
	return complexityScore(asts);
}

tuple[list[int], real] avgUnitComplexityForProject(loc project){
	M3 m3 = createM3FromEclipseProject(project);
	return complexityScoreForM3(m3);
}

tuple[list[int], real] complexityScoreForM3(M3 m3){
	asts = toList(getASTs(m3));
	return complexityScore(asts);
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
		case \foreach(_, _, _): i += 1;
		case \for(_, _, _): i += 1;
		case \for(_, _, _, _): i += 1;
		case \while( _, _): i += 1; 
		case \do( _, _): i += 1; 
		case \if( _, _): i += 1;
		case \if(_, _, _): i += 1;
		// the case for \case is not entirely correct for exhaustive cases,
		// because it also counts the path for a non-existent default case.
		// Exhaustive cases are difficult to check using static analysis, so
		// this is a deliberate compromise.
		case \case(_): i += 1; 
		case \catch(_, _): i += 1;
		case \conditional(_, _, _): i += 1;
		case \infix(_, "&&", _): i += 1;
		case \infix(_, "||", _): i += 1;
	}
	
	return i;
}

list[int] getComplexities(list[node] asts){
	return [getComplexity(ast) | ast <- asts];
}


tuple[list[int], real] complexityScore(list[Declaration] asts){
	if(size(asts) == 0) return <[], 0.0>;
	complexities = getComplexities(asts);
	avg = (0| it + c | c <- complexities) / toReal(size(asts));
	return <complexities, avg>;
}

lrel[int, real] complexityBins(list[int] complexities){
	binVals = [5, 10, 15, 25, 1000000];
	map[int, real] bins = (v: 0.0 | v <- binVals);
	int total = size(complexities);
	for(c <- complexities){
		binVal = [b | b <- binVals, b >= c][0];
		bins[binVal] += 1.0 / total;
	}
	return sort([<bin, bins[bin]> | bin <- bins]);
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
