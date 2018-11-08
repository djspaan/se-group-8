module Main

import IO;
import Loc;
import Duplication;
import UnitSize;
import UnitComplexity;

import util::Math;

public void main() {
	map[str, value] scores = calculateScores(|project://smallsql0.21_src|);
	showSIGMaintainabilityModel(scores);
	//map[str, value] scores = calculateScores(|project://hsqldb-2.3.1|);
	//showSIGMaintainabilityModel(scores);
}

public map[str, value] calculateScores(loc project) {
	int lines = countLinesForProject(project);
	int duplis = countDuplicationsForProject(project);
	real duplipct = round(10000 * toReal(duplis) / lines) / 100.0;
	return (
		"linesNumber": lines, 
		"linesScore": getRankForScore(lines), 
		"avgUnitSize": getAverageUnitSizeForProject(project),
		"complexityNumber": avgUnitComplexityForProject(project),
		"complexityScore": "magic",
		"duplicatesNumber": countDuplicationsForProject(project),
		"duplicatesPercentage": "<duplipct>%",
		"duplicatesScore": "TODO"
		);
}

public void showSIGMaintainabilityModel(map[str, value] scores) {
	println("---------------------------");
	println("Volume");
	println("Total code lines: <scores["linesNumber"]>");
	println("Volume score: <scores["linesScore"]>");
	println("---------------------------");
	println("Unit Size & Complexity");
	println("Average unit size: <scores["avgUnitSize"]>");
	println("Cyclomatic complexity: <scores["complexityNumber"]>");
	println("Complexity score: <scores["complexityScore"]>");
	println("---------------------------");
	println("Duplication");
	println("Duplicate lines #: <scores["duplicatesNumber"]>");
	println("Duplicate lines %: <scores["duplicatesPercentage"]>");
	println("Duplication score: <scores["duplicatesScore"]>"); // numberOfDuplicates/toReal(totalLinesOfCode)
	println("---------------------------");
}