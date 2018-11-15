module tests::UnitComplexity

import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import UnitComplexity;

test bool getComplexityForEmptyClass() {
	M3 project = createM3FromEclipseProject(|project://testproject|);
	real complexity = avgUnitComplexityForM3(project);
	return complexity == 1.666666667;
}