import logging
import ply.lex as lex
from kompilator.drobiazgi.errors import Errors


class Pflex(object):
    tokens = ('VAR', 'BEGIN', 'END',
              'READ', 'WRITE',
              'FOR', 'TO', 'DOWNTO', 'ENDFOR',
              'WHILE', 'DO', 'ENDWHILE',
              'IF', 'THEN', 'ELSE', 'ENDIF'

                                    'LOL', 'ASSIGN', 'PID', 'NUMB',
              'ADD', 'SUB', 'MULT', 'DIV', 'MOD',
              'EQ', 'NOTEQ', 'LESS', 'GREAT', 'LESSEQ', 'GREATEQ')

    t_VAR = r'VAR'
    t_BEGIN = r'BEGIN'
    t_END = r'END'
    t_READ = r'READ'
    t_WRITE = r'WRITE'
    t_FOR = r'FOR'
    t_TO = r'TO'
    t_DOWNTO = r'DOWNTO'
    t_ENDFOR = r'ENDFOR'
    t_WHILE = r'WHILE'
    t_DO = r'DO'
    t_ENDWHILE = r'ENDWHILE'
    t_IF = r'IF'
    t_THEN = r'THEN'
    t_ELSE = r'ELSE'
    t_ENDIF = r'ENDIF'
    t_LOL = r';'
    t_ASSIGN = r':='
    t_PID = r'[_a-z]+'
    t_ADD = r'\+'
    t_SUB = r'-'
    t_MULT = r'\*'
    t_DIV = r'/'
    t_MOD = r'%'
    t_EQ = r'='
    t_NOTEQ = r'<>'
    t_LESS = r'<'
    t_GREAT = r'>'
    t_LESSEQ = r'<='
    t_GREATEQ = r'>='

    t_ignore = ' \t'

    def t_NUMB(self, t):
        r'\d+'
        t.value = int(t.value)
        return t

    def t_newline(selfself, t):
        r'\n+'
        t.lexer.lineo += len(t.value)

    def t_ERROR(self, t):
        logging.error('In line %d', t.lexer.lineo)
        logging.error('Unknown symbols "%s"', t.value.split(' ', 1))
        raise Errors()

    def __init__(self, **kwargs):
        self.lexer = lex.lex(module=self, **kwargs)

    def tokenize(self, data):
        self.lexer.input(data)
        while True:
            tok = self.lexer.token()
            if tok:
                yield tok
            else:
                break
