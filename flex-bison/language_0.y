%{
  #include "ast.h"
  #include <iostream>
  #include <string>

// From flex
  extern "C" int yylex();

void yyerror(ASTNode& program, std::ostream& error, const char*);
%}

// Debugging flags.
// Some of them need yydebug assigned to 1 before calling yyparse().
//   (They are VERY verbose!)
%debug
%error-verbose

%parse-param {ASTNode& program}
%parse-param {std::ostream& error}

%token <integer>    integer
%token <real>       real
%token <str>        identifier
%token <str>        unaryPrefixOperatorKeyword
%token <str>        unaryPostfixOperatorKeyword
%token <str>        minusOperatorKeyword
%token <str>        assignmentOperatorKeyword
%token <str>        binaryOperatorKeyword0
%token <str>        binaryOperatorKeyword1
%token <str>        binaryOperatorKeyword2
%token <str>        binaryOperatorKeyword3
%token <str>        binaryOperatorKeyword4
%token <str>        binaryOperatorKeyword5
%token <str>        binaryOperatorKeyword6
%token <str>        binaryOperatorKeyword7
%token <str>        binaryOperatorKeyword8
%token <str>        binaryOperatorKeyword9

// Reserved words.
%token <str>        constQualifier
%token <str>        elseKeyword
%token <str>        ifKeyword
%token <str>        returnKeyword
%token <str>        whileKeyword

%type <node>        Assignment
%type <node>        Block
%type <node>        Declaration
%type <node>        Declarations
%type <node>        DeclList
%type <node>        ElseStatement
%type <node>        Expression
%type <node>        PrimaryTerm
%type <node>        PostfixExpression
%type <node>        UnaryExpression
%type <node>        TermPrecedence0
%type <node>        TermPrecedence1
%type <node>        TermPrecedence2
%type <node>        TermPrecedence3
%type <node>        TermPrecedence4
%type <node>        TermPrecedence5
%type <node>        TermPrecedence6
%type <node>        TermPrecedence7
%type <node>        TermPrecedence8
%type <node>        TermPrecedence9
%type <node>        IfStatement
%type <node>        Literal
%type <node>        Program
%type <node>        ReturnStatement
%type <node>        Statement
%type <node>        Statements
%type <node>        Type
%type <node>        Value
%type <node>        WhileStatement
%type <str>         assignmentOperator

%code requires {
  #include "ast.h"

  // Structs, unlike unions, allow class members.
  struct YYSTYPE {
    int integer;
    double real;
    std::string str;
    ASTNode node;

    // We should probably have a reasonable default constructor.
    YYSTYPE()
    : integer(), real() {}
  };
}

%%

Program:
  Statements {
    program.type = ASTNode::Program;
    program.addChild($1);
  }
;

Statements:
  Statements Statement {
    $$.addChild($2);
  }
| Statement {
    $$ = ASTNode(ASTNode::Block);
    $$.addChild($1);
  }
;

Statement:
  Declarations ';' {
    $$ = $1;
  }
| Expression ';' {
    $$ = $1;
  }
| Block {
    $$ = $1;
  }
| IfStatement {
    $$ = $1;
  }
| WhileStatement {
    $$ = $1;
  }
| ReturnStatement {
    $$ = $1;
  }
| ';' {
    $$ = ASTNode(ASTNode::Expression);
  }
;

Declarations:
  Type DeclList {
    $$ = ASTNode(ASTNode::Declarations);
	$$.addChild($1);
	for(auto& child: $2.children){
		$$.addChild(child);
	}
  }
;

DeclList:
  Declaration {
    if($$.type != ASTNode::Declarations){
	  $$ = ASTNode(ASTNode::Declarations);
	}

    $$.addChild($1);
  }
| DeclList ',' Declaration {
    $$.addChild($3);
  }
;

Declaration:
  Assignment {
    $$ = $1;
  }
| identifier {
    $$ = ASTNode(ASTNode::Symbol, $1);
  }
;

Type:
  constQualifier Type {
    $$ = $2;
    $$.makeConst();
  }
| identifier {
    $$ = ASTNode(ASTNode::Symbol, $1);
  }
;

Assignment:
  identifier '=' Expression {
    $$ = ASTNode(ASTNode::Assignment);
    $$.addChild(ASTNode(ASTNode::Symbol, $1));
    $$.addChild($3);
  }
;

Block:
  '{' Statements '}' {
    $$ = $2;
  }
  | '{' '}' {
    $$ = ASTNode(ASTNode::Block);
  }
;

// the assignment operators have the lowest precedence so they come first
Expression:

  // this rule is right recursive because it is right associative.
  TermPrecedence9 assignmentOperator Expression {
    $$ = ASTNode(ASTNode::Assignment, $2);
    $$.addChild($1);
    $$.addChild($3);
  }
| TermPrecedence9 {
    $$ = $1;
  }
;

TermPrecedence9:
  TermPrecedence9 binaryOperatorKeyword9 TermPrecedence8 {
    $$ = ASTNode(ASTNode::Expression, $2);
    $$.addChild($1);
    $$.addChild($3);
  }
| TermPrecedence8 {
    $$ = $1;
  }
;

TermPrecedence8:
  TermPrecedence8 binaryOperatorKeyword8 TermPrecedence7 {
    $$ = ASTNode(ASTNode::Expression, $2);
    $$.addChild($1);
    $$.addChild($3);
  }
