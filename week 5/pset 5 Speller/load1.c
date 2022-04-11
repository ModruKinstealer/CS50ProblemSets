// 1st iteration of the load function
// Doesn't seem to be loading properly, it doesn't seem to be evaluating if (table[hash_num] == NULL)
// properly, and doesn't seem to be executing the else either...
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
        // node *list = NULL;
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
        //Is this the first node for table[hash_num]
        if (table[hash_num] == NULL)
        {
            table[hash_num] = n;
        }
        // It's not the 1st so we have to make sure to insert carefully to not lose existing nodes
        else
        {
            // Need to point n at first node
            n -> next = table[hash_num] -> next;
            table[hash_num] = n;
        }
        word_count++;
    }
    fclose(dict);
    return true;
}