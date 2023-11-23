#include <iostream>

int interpolationSearch(int array[], int arraySize, int value);

int main() {
    int value;
    int size;
    std::cout << "Enter search number: ";
    std::cin >> value;
    std::cout << "Enter array size: ";
    std::cin >> size;
    int array[size];
    for (int i = 0; i < size; i++) {
        array[i] = i + (i != 0 ? 2 + (i - 1) : 1 ) ;
        std::cout << array[i] << " ";
    }
    std::cout << '\n';
    int index = interpolationSearch(array, size, value);
    if (index > -1) std::cout << value << " was found on index " << index << '\n';
    else std::cout << value << " was not found!" << '\n';
    return 0;
}

int interpolationSearch(int array[], int arraySize, int value) {
    int low = 0;
    int high = arraySize - 1;
    while (value >= array[low] && value <= array[high] && low <= high) {
        int probe = low + (((double)(high - low) / (array[high] - array[low])) * (value - array[low]));
        if (array[probe] < value) low = probe + 1;
        else if (array[probe] > value) high = probe - 1;
        else if (array[probe] == value) return probe;
    }
    return -1;
}