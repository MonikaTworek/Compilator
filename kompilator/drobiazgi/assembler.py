from ply.cpp import xrange

class Assembler(object):
    def __init__(self):
        self.memory = {} #memory
        self.block = {} #block: line_no mapping
        self.out = [] #output
        self.lol = 0 #line_no

    # a <- number
    def numb(self, number, a):
        self.cmd('ZERO  a', a=a)
        if number == 0:
            return a
        number = bin(number)[3:]#pomija pierwsze 3 bity, czyli 0b1
        self.cmd('INC   a', a=a)
        for i in number:
            self.cmd('SHL   a', a=a)
            if i == '1':
                self.cmd('INC   a', a=a)
        return a

    #lets play a game <3
    #c <- a * b //sprawdzic ktora wieksza!

    #d<- a/b //sprawdzic, czy b to zero


def is_number(a): return isinstance(a, int)
def is_int(a): return isinstance(a, str)
def is_inttab(a): return isinstance(a, tuple) and len(a) == 2
def is_operation(a): return isinstance(a, tuple) and len(a) == 3