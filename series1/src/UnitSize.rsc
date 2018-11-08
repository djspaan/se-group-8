module UnitSize

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;
import Set;
import Loc;

public int getAverageUnitSizeForProject(loc location) {
	M3 project = createM3FromEclipseProject(location);
	set[loc] units = methods(project);
	return sum([getUnitSize(unit) | unit <- units]) / size(units);
	// return min([getUnitSize(unit) | unit <- units]);
	// return max([getUnitSize(unit) | unit <- units]);
}

int getUnitSize(loc unit) {
	return countLinesForLocation(unit);
}