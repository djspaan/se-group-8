module Benchmark

import IO;
import Loc;
import Duplication;
import UnitSize;
import UnitComplexity;

import util::Math;
import util::Benchmark;

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import analysis::m3::Core;

public void benchmark() {
	benchmarkScores(|project://smallsql0.21_src|);
	benchmarkScores(|project://hsqldb-2.3.1|);
}

public void benchmarkScores(loc project) {
	t0 = getNanoTime();
	int lines = countLinesForProject(project);
	t1 = getNanoTime();
	int duplis = countDuplicationsForProject(project);
	t2 = getNanoTime();
	real unitSize = getAverageUnitSizeForProject(project);
	t3 = getNanoTime();
	real complexity = avgUnitComplexityForProject(project);
	t4 = getNanoTime();
	
	println("Scores: <lines> <duplis> <unitSize> <complexity>");
	
	println("Benchmarks:");
	println("        lines (s) <(t1 - t0) * 1e-9>");
	println("  duplication (s) <(t2 - t1) * 1e-9>");
	println("     unitSize (s) <(t3 - t2) * 1e-9>");
	println("   complexity (s) <(t4 - t3) * 1e-9>");
	println("------------------------------------");
	println("        total (s) <(t4 - t0) * 1e-9>");
	
}
