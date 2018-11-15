module tests::Duplication

import IO;
import Duplication;

test bool linesOfCodesCountedIsCorrectForTestProject() {
	<duplis, dupliTotalLinesCounted> = countDuplicationsForProject(|project://testproject|);
	println(duplis);
	println(dupliTotalLinesCounted);
	return duplis == 12 && dupliTotalLinesCounted == 25;
}