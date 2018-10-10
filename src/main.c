#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#define CHUNK_SIZE 10


typedef struct {
    FILE* output;
    FILE* input;
    int numeric;
} Arguments;


int compare(char* ptr1, char* ptr2, int num) {
    if (num) return atoi(ptr1) - atoi(ptr2);
    else return strcmp(ptr1, ptr2);
}

#ifdef ASM_QSORT
extern my_qsort(char** left, char** right, int num);
#else
void my_qsort(char** left, char** right, int num) {
    if (left < right) {
        char* pivot = *left;
        char** curMin = left+1;
        char** curMax = right;

        while (curMin <= curMax) {
            while (curMin <= right && compare(*curMin, pivot, num) <= 0)
                ++curMin;

            while (curMax >= left && compare(*curMax, pivot, num) > 0)
                --curMax;

            if (curMin < curMax) {
                char* aux = *curMin;
                *curMin = *curMax;
                *curMax = aux;
            }
        }
        
        char* aux = *left;
        *left = *curMax;
        *curMax = aux;

        my_qsort(left, curMax-1, num);
        my_qsort(curMax+1, right, num);
    }
}
#endif

void print_help() {
    printf("Usage:\n");
    printf("    qsort -h\n");
    printf("    qsort -V\n");
    printf("    qsort [options] archivo\n");
    printf("Options:\n");
    printf("    -h, --help      Imprime ayuda.\n");
    printf("    -V, --version   Versión del programa.\n");
    printf("    -o, --output    Archivo de salida.\n");
    printf("    -n, --numeric   Ordenar los datos numéricamente en vez de alfabéticamente.\n");
    printf("Examples:\n");
    printf("    qsort -n numeros.txt\n");
}

void print_version() {
    printf("QSort Version 1.0\n");
}

void print_output(char** lines, int count, FILE* output) {
    for (int i = 0; i < count; ++i) {
        fprintf(output, "%s\n", lines[i]);
    }
}

void free_lines(char** lines, int count) {
    for (int i = 0; i < count; ++i) {
        free(lines[i]);
    }
    free(lines);
}

char* read_line(FILE* input) {
    char* str = (char*) malloc(sizeof(char));
    *str = '\0';
    int len = 0;
    char c;

    if (feof(input)) return NULL;

    while (EOF != (c=fgetc(input)) && c != '\n') {
        ++len;
        str = (char*) realloc(str, sizeof(char)*(len+1));
        str[len-1] = c;
        str[len] = '\0';
    }

    if (c == EOF && len == 0) {
        free(str);
        return NULL;
    }

    return str;
}

int parse_file(FILE* input, void** dest) {
    char** lines = NULL;
    char* line = NULL;
    int count = 0;

    while (line = read_line(input)) {
        int length = strlen(line);
        
        if (length > 0) {
            if ((count % CHUNK_SIZE) == 0) {
                int amount = (count/CHUNK_SIZE+1)*CHUNK_SIZE;
                lines = (char**) realloc(lines, amount*sizeof(void*));
            }
            lines[count] = line;
            ++count;
        }
    }
    
    *dest = lines;
    return count;
}

void process_file(FILE* input, int numeric, FILE* output) {
    char** lines = NULL;
    int count = 0;
    
    count = parse_file(input, &lines);

    my_qsort(lines, &lines[count-1], numeric);

    print_output(lines, count, output);
    
    free_lines(lines, count);
}

int parse_args(char** argv, int argc, Arguments* args, int* error) {
    if (argc == 1) {
        fprintf(stderr, "No arguments passed. Use -h option for usage help\n");
        *error = EINVAL;
        return 1;
    }

    // Set defaults
    args->output = stdout;
    args->input = NULL;
    args->numeric = 0;
    char* output_name = NULL, *input_name = NULL;

    for (int i = 1; i < argc; ++i) {
        char* arg = argv[i];
        if (strcmp(arg, "-h") == 0 || strcmp(arg, "--help") == 0) {
            print_help();
            return 1;
        } else if (strcmp(arg, "-V") == 0 || strcmp(arg, "--version") == 0) {
            print_version();
            return 1;
        } else if (strcmp(arg, "-o") == 0 || strcmp(arg, "--output") == 0) {
            if (i == argc - 1) {
                fprintf(stderr, "No file specified after -o argument\n");
                *error = EINVAL;
                return 1;
            } else if (strcmp(argv[i+1], "-") != 0) {
                output_name = argv[i+1];
                args->output = fopen(output_name, "w");
            }
        } else if (strcmp(arg, "-n") == 0 || strcmp(arg, "--numeric") == 0) {
            args->numeric = 1;
        }
    }
    
    input_name = argv[argc-1];
    if (input_name == output_name) {
        fprintf(stderr, "No input specified\n");
        *error = EINVAL;
        return 1;
    }

    args->input = fopen(input_name, "r");
    if (!args->input) {
        fprintf(stderr, "Failed to open file %s, error %d\n", input_name, errno);
        *error = errno;
        return 1;
    }
    
    return 0;
}

int main(int argc, const char** argv) {
    Arguments args;
    int ret = 0;

    int finish = parse_args(argv, argc, &args, &ret);
    if (finish) return ret;

    process_file(args.input, args.numeric, args.output);
    
    return 0;
}
