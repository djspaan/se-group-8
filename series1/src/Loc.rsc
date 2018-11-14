module Loc

import lang::java::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Set;
import String;
import List;
import IO;
import util::Resources;

public M3 projectM3(loc project){
	return createM3FromEclipseProject(project);
}

public int countLinesForProject(loc project) {
	M3 m3Project = createM3FromEclipseProject(project);
	return countLinesForM3(m3Project);
}
public int countLinesForM3(M3 m3Project) {
	set[loc] files = classes(m3Project);
	return sum([countLinesForLocation(file) | loc file <- files]);
}


public str getRankForLineScore(int linesOfCode){
	if(linesOfCode <= 66000){
		return "++";
	} else if(linesOfCode > 66000 && linesOfCode <= 246000){
		return "+";
	} else if(linesOfCode > 246000 && linesOfCode <= 665000){
		return "o";
	} else if(linesOfCode > 665000 && linesOfCode <= 1310000){
		return "-";
	} else {
		return "--";
	}
}

public int countLinesForLocation(loc location) {
	str fileContents = readFile(location);
	str fileContentsWithoutComments = removeComments(fileContents);
	list[str] lines = getLines(fileContentsWithoutComments);
	list[str] filteredLines = filterLines(lines);
	return size(filteredLines);
	
}

private list[loc] allFiles(loc project) {
	return [f | /file(f) := getProject(project), f.extension == "java"];
}

public str removeComments(str text) {
	return visit(text){
		case /^(\*.*|\/\/.*|(\"(?:\\\\[^\"]|\\\\\"|.)*?\")|(?s)\/\\*.*?\\*\/)/ => " "
		case /<s:^[a-zA-Z0-9_ (){}\[\]:;,.\t@]+>/ => s // whitelist irrelevant lines -> big performance boost
	};
}

private list[str] getLines(str text) {
	list[str] lines = split("\n", text);
	return lines;
}

private list[str] filterLines(list[str] lines) {
	lines = mapper(lines, filterLine);
	return [line | line <- lines, line != ""];
}

private str filterLine(str line) {
	line = replaceAll(line, "\r", "");
	line = trim(line);
	return line;
}
