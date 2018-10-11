import sys
import re


CODE_OFFSET = 8
COMMENT_OFFSET = 32
ARGS_OFFSET = 8


def main():
    if len(sys.argv) < 2:
        print >> sys.stderr, "No filename specified"
        return 1

    code = open(sys.argv[1], 'r').read().splitlines()
    formatted = []
    for line in code:
        stripped = line.strip()
        if stripped.startswith('#include'):
            formatted.append(stripped)
        elif stripped.startswith('#'):
            formatted.append(' '*CODE_OFFSET + stripped)
        elif re.match('^[a-zA-Z_]+:$', stripped):
            formatted.append(stripped)
        elif re.match('[a-z]+(\s+[a-zA-Z_0-9,()$]*)?', stripped):
            l = stripped.split('#')
            instr = l[0].strip()
            op = instr.split()[0]
            args = ', '.join([a.strip() for a in ''.join(instr.split()[1:]).split(',')])
            instr = op + (' '*(ARGS_OFFSET-len(op))) + args
            comment = '# ' + l[1].strip() if len(l) > 1 else None
            f = ' '*CODE_OFFSET + instr
            if comment: f += ' '*(COMMENT_OFFSET-len(instr)) + comment
            formatted.append(f)
        elif stripped == '':
            formatted.append('')
        elif stripped.startswith('.'):
            formatted.append(' '*CODE_OFFSET + stripped)
        else:
            print >> sys.stderr, "WTF is this? " + line
            
    for line in formatted:
        print line
            
    return 0


if __name__ == "__main__":
    exit(main())
