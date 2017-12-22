import argparse
from kompilator.drobiazgi.errors import Errors
from kompilator.drobiazgi.pflex import Pflex
from kompilator.drobiazgi.parser import Parser



def main():
    args = parse_args()
    compilation(args.file_path, args.out)

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('filepath', help = '.imp file')
    parser.add_argument('--output', default="loser.mr", help = "place the output")
    return parser.parse_args()

def compilation(filepath, outhpath):
    parser = Parser()

if __name__ == '__main__':
    main()