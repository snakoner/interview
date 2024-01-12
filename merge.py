import os
import sys
import re

def read_file(filename):
    data = []
    with open(filename, 'r') as f:
        data = f.read().splitlines()
    
    return data

def write_string_to_file(filename, s):
    with open(filename, 'w') as f:
        f.write(s)

def main():
    if len(sys.argv) != 2:
        print('usage: python merge.py [dirname]')

    path = sys.argv[1]
    files = os.listdir(f'./{path}')
    files = [x for x in files if re.search('[\d]+', x[:2])]
    files = sorted(files, key=lambda x: int(x.split('.')[0]))
    data = []
    for x in files:
        data += read_file(f'{path}/{x}')
    
    data = '\n'.join(data)
    write_string_to_file(f'{path}/merged.md', data)
    pass

if __name__ == '__main__':
    main()