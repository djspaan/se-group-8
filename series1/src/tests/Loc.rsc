module tests::Loc

import IO;
import Loc;

test bool getScoreForEmptyClass() {
	return countLinesForLocation(|project://testproject/src/EmptyClass.java|) == 1;
}

test bool getScoreForSmallClass() {
	return countLinesForLocation(|project://testproject/src//SmallClass.java|) == 28;
}

test bool getRankForLineScorePlusPlus() {
	return getRankForLineScore(50000) == "++";
}

test bool getRankForLineScorePlus() {
	return getRankForLineScore(140000) == "+";
}

test bool getRankForLineScoreO() {
	return getRankForLineScore(300000) == "o";
}

test bool getRankForLineScoreO() {
	return getRankForLineScore(700000) == "-";
}

test bool getRankForLineScoreO() {
	return getRankForLineScore(100000000) == "--";
}