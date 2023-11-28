#include <iostream>
#include <array>
#include <time.h>
#include <cstdlib>

void mergeSort(int array[], int arraySize);
void merge(int leftArray[], int rightArray[], int array[], int arraySize);
void printArray(int array[], int arraySize);

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
    // std::array<int, 5> array;
    int array[arraySize];
    for (int i = 0; i < arraySize; i++)
        array[i] = rand() % integerBound;
    printArray(array, arraySize);
    mergeSort(array, arraySize);
    printArray(array, arraySize);
    return 0;
}

void mergeSort(int array[], int arraySize)
{
    if (arraySize <= 1) return;
    int middle = arraySize/2;
    int leftArray[middle];
    int rightArray[arraySize - middle];
    int leftIndex = 0;
    int rightIndex = 0;
    for (int i = 0; i < arraySize; i++)
    {
        if (i < middle) {
            leftArray[leftIndex] = array[i];
            leftIndex++;
        } else {
            rightArray[rightIndex] = array[i];
            rightIndex++;
        }
    }
    mergeSort(leftArray, middle);
    mergeSort(rightArray, arraySize - middle);
    merge(leftArray, rightArray, array, arraySize);
}

void merge(int leftArray[], int rightArray[], int array[], int arraySize)
{
    int leftSize = arraySize/2;
    int rightSize = arraySize - leftSize;
    int i = 0, l = 0 , r = 0;

    // merging conditions
    while(l < leftSize && r < rightSize) {
        if (leftArray[l] < rightArray[r]) {
            array[i] = leftArray[l];
            i++;   
            l++;
        } else {
            array[i] = rightArray[r];
            i++;
            r++;
        }
    }
    while(l < leftSize) {
        array[i] = leftArray[l];
        i++;
        l++;
    }
    while(r < rightSize) {
        array[i] = rightArray[r];
        i++;
        r++;
    }

}

void printArray(int array[], int arraySize)
{
    std::cout << '\n';
    for (int i = 0; i < arraySize; i++)
    {
        if (i == 0)
            std::cout << "[ ";
        std::cout << array[i] << " ";
        if (i == arraySize - 1)
            std::cout << " ]" << '\n';
    }
}
