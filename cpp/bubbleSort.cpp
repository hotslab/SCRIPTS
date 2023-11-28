#include <iostream>
#include <cstdlib>
#include <time.h>

void bubbleSort(int *array, int arraySize);
void printArray(int *array, int arraySize);

int main()
{
    int arraySize;
    int integerSize;
    std::cout << "Enter maximum size of integer: ";
    std::cin >> integerSize;
    std::cout << "Enter size of array: ";
    std::cin >> arraySize;
    std::cout << '\n';
    int array[arraySize];
    srand(time(0));
    for (int i = 0; i < arraySize; i++) array[i] = rand() % integerSize;
    printArray(array, arraySize);
    bubbleSort(array, arraySize);
    printArray(array, arraySize);
    return 0;
}

void bubbleSort(int *array, int arraySize) 
{
    for (int i = 0; i < arraySize - 1; i++)
    {
        std::cout << "==================================" << '\n';
        std::cout << "index=> " << i << ", value => " << array[i] << '\n';
        std::cout << "==================================" << '\n';
        for (int j = 0; j < arraySize - i - 1; j++)
        {
            std::cout << "Jindex=> " << j << ", Jvalue => " << array[j] << ", Jvalue+ => " << array[j+1] <<'\n';
            if (array[j] > array[j+1]) {
                int temp = array[j];
                array[j] = array[j+1];
                array[j+1] = temp; 
            }
        }
        std::cout << "==================================" << '\n';
        std::cout << '\n';
    }
    
}

void printArray(int *array, int arraySize) {
    std::cout << '\n';
    for (int i = 0; i < arraySize; i++)
    {
        if (i == 0) std::cout << "[ ";
        std::cout << array[i] << " ";
        if (i == arraySize - 1) std::cout << "]" << '\n';
    }
}
