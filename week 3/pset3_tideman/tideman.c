#include <cs50.h>
#include <stdio.h>
#include <strings.h>

// Max number of candidates
#define MAX 9

// preferences[i][j] is number of voters who prefer i over j
int preferences[MAX][MAX];

// locked[i][j] means i is locked in over j
bool locked[MAX][MAX];

// Each pair has a winner, loser
typedef struct
{
    int winner;
    int loser;
}
pair;

// Array of candidates
string candidates[MAX];
pair pairs[MAX * (MAX - 1) / 2];

int pair_count;
int candidate_count;

// Function prototypes
bool vote(int rank, string name, int ranks[]);
void record_preferences(int ranks[]);
void add_pairs(void);
void sort_pairs(void);
void lock_pairs(void);
void print_winner(void);
bool cycle_created(int test_pair_winner, int test_pair_loser);

int main(int argc, string argv[])
{
    // Check for invalid usage
    if (argc < 2)
    {
        printf("Usage: tideman [candidate ...]\n");
        return 1;
    }

    // Populate array of candidates
    candidate_count = argc - 1;
    if (candidate_count > MAX)
    {
        printf("Maximum number of candidates is %i\n", MAX);
        return 2;
    }
    for (int i = 0; i < candidate_count; i++)
    {
        candidates[i] = argv[i + 1];
    }

    // Clear graph of locked in pairs
    for (int i = 0; i < candidate_count; i++)
    {
        for (int j = 0; j < candidate_count; j++)
        {
            locked[i][j] = false;
        }
    }

    pair_count = 0;
    int voter_count = get_int("Number of voters: ");

    // Query for votes
    for (int i = 0; i < voter_count; i++)
    {
        // ranks[i] is voter's ith preference
        int ranks[candidate_count];

        // Query for each rank
        for (int j = 0; j < candidate_count; j++)
        {
            string name = get_string("Rank %i: ", j + 1);

            if (!vote(j, name, ranks))
            {
                return 3;
            }
        }

        record_preferences(ranks);
    }

    add_pairs();
    sort_pairs();
    lock_pairs();
    print_winner();
    return 0;
}

// Update ranks given a new vote
bool vote(int rank, string name, int ranks[])
{
    for (int i = 0, l = candidate_count; i < l; i++)
    {
        // Check each element of candidates[] to see if it matches the name and if so update the ranks[] array
        if (strcasecmp(name, candidates[i]) == 0)
        {
            // Rank is the nth iteration of 1st place, 2nd place, etc ..nth place, i represents the index of the matched name in candidates[]
            ranks[rank] = i;
            return true;
        }
    }
    // If name doesn't exist in candidates[] return false
    return false;
}

// Update preferences given one voter's ranks
void record_preferences(int ranks[])
{
    // Iterate over ranks[], ranks[i] is prefered over every candidate ranks[>i]
    for (int i = 0, l = candidate_count; i < l; i++)
    {
        // Iterate over ranks[] again, starting at i because i is prefered over every index >i in ranks[]
        for (int j = i + 1, m = candidate_count; j < m; j++)
        {
            // Preferences[i] stays the same but each preferences[j] needs to increment +1
            preferences[ranks[i]][ranks[j]]++;
        }
    }
    return;
}

// Record pairs of candidates where one is preferred over the other
void add_pairs(void)
{
    // Preferences[][] is a n x n grid with both the x axis and y axis are candidates[0] through candidates[candidates_count]
    // First For loop is to allow us to loop through each layer of the preferences[][] grid (0,0), (1,1), (2,2)... (n,n)
    for (int i = 0, l = candidate_count; i < l - 1 ; i++)
    {
        // Second loop allows us to loop through the internal elements of those outer layers peeling it like an onion until we get to (7,8)(8,7)
        for (int j = i, m = candidate_count; j < m; j++)
        {
            if (preferences[i][j] != preferences[j][i])
            {
                // Update pair[i].winner and pair[i].loser
                if (preferences[i][j] > preferences[j][i])
                {
                    pairs[pair_count].winner = i;
                    pairs[pair_count].loser = j;
                }
                else
                {
                    pairs[pair_count].winner = j;
                    pairs[pair_count].loser = i;
                }
                // Increment pair_count
                pair_count++;
            }
        }
    }
    return;
}

// Sort pairs in decreasing order by strength of victory
void sort_pairs(void)
{
    // If 1 or fewer pairs, It's already sorted
    if (pair_count <= 1)
    {
        return;
    }
    else
    {
        // Create an array that allows us store temporary values in it
        pair sorted_pairs[pair_count];
        // We want the largest pairs[i].winner, to allow us to put pairs[i] at pairs[0] then go down from there
        int largest = 0;
        // Find out which pairs[i].winner is the largest
        for (int i = 0; i < pair_count; i++)
        {
            if (preferences[pairs[i].winner][pairs[i].loser] > largest)
            {
                largest = preferences[pairs[i].winner][pairs[i].loser];
            }
        }
        // Keep track of what was the last index of sorted_pairs[] used
        int sorted_pairs_index = 0;
        // Find pairs[].winner that equals largest
        while (sorted_pairs_index < pair_count)
        {
            for (int i = 0; i < pair_count; i++)
            {
                if (preferences[pairs[i].winner][pairs[i].loser] == largest)
                {
                    sorted_pairs[sorted_pairs_index].winner = pairs[i].winner;
                    sorted_pairs[sorted_pairs_index].loser = pairs[i].loser;
                    sorted_pairs_index++;
                }
            }
            largest--;
        }
        // Update pairs[] from sorted_pairs[]
        for (int i = 0; i < pair_count; i++)
        {
            pairs[i] = sorted_pairs[i];
        }
    }
    return;
}

// Lock pairs into the candidate graph in order, without creating cycles
void lock_pairs(void)
{
    // Locked[i][j] means i is locked in over j
    // If there are no pairs then no need to try to lock anything
    if (pair_count > 0)
    {
        // Since they're sorted highest to lowest pairs[0] is always going to lock
        locked[pairs[0].winner][pairs[0].loser] = true;
        // Iterate over rest of pairs[]
        for (int j = 1; j < pair_count; j++)
        {
            // Is it safe to lock pairs[j], doing so does not create a cycle
            if (cycle_created(pairs[j].winner, pairs[j].loser))
            {
                locked[pairs[j].winner][pairs[j].loser] = true;
            }
        }
    }
    return;
}

// Print the winner of the election
void print_winner(void)
{
    // Print the winner of a locked pair that does not appear as a loser in a locked pair
    // Setting a variable to keep track of whether or not a candidates[i] has shown in pairs as a pairs[j].loser
    int losses = 0;
    for (int i = 0; i < candidate_count; i++)
    {
        // Is candidates[i] a loser of a locked pair?
        for (int j = 0; j < candidate_count; j++)
        {
            if (locked[j][i])
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

// Return true if no cycle is created
bool cycle_created(int test_pair_winner, int test_pair_loser)
{
    bool truefalse = true;
    // Does the current_pair.loser appear as a winner in any locked pair
    for (int i = 0; i < pair_count; i++)
    {
        if (locked[test_pair_loser][i])
        {
            // If locked[i][test_pair_winner] is true, cycle is created, return false
            if (locked[i][test_pair_winner])
            {
                truefalse = false;
            }
            // Since locked[i][test_pair_winner] isn't true, we need to see if i wins over another number that does beat test_pair_winner
            else if (!cycle_created(test_pair_winner, i))
            {
                truefalse = false;
            }
        }
    }
    return truefalse;
}