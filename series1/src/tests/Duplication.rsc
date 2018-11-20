module tests::Duplication

import IO;
import Duplication;

test bool linesOfCodesCountedIsCorrectForTestProject() {
	<duplis, dupliTotalLinesCounted> = countDuplicationsForProject(|project://testproject|);
	return duplis == 12 && dupliTotalLinesCounted == 27;
}