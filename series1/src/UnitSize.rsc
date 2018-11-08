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
	set[loc] units = methods(project);
	return sum([getUnitSize(unit) | unit <- units]) / toReal(size(units));
}

int getUnitSize(loc unit) {
	return countLinesForLocation(unit);
}