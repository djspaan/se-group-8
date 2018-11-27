module UnitSize

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;
import Set;
import Loc;
import util::Math;

public real getAverageUnitSizeForProject(loc location) {
	M3 project = createM3FromEclipseProject(location);
	return getAverageUnitSizeForM3(project);
}

public real getAverageUnitSizeForM3(M3 project) {
	set[loc] units = methods(project);
	return sum([getUnitSize(unit) | unit <- units]) / toReal(size(units));
}

public str getRankForUnitSizeScore(real avgUnitSize){
	if(avgUnitSize <= 15){
		return "++";
	} else if(avgUnitSize <= 30){
		return "+";
	} else if(avgUnitSize <= 60){
		return "-";
	} else {
		return "--";
	}
}

public int getUnitSize(loc unit) {
	return countLinesForLocation(unit);
}