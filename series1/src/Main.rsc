module Main

import IO;
import Loc;
import Duplication;
import UnitSize;
import UnitComplexity;

import util::Math;

public void main() {
	calculateAndShowScores(|project://smallsql0.21_src|);
	//calculateAndShowScores(|project://hsqldb-2.3.1|);
}

public void calculateAndShowScores(loc project) {
	map[str, value] sigScores = calculateScores(project);
	map[str, str] isoScores = calculateISOScore(sigScores);
	showSIGMaintainabilityModel(sigScores);
	showISOScore(isoScores);
}

public map[str, value] calculateScores(loc project) {
	int lines = countLinesForProject(project);
	int duplis = countDuplicationsForProject(project);
	real duplipct = round(10000 * toReal(duplis) / lines) / 100.0;
	return (
		"linesNumber": lines,
		"linesScore": getRankForScore(lines),
		"avgUnitSize": getAverageUnitSizeForProject(project),
		"avgUnitSizeScore": "TODO",
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

public map[str, str] calculateISOScore(map[str, value] scores) {
	c = scoreToInt(scores["complexityScore"]);
	u = scoreToInt(scores["avgUnitSizeScore"]);
	v = scoreToInt(scores["linesScore"]);
	d = scoreToInt(scores["duplicatesScore"]);
	i = 0; // TODO: unitinterface;

	analysability = (v + u + d) / 3;
	changeability = (c + d) / 2;
	//stability = ()/2;
	stability = 0; // TODO
	testability = (c + u) / 2;
	// reusability = (u + i)/2; // TODO
	reusability = 0;

	return (
		"analysability": intToScore(analysability),
		"changeability": intToScore(changeability),
		"stability": intToScore(stability),
		"testability": intToScore(testability),
		"reusability": intToScore(analysability)
	);
}

public void showISOScore(map[str, str] scores) {
	println("| analysability    | <scores["analysability"]>");
	println("| changeability    | <scores["changeability"]>");
	println("| stability        | <scores["stability"]>");
	println("| testability      | <scores["testability"]>");
	println("| reusability      | <scores["analysability"]>");
}

private int scoreToInt(value score) {
	switch (score) {
		case "--": return 1;
		case "-" : return 2;
		case "o" : return 3;
		case "+" : return 4;
		case "++": return 5;
		default:
			return -1;
	}
}

private str intToScore(int score) {
	switch (score) {
		case 1: return "--";
		case 2: return "-" ;
		case 3: return "o" ;
		case 4: return "+" ;
		case 5: return "++";
		default:
			return "";
	}
}
