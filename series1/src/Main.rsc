module Main

import IO;
import Loc;
import UnitSize;

public void main() {
	map[str, value] scores = calculateScores(|project://smallsql0.21_src|);
	showSIGMaintainabilityModel(scores);
	//map[str, value] scores = calculateScores(|project://hsqldb-2.3.1|);
	//showSIGMaintainabilityModel(scores);
}

public map[str, value] calculateScores(loc project) {
	int lines = countLinesForProject(project);
	return (
		"linesNumber": lines, 
		"linesScore": getRankForScore(lines), 
		"avgUnitSize": getAverageUnitSizeForProject(project),
		"complexityNumber": "TODO",
		"complexityScore": "TODO",
		"duplicatesNumber": "TODO",
		"duplicatesPercentage": "TODO",
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
	println("Duplicates #: <scores["duplicatesNumber"]>");
	println("Duplicates %: <scores["duplicatesPercentage"]>");
	println("Duplication score: <scores["duplicatesScore"]>"); // numberOfDuplicates/toReal(totalLinesOfCode)
	println("---------------------------");
}