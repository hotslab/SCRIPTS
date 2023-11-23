#include <stdio.h>
#include <iostream>

int main() {
    char test[] = "Tested second";
    std::string test2 = "Tested second";

    std::printf("%s\n", test);
    std::printf("%d\n", sizeof(test));
    std::cout << test2 << '\n';
    std::cout << sizeof(test2) << '\n';
    
    return 0;   
}

