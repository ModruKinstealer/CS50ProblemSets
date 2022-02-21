#include <cs50.h>
#include <ctype.h>
#include <math.h>
#include <stdio.h>
#include <string.h>

int count_letters(string text);
int count_words(string text);
int count_sentences(string text);

int main(void)
{
    string text = get_string("Text: ");
    int num_letters = count_letters(text);
    int num_words = count_words(text);
    int num_sentences = count_sentences(text);
    // I could have had these calculations in the line for casting index but this feels easier to read/maintain
    float l = ((float)num_letters / num_words) * 100;
    float s = ((float)num_sentences / num_words) * 100;
    // Coleman-Liau index index = 0.0588 * L - 0.296 * S - 15.8
    int index = round(0.0588 * l - 0.296 * s - 15.8);
    if (index > 16)
    {
        printf("Grade 16+\n");
    }
    else if (index < 1)
    {
        printf("Before Grade 1\n");
    }
    else
    {
        printf("Grade %i\n", index);
    }
}


int count_letters(string text)
{
    int n = 0;
    for (int i = 0, l = strlen(text); i < l; i++)
    {
        if (isalpha(text[i]))
        {
            n++;
        }
    }
    return n;
}

int count_words(string text)
{
    int n = 0;
    for (int i = 0, l = strlen(text); i < l; i++)
    {
        if (isspace(text[i]))
        {
            n++;
        }
    }
    // There are n spaces but since the sentences don't end in a space we need to add 1 for the last word.
    return n + 1;
}

int count_sentences(string text)
{
    int n = 0;
    for (int i = 0, l = strlen(text); i < l; i++)
    {
        // ! = 33, . = 46, ? = 63
        if (text[i] == 33 || text[i] == 46 || text[i] == 63)
        {
            n++;
        }
    }
    return n;
}