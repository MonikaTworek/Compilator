import logging
import ply.yacc as yacc

from kompilator.drobiazgi.pflex import Pflex
from kompilator.drobiazgi.errors import Errors


class Parser(object):
    # program
    def p_program(self, p):
        'program : VAR vdeclarations BEGIN commands END'
        p[0] = ('program', p[2], p[4])

    # vdeclarations
    def p_vdeclaration_numb(self, p):
        'vdeclarations : vdeclarations PID'
        p[0] = p[1] if p[1] else []
        p[0].append(('int', p[2], p.lineo(2)))

    def p_vdeclarations_tab(self, p):
        'vdeclarations : vdeclarations PID LEFT NUMB RIGHT'
        p[0] = p[1] if p[1] else []
        p[0].append(('int[]', p[2], p[4], p.lineo(2)))

    def p_vdeclarations_empty(self, p):
        'vdeclarations : empty'
        p[0] = []

    # commands
    def p_commands(self, p):
        'commands : commands command'
        p[0] = p[1] if p[1] else []
        p[0].append(p[2])

    def p_commands_empty(self, p):
        'commands : empty'
        pass

    # command
    def p_command_assign(self, p):
        'command : identifier ASSIGN expression LOL'
        p[0] = ('assign', p[1], p[3])

    def p_command_if_then(self, p):
        'command : IF condition THEN commands ENDIF'
        p[0] = ('if_then', p[2], p[4])

    def p_command_if_else(self, p):
        'command : IF condition THEN commands ELSE commands ENDIF'
        p[0] = ('if_else', p[2], p[4], p[6])

    def p_command_while(self, p):
        'command : WHILE condition DO commands ENDWHILE'
        p[0] = ('while', p[2], p[4])

    def p_command_for_up(self, p):
        'command : FOR PID FROM value TO value DO commands ENDFOR'
        i = ('int', p[2], p.lineno(2))
        p[0] = ('for_up', i, p[4], p[6], p[8])

    def p_command_for_down(self, p):
        'command : FOR PID DOWN FROM value TO value DO commands ENDFOR'
        i = ('int', p[2], p.lineno(2))
        p[0] = ('for_down', i, p[5], p[7], p[9])

    def p_command_write(self, p):
        'command : WRITE identifier LOL'
        p[0] = ('write', p[2])

    def p_command_read(self, p):
        'command : READ value LOL'
        p[0] = ('read', p[2])

    # expression
    def p_expression_value(self, p):
        'expression : value'
        p[0] = ('expression', p[1])

    def p_expression(self, p):
        '''expression : value ADD value
                      | value SUB value
                      | value MULT value
                      | value DIV value
                      | value MOD value'''
        p[0] = ('expression', p[2], p[1], p[3])

    # condition
    def p_condition(self, p):
        '''condition : value EQ value
                     | value NOTEQ value
                     | value LESS value
                     | value GREAT value
                     | value LESSEQ value
                     | value GREATEQ value'''
        p[0] = ('condition', p[2], p[1], p[3])

    # value
    def p_value(self, p):
        '''value : NUMB
                 | identifier'''
        p[0] = p[1]

    # identifier
    def p_identifier_var(self, p):
        'identifier : PID'
        p[0] = ('int', p[1], p.lineno(1))

    def p_identifier_table_id(self, p):
        'identifier : PID LEFT PID RIGHT'
        i = ('int', p[3], p.lineno(3))
        p[0] = ('int[]', p[1], i, p.lineno(1))

    def p_identifier_table_num(self, p):
        'identifier : PID LEFT NUMB RIGHT'
        p[0] = ('int[]', p[1], p[3], p.lineno(1))

    # empty
    def p_empty(self, p):
        'empty : '
        pass

    # error
    def p_error(self, p):
        logging.error('In line %d', p.lineno)
        logging.error('Szto eta za zapis? "%s"', p.value)
        raise Errors()

    # parser
    def __init__(self):
        self.lexer = Pflex()
        self.tokens = self.lexer.tokens
        self.parser = yacc.yacc(module=self, write_tables=0, debug=False)

    def parse(self, data):
        if data:
            return self.parser.parse(data, self.lexer.lexer, 0, 0, None)
        else:
            logging.error("Zdes niszewo net")
            raise Errors()