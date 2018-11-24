module Main

import IO;
import Loc;
import Duplication;
import PackageIndependence;
import String;
import Set;
import Type;
import UnitSize;
import UnitComplexity;
import util::Math;
import util::Benchmark;


public void main() {
	calculateAndShowScores(|project://smallsql0.21_src|);
	println("");
	calculateAndShowScores(|project://hsqldb-2.3.1|);
}

public void calculateAndShowScores(loc project) {
	map[str, value] sigScores = calculateScores(project);
	map[str, str] isoScores = calculateISOScore(sigScores);
	showSIGMaintainabilityModel(sigScores);
	showISOScore(isoScores);
}

public map[str, value] calculateScores(loc location) {
	project = projectM3(location);
	println("Statistics for: <location>");
	println("---------------------------");
	int t0 = getMilliTime();
	int lines = countLinesForM3(project);
	int t1 = getMilliTime();
	real avgUnitSize = getAverageUnitSizeForM3(project);
	int t2 = getMilliTime();
	<duplis, dupliTotalLinesCounted> = countDuplicationsForM3(project);
	real duplipct = round(10000 * toReal(duplis) / dupliTotalLinesCounted) / 100.0;
	int t3 = getMilliTime();
	<unitCpls, meanComplexity> = complexityScoreForM3(project);
	int t4 = getMilliTime();
	real independence = meanIndependenceScoreForM3(project);
	real independencePct = 100 * independence;
	str independenceRank = getRankForIndependenceScore(independence);
	int t5 = getMilliTime();
	real tests = meanTestScoreForM3(project);
	real testsPct = 100 * tests;
	int t6 = getMilliTime();

	println("Time ");
	println("Count lines: <t1 - t0> ms");
	println("Unit size: <t2 - t1> ms");
	println("Duplication: <t3 - t2> ms");
	println("Complexity: <t4 - t3> ms");
	println("Independence: <t5 - t4> ms");
	println("Tests: <t6 - t4> ms");
	println("Total: <t6 - t0> ms");
	return (
		"linesNumber": lines,
		"linesRank": getRankForLineScore(lines),
		"avgUnitSizeScore": avgUnitSize,
		"avgUnitSizeRank": getRankForUnitSizeScore(avgUnitSize),
		"meanComplexity": meanComplexity,
		"complexityRank": getComplexityScore(meanComplexity),
		"unitComplexities": complexityBins(unitCpls),
		"duplicatesNumber": duplis,
		"duplicatesPercentage": duplipct,
		"duplicatesRank": getDuplicationScore(duplipct),
		"independenceRank": independenceRank,
		"independencePercentage": independencePct,
		"testsPercentage": testsPct
		);
}

public void showSIGMaintainabilityModel(map[str, value] scores) {
	println("---------------------------");
	println("Volume");
	println("Total code lines: <scores["linesNumber"]>");
	println("Volume score: <scores["linesRank"]>");
	println("---------------------------");
	println("Unit Size & Complexity");
	println("Mean unit size: <scores["avgUnitSizeScore"]>");
	println("Mean unit size rank: <scores["avgUnitSizeRank"]>");
	println("---------------------------");
	println("Mean cyclomatic complexity: <scores["meanComplexity"]>");
	println("Complexity score: <scores["complexityRank"]>");
	println("Unit complexity scores:");
	if(list[tuple[int, real]] cmps := scores["unitComplexities"]){
		for(<bin, count> <- cmps){
			if (bin == 1000000) {
				println("<right("25+", 10, " ")>: <count * 100>%");
			} else {
				println("<right("<bin>", 10, " ")>: <count * 100>%");
			}
		}
	}
	else{
		println("????");
	}

	println("---------------------------");
	println("Duplication");
	println("Duplicate lines #: <scores["duplicatesNumber"]>");
	println("Duplicate lines %: <scores["duplicatesPercentage"]>");
	println("Duplication score: <scores["duplicatesRank"]>"); // numberOfDuplicates/toReal(totalLinesOfCode)
	println("---------------------------");
	println("Package Independence");
	println("LoC in public modules %: <scores["independencePercentage"]>");
	println("Independence score: <scores["independenceRank"]>"); // numberOfDuplicates/toReal(totalLinesOfCode)
	println("---------------------------");
	println("Testing");
	println("LoC in tested modules %: <scores["testsPercentage"]>");
	//println("Independence score: <scores["independenceRank"]>"); // numberOfDuplicates/toReal(totalLinesOfCode)
	println("---------------------------");
}

public map[str, set[str]] isoMatrix = (
		"analysability": {"linesRank", "avgUnitSizeRank", "complexityRank"},
		"changeability": {"complexityRank", "duplicatesRank"},
		"stability": {},
		"testability": {"avgUnitSizeRank", "complexityRank"}
);


public map[str, str] calculateISOScore(map[str, value] scores) {
	map[str, int] intResults = ();
	for(score <- isoMatrix){
		ranks = isoMatrix[score];
		intResults[score] = 0;
		if(ranks == {}) {
			continue;
		}
		for(rank <- ranks){
			intResults[score] += scoreToInt(scores[rank]);
		}
		intResults[score] /= size(ranks);
	}
	return (k: intToScore(intResults[k]) | k <- intResults);
}

public void showISOScore(map[str, str] scores) {
	println("| analysability    | <scores["analysability"]>");
	println("| changeability    | <scores["changeability"]>");
	println("| stability        | <scores["stability"]>");
	println("| testability      | <scores["testability"]>");
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
