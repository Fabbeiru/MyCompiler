// Categories of the symbols stored:
// V: variable
// F: function (either external function or main)
enum categories {var, func};
extern char *initCategories;

// Structure of each node of our LinkedList
extern struct Node {
    char *varName;
    int address;
    int functArguments;
    enum categories cat;
    struct Node *next;
} *head;

// Returns first node in the list with same varName
struct Node *searchName(char *varName);

// Returns node if same categories
struct Node *searchCat(char *varName, enum categories cat);

// Creates a new node in the LinkedList
struct Node *insert(char *varName, enum categories cat);

// After calling insert adds the address atribute to the returning Node
struct Node *addAddress(char *varName, enum categories cat, int address);

// Frees memory used in storing symbols inside a function
void freeMemory();

// Prints information of our symbol table
void showInConsole(const char* s);
