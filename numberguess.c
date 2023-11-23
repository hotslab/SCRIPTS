#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main() {
    const int MIN = 1;
    const int MAX = 100;
    int guess;
    int guesses;
    int answer;
    double test;
    float test2;
    char test3;

    test3 ? printf("%c - is true \n", test3) : printf("%c - is false \n", test3);

    printf("%d - ching int value\n", guess);
    printf("%f- ching int value\n", test);
    printf("%lf - ching int value\n", test2);
    printf("%c - ching int value\n", test3);

    srand(time(0));

    answer = (rand() % MAX) + MIN;

    do {
        printf("Enter a guess:\n");
        scanf("%d", &guess);
        if (guess > answer) {
            printf("To high!\n");
        } else if (guess < answer) {
            printf("To low!\n");
        } else {
            printf("*******************************\n");
            printf("Correct!\n");
        }
        guesses++;
    } while (guess != answer);

    printf("*******************************\n");
    printf("answer: %d\n", answer);
    printf("guesses it took: %d\n", guesses);
    printf("*******************************\n");

    return 0;
}