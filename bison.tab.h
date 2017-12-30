/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_BISON_TAB_H_INCLUDED
# define YY_YY_BISON_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    t_pidentifier = 258,
    t_num = 259,
    t_VAR = 260,
    t_BEGIN = 261,
    t_END = 262,
    t_READ = 263,
    t_WRITE = 264,
    t_IF = 265,
    t_THEN = 266,
    t_ELSE = 267,
    t_ENDIF = 268,
    t_FOR = 269,
    t_FROM = 270,
    t_TO = 271,
    t_DOWNTO = 272,
    t_ENDFOR = 273,
    t_WHILE = 274,
    t_DO = 275,
    t_ENDWHILE = 276,
    t_ASSIGN = 277,
    t_EQUAL = 278,
    t_NOTEQUAL = 279,
    t_GREATER = 280,
    t_LOWER = 281,
    t_GREATEROREQUAL = 282,
    t_LOWEROREQUAL = 283,
    t_ENDLINE = 284,
    t_ERROR = 285
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 60 "bison.y" /* yacc.c:1909  */

	std::string *pidentifier;
	std::vector<std::string> *vec;
	void *pidStruct; // pointer to pidentifierStruct
	void *condStruct; // pointer to pidentifierStruct
	long long number;

#line 93 "bison.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_BISON_TAB_H_INCLUDED  */
