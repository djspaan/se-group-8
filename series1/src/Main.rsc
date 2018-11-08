module Main

import IO;
import Loc;
import UnitSize;

public void main() {
	showSIGMaintainabilityModel(|project://smallsql0.21_src|);
	//showSIGMaintainabilityModel(|project://hsqldb-2.3.1|);
}

public void showSIGMaintainabilityModel(loc project) {
	int linesForProject = countLinesForProject(project);
	println("------------------------------------------------");
	println("Volume");
	println("Total code lines: <linesForProject>");
	println("Volume score: <getRankForScore(linesForProject)>");
	println("------------------------------------------------");
	println("Unit Size & Complexity");
	println("Average unit size: <getAverageUnitSizeForProject(project)>");
	println("Cyclomatic complexity: TODO");
	println("Complexity score: TODO");
	println("------------------------------------------------");
	println("Duplication");
	println("Duplicates #: TODO");
	println("Duplicates %: TODO");
	println("Duplication score: TODO"); // numberOfDuplicates/toReal(totalLinesOfCode)
	println("------------------------------------------------");
}