#include <iostream>
#include <array>
#include <time.h>
#include <cstdlib>

void quickSort(int array[], int arraySize, int start, int end);
int partition(int array[], int arraySize, int start, int end);
void printArray(int array[], int &arraySize);

int main()
{
    int arraySize;
    int integerBound;
    std::cout << "Enter array size: ";
    std::cin >> arraySize;
    std::cout << "Enter maximum size of integer: ";
    std::cin >> integerBound;
    std::cout << '\n';
    srand(time(0));
    int array[arraySize];
    for (int i = 0; i < arraySize; i++)
        array[i] = rand() % integerBound;
    printArray(array, arraySize);
    quickSort(array, arraySize, 0, arraySize -1);
    printArray(array, arraySize);
    return 0;
}

void quickSort(int array[], int arraySize, int start, int end)
{
    std::cout << "Start => " << start << " End => " << end << " Condtion => " <<(end <= start) << '\n';
    if (end <= start) return;
    int pivot = partition(array, arraySize, start, end);
    std::cout << pivot << " is the pivot" << '\n';
    quickSort(array, arraySize, start, pivot - 1);
    quickSort(array, arraySize, pivot + 1, end);
}

int partition(int array[], int arraySize, int start, int end)
{
    std::cout << "Partion is being run" << '\n';
    int pivot = array[end];
    int startIndex = start - 1;

    for (int i = start; i <= end; i++)
    {
        if (array[i] < pivot) {
            startIndex++;
            int temp = array[startIndex];
            array[startIndex] = array[i];
            array[i] = temp;
        }
    }
    int temp = array[startIndex];
    array[startIndex] = array[end];
    array[end] = temp;

    return startIndex;
}

void printArray(int array[], int &arraySize)
{
    std::cout << '\n';
    for (int i = 0; i < arraySize; i++)
    {
        if (i == 0)
            std::cout << "[ ";
        std::cout << array[i] << " ";
        if (i == arraySize - 1)
            std::cout << "]" << '\n';
    }
}
