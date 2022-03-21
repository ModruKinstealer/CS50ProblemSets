#include <cs50.h>
#include <stdio.h>

// Function prototype(s)
void place_blocks(int n);
void place_spaces(int m);

int main(void)
{
    // Ask user for number of levels between 1 and 8 inclusive
    // If they enter a number not in that range prompt again
    int levels;
    do
    {
        levels = get_int("Choose a number of levels for the Pyramid from 1 through 8: ");
    }
    while (levels < 1 || levels > 8);
    // Levels number of rows
    for (int i = 1; i <= levels; i++)
    {
        place_spaces(levels - i);
        place_blocks(i);
        printf("  ");
        place_blocks(i);
        printf("\n");
    }
}

// Place n number of hash blocks
void place_blocks(int n)
{
    for (int i = 1; i <= n; i++)
    {
        printf("#");
    }
}

// Place m number of spaces
void place_spaces(int m)
{
    for (int i = 1; i <= m; i++)
    {
        printf(" ");
    }
}