#ifndef CHECKER_H
#define CHECKER_H

#include <iostream>
#include <string>
#include <map>
#include <vector>

/* types known by compilator */

enum ExprType {
	TYPE_INT,
	TYPE_STRING,
	TYPE_BOOL,
	TYPE_UNKNOWN,
};

/* map that holds information about used variables and its types */

struct VariableInfo {
	ExprType type;
	std::vector<int> lines_used;
};

extern std::map<std::string, VariableInfo> symbol_table;


class Node { /* abstract class of all nodes */
public:
	virtual ~Node() {}
	
	virtual ExprType checkType() { return TYPE_UNKNOWN; }
};

class DeclarationNode : public Node { /* checks for declarations and writes them to symbol_table */
private:
	std::string variable_name;
	ExprType variable_type;
	int line_number;

public:
	DeclarationNode(std::string name, ExprType type, int line)
		: variable_name(name), variable_type(type), line_number(line) {}
		
	ExprType checkType() override {
		if (symbol_table.find(variable_name) != symbol_table.end()) {
			std::cerr << "Line: " << line_number << ", variable: " << variable_name << " was declared earlier" << std::endl;
		} else {
			VariableInfo info;
			info.type = variable_type;
			info.lines_used.push_back(line_number);
			
			symbol_table[variable_name] = info;
		}
		
		return variable_type;
	}
};

class LiteralNode : public Node { /* dummy node class that checks for type */
private:
	ExprType variable_type;
	
public:
	LiteralNode(ExprType t) : variable_type(t) {}
	
	ExprType checkType() override {
		return variable_type;
	}
};

class IdentifierNode : public Node { /* used when variable is found on right side of assignment */
private:
	std::string variable_name;
	int line_number;
	
public:
	IdentifierNode(std::string name, int line) : variable_name(name), line_number(line) {}
	
	ExprType checkType() override {
		if (symbol_table.find(variable_name) == symbol_table.end()) {
			std::cerr << "Line: " << line_number << ", variable: " << variable_name << " was NOT declared" << std::endl;
			
			return TYPE_UNKNOWN;
		}
		
		symbol_table[variable_name].lines_used.push_back(line_number);
		
		return symbol_table[variable_name].type;
	}
};

class AssignmentNode : public Node { /* compares types between declared variable and its r-value */
private:
	std::string variable_name;
	Node* right_side_of_expr;
	int line_number;
	
public:
	AssignmentNode(std::string name, Node* expr, int line) : variable_name(name), right_side_of_expr(expr), line_number(line) {}
	
	ExprType checkType() override {
		ExprType right_type = right_side_of_expr->checkType();
		
		if (symbol_table.find(variable_name) == symbol_table.end()) {
			std::cerr << "Line: " << line_number << ", variable: " << variable_name << ". Assignment to undeclared variable" << std::endl;
			
			return TYPE_UNKNOWN;
		}
		
		symbol_table[variable_name].lines_used.push_back(line_number);
		
		ExprType left_type = symbol_table[variable_name].type;
		
		if (left_type != right_type && right_type != TYPE_UNKNOWN) {
			std::cerr << "Line: " << line_number << ", variable: " << variable_name << ". Type mismatch" << std::endl;
		}
		
		return left_type;
	}
};


#endif