#include <iostream>
#include <vector>

const int TABLE_SIZE = 10, SELECT = 0, ADD = 1, GET = 2, REMOVE = 3, EXIT = 4;

class Entry
{
public:
    int key, value;
    Entry(int key, int value)
    {
        this->key = key;
        this->value = value;
    }
    std::string toString()
    {
        return "key => " + std::to_string(key) + " : Value => " + std::to_string(value);
    }
};

class HashTable
{
private:
    std::vector<Entry *> table;
    // Hash function to compute index
    int hash(int key)
    {
        return key % TABLE_SIZE;
    }

public:
    // Constructor to initialize table
    HashTable()
    {
        table.assign(TABLE_SIZE, nullptr);
    }

    // Insert key-value into the hash table
    void insert(int key, int value)
    {
        int index = hash(key);
        while (table[index] != nullptr && table[index]->key != key)
        {
            index = (index + 1) % TABLE_SIZE; // Linear probing
        }
        if (table[index] != nullptr)
        {
            delete table[index];
        }
        table[index] = new Entry(key, value);
    }

    // Search for a key and return its value
    int get(int key)
    {
        int index = hash(key);
        while (table[index] != nullptr && table[index]->key != key)
        {
            index = (index + 1) % TABLE_SIZE;
        }
        if (table[index] == nullptr)
        {
            return -1; // Not found
        }
        return table[index]->value;
    }

    // Delete a key from the hash table
    void remove(int key)
    {
        int index = hash(key);
        while (table[index] != nullptr)
        {
            if (table[index]->key == key)
            {
                delete table[index];
                table[index] = nullptr;
                return;
            }
            index = (index + 1) % TABLE_SIZE;
        }
        list();
    }

    void list()
    {
        std::cout << '\n';
        std::cout << "========= CURRENT HASH TABLE =========" << '\n';
        for (auto i = 0; i < table.size(); i++)
            if (table[i] != nullptr)
                std::cout << i + 1 << ". " << table[i]->toString() << '\n';
        std::cout << "======================================" << '\n'
                  << '\n';
    }
};

void selectOption(HashTable &ht, int &option);
void addEntry(HashTable &ht, int &option);
void getEntry(HashTable &ht, int &option);
void removeEntry(HashTable &ht, int &option);

int main()
{
    int option = SELECT;
    HashTable ht;
    std::cout << "Welcome to sample hash table!" << '\n'
              << '\n';
    while (option != EXIT)
    {
        switch (option)
        {
        case SELECT:
            selectOption(ht, option);
            break;
        case ADD:
            addEntry(ht, option);
            break;
        case GET:
            getEntry(ht, option);
            break;
        case REMOVE:
            removeEntry(ht, option);
            break;
        default:
            std::cout
                << "Invalid argument entered. Please add the correvct value in options given or enter 4 to exit"
                << '\n'
                << '\n';
            option = SELECT;
            break;
        }
    }
    std::cout << "Thank you for smapling this hash table" << '\n'
              << '\n';
    return 0;
}

void selectOption(HashTable &ht, int &option)
{
    ht.list();
    std::cout << "Select option below: " << '\n';
    std::cout << '\t' << "1. Add to hash table" << '\n';
    std::cout << '\t' << "2. Get hash entry" << '\n';
    std::cout << '\t' << "3. Remove hash table entry" << '\n';
    std::cout << '\t' << "4. Exit" << '\n';
    std::cin >> option;
}

void addEntry(HashTable &ht, int &option)
{
    int key;
    int value;
    std::cout << "Enter entry key: ";
    std::cin >> key;
    std::cout << "Enter entry value: ";
    std::cin >> value;
    ht.insert(key, value);
    option = SELECT;
}

void getEntry(HashTable &ht, int &option)
{
    int key;
    std::cout << "Enter entry key to retrieve: ";
    std::cin >> key;
    std::cout << "Value for key " << key << ": " << ht.get(key) << '\n';
    option = SELECT;
}

void removeEntry(HashTable &ht, int &option)
{
    int key;
    std::cout << "Enter entry key to remove: ";
    std::cin >> key;
    ht.remove(2);
    std::cout << "Value for key " << key << " after removal: " << ht.get(key) << '\n';
    option = SELECT;
}