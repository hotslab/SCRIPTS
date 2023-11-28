#include <iostream>
#include <time.h>
#include <cstdlib>

void selectionSort(int *array, int arraySize);
void printArray(int *array, int arraySize);

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
 selectionSort(array, arraySize);
 printArray(array, arraySize);
 return 0;
}

void selectionSort(int *array, int arraySize)
{
 for(int i = 0; i < arraySize; i++)
 {
  int min = i;
  for(int j = i+1; j<arraySize; j++)
  {
   if (array[min] > array[j]) min = j;
  }
  int temp = array[i];
  array[i] = array[min];
  array[min] = temp;
 }
}

void printArray(int *array, int arraySize)
{
  std::cout << '\n';
  for(int i = 0; i < arraySize; i++)
  {
   if (i == 0) std::cout << "[ ";
   std::cout << array[i] << " ";
   if (i == arraySize - 1) std::cout << " ]" << '\n';
  }
}
