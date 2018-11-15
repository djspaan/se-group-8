module tests::UnitSize

import IO;
import UnitSize;
import Set;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;


test bool getScoreForEmptyClass() {
	M3 project = createM3FromEclipseProject(|project://testproject|);
	set[loc] units = methods(project);
	println(units);
	return size(units) == 0;
}

test bool getScoreForSmallClass() {
	M3 project = createM3FromEclipseProject(|project://testproject|);
	set[loc] units = methods(project);
	res = 0;
	for (unit <- units) {
		res += getUnitSize(unit);
	}
	return res == 7;
}


test bool getRankForScorePlusPlus() {
	return getRankForUnitSizeScore(1.0) == "++";
}

test bool getRankForScorePlus() {
	return getRankForUnitSizeScore(6.0) == "+";
}

test bool getRankForScoreO() {
	return getRankForUnitSizeScore(11.0) == "o";
}

test bool getRankForScoreO() {
	return getRankForUnitSizeScore(16.0) == "-";
}

test bool getRankForScoreO() {
	return getRankForUnitSizeScore(30.0) == "--";
}