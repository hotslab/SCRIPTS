#include <stdio.h>
#include <iostream>
#include <chrono>


int binarySearch(const int *sortedNumbers, int searchValue, int arrayLength);

int main () {
    auto start = std::chrono::high_resolution_clock::now();
    int searchValue;
    int arrayLength;
    std::cout << "Type a number to find: ";
    std::cin >> searchValue;
    std::cout << "Type the size of the array: ";
    std::cin >> arrayLength;
    std::cout << "\n";
    int sortedNumbers[arrayLength]; 
    for (int i = 0; i < arrayLength; i++) sortedNumbers[i] = i + 1;
    int resultIndex = binarySearch(sortedNumbers, searchValue, arrayLength);
    if (resultIndex > -1)
        std::cout << sortedNumbers[resultIndex] << " was found at index " << resultIndex << '\n';
    else
        std::cout << searchValue << " was not found! Return value was " << resultIndex << '\n';
    auto finish = std::chrono::high_resolution_clock::now();
    std::cout << "Duration: " << std::chrono::duration_cast<std::chrono::nanoseconds>(finish - start).count() << " ns\n";
    return 0;
}


/* 
    - works with sorted array data 
    - works great with large datasets
    - O(log n) - best time
*/
int binarySearch(const int *sortedNumbers, int searchValue, int arrayLength)
{
    int lowIndex = 0;
    int highIndex = arrayLength - 1;
    while (highIndex > lowIndex) {
        int middleIndex = lowIndex + (highIndex - lowIndex)/2;
        int foundValue = sortedNumbers[middleIndex];
        if (foundValue < searchValue) lowIndex = middleIndex;
        else if (foundValue > searchValue) highIndex = middleIndex;
        else return middleIndex;
    }
    return -1;
}
