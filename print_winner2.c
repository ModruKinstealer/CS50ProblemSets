// Print the winner of the election
void print_winner(void)
{
    // Print the winner of a locked pair that does not appear as a loser in a locked pair
    // Setting a variable to keep track of whether or not a candidates[i] has shown in pairs as a pairs[j].loser
    int losses = 0;
    for (int i = 0; i < candidate_count; i++)
    {
        // Is candidates[i] a loser of a locked pair?
        for (int j = 0; j < pair_count; j++)
        {
            if (i == pairs[j].loser && locked[pairs[j].winner][pairs[j].loser] == true)
            {
                losses++;
                break;
            }
        }
        // If losses equals zero, print winner's name
        if (losses == 0)
        {
            printf("%s\n", candidates[i]);
        }
        else
        {
            // Reset losses for next iteration
            losses = 0;
        }
    }
    return;
}