| TermPrecedence7 {
    $$ = $1;
  }
;

TermPrecedence7:
  TermPrecedence7 binaryOperatorKeyword7 TermPrecedence6 {
    $$ = ASTNode(ASTNode::Expression, $2);
    $$.addChild($1);
    $$.addChild($3);
  }
| TermPrecedence6 {
    $$ = $1;
  }
;

TermPrecedence6:
  TermPrecedence6 binaryOperatorKeyword6 TermPrecedence5 {
    $$ = ASTNode(ASTNode::Expression, $2);
    $$.addChild($1);
    $$.addChild($3);
  }
| TermPrecedence5 {
    $$ = $1;
  }
;

TermPrecedence5:
  TermPrecedence5 binaryOperatorKeyword5 TermPrecedence4 {
    $$ = ASTNode(ASTNode::Expression, $2);
    $$.addChild($1);
    $$.addChild($3);
  }
| TermPrecedence4 {
    $$ = $1;
  }
;

TermPrecedence4:
  TermPrecedence4 binaryOperatorKeyword4 TermPrecedence3 {
    $$ = ASTNode(ASTNode::Expression, $2);
    $$.addChild($1);
    $$.addChild($3);
  }
| TermPrecedence3 {
    $$ = $1;
  }
;

TermPrecedence3:
  TermPrecedence3 binaryOperatorKeyword3 TermPrecedence2 {
    $$ = ASTNode(ASTNode::Expression, $2);
    $$.addChild($1);
    $$.addChild($3);
  }
| TermPrecedence2 {
    $$ = $1;
  }
;

TermPrecedence2:
  TermPrecedence2 binaryOperatorKeyword2 TermPrecedence1 {
    $$ = ASTNode(ASTNode::Expression, $2);
    $$.addChild($1);
    $$.addChild($3);
  }
| TermPrecedence1 {
    $$ = $1;
  }
;

TermPrecedence1:
  TermPrecedence1 binaryOperatorKeyword1 TermPrecedence0 {
    $$ = ASTNode(ASTNode::Expression, $2);
    $$.addChild($1);
    $$.addChild($3);
  }
| TermPrecedence1 minusOperatorKeyword TermPrecedence0 {
    $$ = ASTNode(ASTNode::Expression, $2);
    $$.addChild($1);
    $$.addChild($3);
  }
| TermPrecedence0 {
    $$ = $1;
  }
;

TermPrecedence0:
  TermPrecedence0 binaryOperatorKeyword0 UnaryExpression {
    $$ = ASTNode(ASTNode::Expression, $2);
    $$.addChild($1);
    $$.addChild($3);
  }
| PostfixExpression {
    $$ = $1;
  }
;

PostfixExpression:
  UnaryExpression unaryPostfixOperatorKeyword {
    $$ = ASTNode(ASTNode::Expression, $2);
    $$.addChild($1);
  }
| UnaryExpression {
    $$ = $1;
  }
;

UnaryExpression:
  unaryPrefixOperatorKeyword PrimaryTerm {
    $$ = ASTNode(ASTNode::Expression, $1);
    $$.addChild($2);
  }
| minusOperatorKeyword PrimaryTerm {
    $$ = ASTNode(ASTNode::Expression, $1);
    $$.addChild($2);
  }
| PrimaryTerm {
    $$ = $1;
  }
;

PrimaryTerm:
  '(' Expression ')' {
    $$ = $2;
  }
| Value {
    $$ = $1;
  }
;

// required because '=' needs special significance in assignment and therefore can't be apart of the assignmentOperatorKeyword regex
assignmentOperator:
  '=' {
    $$ = std::string("=");
  }
| assignmentOperatorKeyword {
    $$ = $1;
  }

Value:
  identifier {
    $$ = ASTNode(ASTNode::Symbol, $1);
  }
| Literal {
    $$ = $1;
  }
;

Literal:
// TODO: const char* and char literals. (Eventually)
  integer {
    $$ = ASTNode(ASTNode::Symbol, std::to_string($1));
  }
| real {
    $$ = ASTNode(ASTNode::Symbol, std::to_string($1));
  }
;

IfStatement:
  ifKeyword '(' Expression ')' Block {
    $$ = ASTNode(ASTNode::If);
    $$.addChild($3);
    $$.addChild($5);
  }
| ifKeyword '(' Expression ')' Block ElseStatement  {
    $$ = ASTNode(ASTNode::If);
    $$.addChild($3);
    $$.addChild($5);
    $$.addChild($6);
  }
;

ElseStatement:
  elseKeyword Block {
    $$ = $2;
  }
| elseKeyword IfStatement {
    $$ = $2;
  }
;

WhileStatement:
  whileKeyword '(' Expression ')' Block {
    $$ = ASTNode(ASTNode::While);
    $$.addChild($3);
    $$.addChild($5);
  }
;

ReturnStatement:
  returnKeyword Expression ';' {
    $$ = ASTNode(ASTNode::Return);
    $$.addChild($2);
  }
| returnKeyword ';' {
    $$ = ASTNode(ASTNode::Return);
  }
;

%%

void yyerror(ASTNode& program, std::ostream& error, const char* msg) {
    error << "[Error] " << msg << std::endl;
}
