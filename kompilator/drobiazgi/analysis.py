import logging
from itertools import chain
from ply.cpp import xrange
from kompilator.drobiazgi.errors import Errors

class Analysis(object):
    def __init__(self):
        self.variable = None
        self.init = None
        self.iter =0


    #a tu se poanalizuję czy zmienne nie sa zle uzyte, itp