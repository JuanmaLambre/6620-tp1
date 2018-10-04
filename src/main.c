#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#define FILE_MAX_LINES 256
#define LINE_MAX_LENGTH 100
#define CHUNK_SIZE 10


void my_qsort(char** left, char** right, int num) {
    int count = (int)(right - left + 1);
    if (count > 1) {
        char* pivot = &right;
        char** cur = left;
        char** nextMin = left;
        for (; cur <= right; ++cur) {
            int cursorSmaller = 0;
            if (num) cursorSmaller = (atoi(&cur) <= atoi(&pivot));
            else cursorSmaller = (strcmp(&cur, &pivot) <= 0);

            if (cursorSmaller) {
                char* aux = &nextMin;
                nextMin[0] = &cur;
                cur[0] = aux;
                nextMin += 1;
            }
        }
        //my_qsort(left, nextMin-1, num);
        //my_qsort(nextMin, right, num);
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
        fputs(lines[i], output);
    }
}

void free_lines(char** lines, int count) {
    for (int i = 0; i < count; ++i) {
        free(lines[i]);
    }
    free(lines);
}

void process_file(FILE* input, int numeric, FILE* output) {
    char buffer[LINE_MAX_LENGTH];
    char** lines = NULL;
    int count = 0;

    // Read file line by line
    while (fgets(buffer, LINE_MAX_LENGTH, input)) {
        if (count >= FILE_MAX_LINES) {
            // Raise error
        }
        if ((count % CHUNK_SIZE) == 0) {
            int amount = (count/CHUNK_SIZE+1)*CHUNK_SIZE;
            lines = (char**) realloc(lines, amount*sizeof(void*));
        }
        
        lines[count] = (char**) malloc(strlen(buffer)+1);
        strcpy(lines[count], buffer);

        ++count;
    }

    // Sort the lines
    my_qsort(lines, &lines[count-1], numeric);

    // Print the lines
    print_output(lines, count, output);
    
    free_lines(lines, count);
}

int main(int argc, const char** argv) {
    // Set the parameters
    FILE* output = stdout;
    FILE* input = NULL;
    int numeric = 0;

    for (int i = 1; i < argc; ++i) {
        char* arg = argv[i];
        if (strcmp(arg, "-h") == 0 || strcmp(arg, "--help") == 0) {
            print_help();
            return 0;
        } else if (strcmp(arg, "-V") == 0 || strcmp(arg, "--version") == 0) {
            print_version();
            return 0;
        } else if (strcmp(arg, "-o") == 0 || strcmp(arg, "--output") == 0) {
            if (strcmp(argv[i+1], "-") != 0)
                output = fopen(argv[i+1], "w");
        } else if (strcmp(arg, "-n") == 0 || strcmp(arg, "--numeric") == 0) {
            numeric = 1;
        }
    }

    input = fopen(argv[argc-1], "r");

    // And we do the processing now
    process_file(input, numeric, output);
    
    return 0;
}
