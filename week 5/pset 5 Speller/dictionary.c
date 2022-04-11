
 Implements a dictionary's functionality

#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>

#include "dictionary.h"

// Represents a node in a hash table
typedef struct node
{
    char word[LENGTH + 1];
    struct node *next;
}
node;

// TODO: Choose number of buckets in hash table
const unsigned int N = 6144;

// Hash table
node *table[N];

// Returns true if word is in dictionary, else false
bool check(const char *word)
{
    // Hash word to find out where in table[] it's linked list should be
    int index = hash(word);
    if (table[index] == NULL)
    {
        return false;
    }
    // Create a new node
    node *checker = table[index];
    while (checker != NULL)
    {
        if (strcasecmp(word, checker -> word) == 0)
        {
            return true;
        }
        else
        {
            checker = checker ->next;
        }
    }
    return false;
}

// Hashes word to a number
unsigned int hash(const char *word)
{
    // TODO: Improve this hash function
    // Sources used to determine how many buckets I thought would work well
    // Text containing all english words with no numbers or symbols
    // Https://github.com/dwyl/english-words/blob/22d7c41119076750a96fca2acd664ed994cc0a75/words_alpha.txt

    // If word is less than 4 characters, just put them in a-z buckets by first character
    if (strlen(word) < 4)
    {
        int n = tolower(word[0]) - 'a';
        return n;
    }
    // If word is 19 characters or longer lump them into one bucket
    if (strlen(word) > 18)
    {
        return tolower(word[0]) - 'a';
    }
    // If word is 4-18 characters, iterate over word, sum ascii values of each leter from i to end of word
    unsigned int sum = 0;
    for (int i = 0; i < strlen(word); i++)
    {
        for (int j = i; j < strlen(word); j++)
        {
            sum += tolower(word[j]);
        }
    }
    // Divide sum by 3, add ascii value of word[0], then subtract 378
    int n = (sum / 3) + tolower(word[0]) - 378;
    // If n is less than zero then dump the word into the a-z bucket based on first letter of word
    if (n < 0)
    {
        n = tolower(word[0]) - 'a';
    }
    return n;
}

// Keep track of number of words in dictionary
int word_count = 0;

// Loads dictionary into memory, returning true if successful, else false
bool load(const char *dictionary)
{
    // TODO
    // Open dictionary
    FILE *dict = fopen(dictionary, "r");
    if (dict == NULL)
    {
        return false;
    }
    // Read string from file 1 at a time
    char str[LENGTH + 1];
    while (fscanf(dict, "%s", str) != EOF)
    {
        // Create a new node
        node *n = malloc(sizeof(node));
        if (n == NULL)
        {
            printf("Unable to allocate memory to create a new node.\n");
            return false;
        }
        strcpy(n -> word, str);
        n -> next = NULL;
        // Hash str so we know where in our table[] array to put our node
        unsigned int hash_num = hash(str);
        // Insert node into hash table
        // Need to point n at first node
        if (table[hash_num] == NULL)
        {
            table[hash_num] = n;
        }
        else
        {
            n -> next = table[hash_num];
            // Now that N points to the first element we can make the head equal n
            table[hash_num] = n;
        }
        // Keeping track of how many words we've added to the dictionary for later use
        word_count++;
    }
    fclose(dict);
    return true;
}

// Returns number of words in dictionary if loaded, else 0 if not yet loaded
unsigned int size(void)
{
    // TODO
    return word_count;
}

// Unloads dictionary from memory, returning true if successful, else false
bool unload(void)
{
    // TODO
    // For each element of table[]
    for (int i = 0; i < N; i++)
    {
        // If element is not NULL
        if (table[i] != NULL)
        {
            // Loop through all elements of table[i]
            node *current = table[i];
            while (current != NULL)
            {
                // Create a temp variable equal to current
                node *temp = current;
                current = current -> next;
                free(temp);
            }
            //free(current);
        }
    }
    return true;
}
