#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#define FILE_MAX_LINES 256
#define LINE_MAX_LENGTH 100
#define CHUNK_SIZE 10

int compare(char* ptr1, char* ptr2, int num) {
    if (num) return atoi(ptr1) - atoi(ptr2);
    else return strcmp(ptr1, ptr2);
}

void my_qsort(char** left, char** right, int num) {
    int count = (int)(right - left + 1);
    if (left < right) { // Creo que es al pedo usar el count
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

void print_help() {
    printf("USAGE HELP");
}

void print_version() {
    printf("Version 1.0");
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

int parse_file(FILE* input, void** dest) {
    char** lines = NULL;
    char buffer[LINE_MAX_LENGTH];
    int count = 0;

    while (fgets(buffer, LINE_MAX_LENGTH, input)) {
        int strsize = strlen(buffer);
        if (buffer[strsize-1] == '\n') buffer[strsize-1] = '\0';
        
        if (strlen(buffer) > 0) {
            if ((count % CHUNK_SIZE) == 0) {
                int amount = (count/CHUNK_SIZE+1)*CHUNK_SIZE;
                lines = (char**) realloc(lines, amount*sizeof(void*));
            }
            
            lines[count] = (char**) malloc(strlen(buffer)+1);
            strcpy(lines[count], buffer);

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

int main(int argc, const char** argv) {
    // Set the parameters
    FILE* output = stdout;
    FILE* input = NULL;
    int numeric = 0;

    if (argc == 1) {
        fprintf(stderr, "No arguments passed. Use -h option for usage help");
        return 1;
    }

    for (int i = 1; i < argc; ++i) {
        char* arg = argv[i];
        if (strcmp(arg, "-h") == 0 || strcmp(arg, "--help") == 0) {
            print_help();
            return 0;
        } else if (strcmp(arg, "-V") == 0 || strcmp(arg, "--version") == 0) {
            print_version();
            return 0;
        } else if (strcmp(arg, "-o") == 0 || strcmp(arg, "--output") == 0) {
            if (i == argc - 1) {
                fprintf(stderr, "No file specified after -o argument");
                return EINVAL;
            } else if (strcmp(argv[i+1], "-") != 0) {
                output = fopen(argv[i+1], "w");
            }
        } else if (strcmp(arg, "-n") == 0 || strcmp(arg, "--numeric") == 0) {
            numeric = 1;
        }
    }

    char* filename = argv[argc-1];
    input = fopen(filename, "r");
    if (!input) {
        fprintf(stderr, "Failed to open file %s, error %d", filename, errno);
    }

    // And we do the processing now
    process_file(input, numeric, output);
    
    return 0;
}
