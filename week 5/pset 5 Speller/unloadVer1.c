// Unloads dictionary from memory, returning true if successful, else false
bool unload(void)
{
    // TODO
    // For each element of table[]
    bool complete;
    for (int i = 0; i < N; i++)
    {
        // If element is not NULL
        if (table[i] != NULL)
        {
            // Call helper function to free elements of list recursively
            complete = free_lists(table[i]);
        }
    }
    return complete;
}

// Frees elements of linked list, returns true/false, takes a node pointer to a list
bool free_lists(node *list)
{
    // If list is null stop
    if (list == NULL)
    {
        return true;
    }
    // Free rest of list by calling free_lists with reduced list
    free_lists(list -> next);
    // Free current node
    free(list);
    return true;
}