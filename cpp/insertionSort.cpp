#include <iostream>
#include <time.h>
#include <cstdlib>

void insertionSort(int array[], int &arraySize);
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
 for(int i = 0; i < arraySize; i++) 
 	array[i] = rand() % integerBound;
 printArray(array, arraySize);
 insertionSort(array, arraySize);
 printArray(array, arraySize);
 return 0;
}

void insertionSort(int array[], int &arraySize)
{
 for(int i = 1; i < arraySize; i++)
 {
  int temp = array[i];
  int leftIndex = i - 1;
  while(leftIndex >= 0 && array[leftIndex] > temp)
  {
    array[leftIndex+1] = array[leftIndex];
    leftIndex--;
  }
  array[leftIndex + 1] = temp;
 }
}

void printArray(int array[], int &arraySize)
{
  std::cout << '\n';
  for(int i = 0; i < arraySize; i++)
  {
   if (i == 0) std::cout << "[ ";
   std::cout << array[i] << " ";
   if (i == arraySize - 1) std::cout << " ]" << '\n';
  }
}
