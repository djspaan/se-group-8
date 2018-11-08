module Loc

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Set;
import String;
import List;
import IO;
import util::Resources;

public int countLinesForProject(loc project) {
	//loc project = |project://smallsql0.21_src|;
	list[loc] files = allFiles(project);
	return sum([countLinesForFile(file) | file <- files]);
}

public list[loc] allFiles(loc project) {
	return [f | /file(f) := getProject(project), f.extension == "java"];
}

public int countLinesForFile(loc file) {
	str fileContents = readFile(file);
	str fileContentsWithoutComments = removeComments(fileContents);
	list[str] lines = getLines(fileContentsWithoutComments);
	list[str] filteredLines = filterLines(lines);
	return size(filteredLines);
	
}

public str removeComments(str text) {
	return visit(text){
			case /\/\/.*|(\"(?:\\\\[^\"]|\\\\\"|.)*?\")|(?s)\/\\*.*?\\*\// => " "
	};
}

public list[str] getLines(str text) {
	list[str] lines = split("\n", text);
	return lines;
}

public list[str] filterLines(list[str] lines) {
	lines = mapper(lines, filterLine);
	return [line | line <- lines, line != "", !startsWith(line, "*")];
}

public str filterLine(str line) {
	line = replaceAll(line, "\r", "");
	line = trim(line);
	return line;
}
