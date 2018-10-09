import sys

if __name__ == "__main__":
    val = int if 'numeric' in sys.argv else str

    increases = True
    try:
        str1 = raw_input()
        str2 = raw_input()
        while (increases and str2):
            if len(str1) > 0 and len(str2) > 0:
                increases = (val(str1) <= val(str2))
            str1 = str2
            str2 = raw_input()
            if not increases:
                print str1
                print str2
    except EOFError:
        pass

    exit(0 if increases else 1)
