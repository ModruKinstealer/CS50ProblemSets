#include <cs50.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>

int alpha_key(string key);
int alpha_once(string key, string alpha);
string convert_plaintext(string plain_text, string key, string alpha);

int main(int argc, string argv[])
{
    // Validate argument
    // Only 1 argument
    if (argc != 2)
    {
        printf("Usage: ./substitution key\n");
        return 1;
    }
    string key = argv[1];
    // Argument should be 26 characters and only alpha characters
    if (alpha_key(key) != 0 || strlen(key) != 26)
    {
        printf("Key must contain 26 alpha characters\n");
        printf("key is %lu letters\n", strlen(key));
        return 1;
    }
    // Setting a string to compare against, it's used in more than one function so I set it here as the first instance of use.
    string alpha = "abcdefghijklmnopqrstuvwxyz";
    // Argument has to contain each letter of alphabet exactly once
    if (alpha_once(key, alpha) != 0)
    {
        printf("Key must contain each letter exactly once\n");
        return 1;
    }
    // Get user input
    string plain_text = get_string("plaintext: ");
    // Argument passed as a string so it's an array we'll be able to iterate through
    string cipher_text = convert_plaintext(plain_text, key, alpha);
    printf("ciphertext: %s\n", cipher_text);
    return 0;
}

// Function to determine if all the characters in the key are alphabetical
int alpha_key(string key)
{
    for (int i = 0, l = strlen(key); i < l; i++)
    {
        if (isalpha(key[i]) == 0)
        {
            return 1;
        }
    }
    return 0;
}

// Function to verify each letter of the alphabet is used exactly once
int alpha_once(string key, string alpha)
{
    // We'll have to iterate through alpha and inside that loop will be another loop to iterate through key
    for (int i = 0, l = strlen(alpha), alpha_count = 0; i < l; i++)
    {
        // Secondary loop to iterate through the key comparing alpha[i] to each member of key and incrementing a variable each time they equal
        for (int j = 0, m = strlen(key); j < m; j++)
        {
            if (alpha[i] == tolower(key[j]))
            {
                alpha_count++;
            }
        }
        // If alpha[i] appears in key more than once return a false to break out of the loops.
        if (alpha_count != 1)
        {
            return 1;
        }
        alpha_count = 0;
    }
    return 0;
}

// Function to handle converting plaintext to ciphertext
string convert_plaintext(string plain_text, string key, string alpha)
{
    string ciphertext = plain_text;
    for (int i = 0, l = strlen(plain_text); i < l; i++)
    {
        // Check if it's an alpha character, if no send to ciphertext, if yes process further
        if (isalpha(plain_text[i]))
        {
            // It is alpha
            // Find plain_text[i] in alpha[]
            for (int j = 0, m = strlen(alpha); j < m; j++)
            {
                if (tolower(plain_text[i]) == alpha[j])
                {
                    if (isupper(plain_text[i]))
                    {
                        ciphertext[i] = toupper(key[j]);
                        break;
                    }
                    else
                    {
                        // Forcing it to lower to match what's in plaintext in case the key happens to be uppercase.
                        ciphertext[i] = tolower(key[j]);
                        break;
                    }
                }
            }
        }
        else
        {
            // Is not alpha
            ciphertext[i] = plain_text[i];
        }
    }
    return ciphertext;
}
