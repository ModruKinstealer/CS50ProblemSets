#include <cs50.h>
#include <stdio.h>

int main(void)
{
    long cc = 0;
    do
    {
        cc = get_long("Please enter a valid Credit Card number: ");
    }
    // Since the lowest valid # of digits for a CC is 13 I'm throwing out any number that is less than that.
    while (cc < 999999999999);
    long digit = cc;
    // While loop to go through and modulo 10 to determine each digit of the number
    int checksum = 0, i = 0, first_two = 0;
    while (digit > 0)
    {
        // If count is even add digit to checksum
        int last_digit = digit % 10;
        if (i % 2 == 0)
        {
            checksum = checksum + last_digit;
        }
        // Else  multiply digit by 2
        else
        {
            last_digit = last_digit * 2;
            // If sum > 9
            if (last_digit > 9)
            {
                checksum = checksum + last_digit % 10;
                last_digit = last_digit / 10;
                checksum = checksum + last_digit;
            }
            else
            {
                checksum = checksum + last_digit;
            }
        }
        if (digit >= 10 && digit <= 99)
        {
            first_two = digit;
        }
        digit = digit / 10;
        i++;
    }
    int cc_checksum = 0;
    // Once determine checksum set variable to true or false to be stored for next step
    if (checksum % 10 == 0)
    {
        cc_checksum = 1;
    }
    // Check for correct number of digits 13, 15, or 16 for our requirements
    int cc_num_digits_valid = 0;
    if (i == 13 || i == 15 || i == 16)
    {
        cc_num_digits_valid = 1;
    }
    // Does the number start with one of the valid startng numbers for AMEX, MC, or Visa
    int cc_first_two_valid = 0;
    string card_type = "";
    if (first_two == 34 || first_two == 37)
    {
        cc_first_two_valid = 1;
        card_type = "AMEX\n";
    }
    else if (first_two > 50 && first_two < 56)
    {
        cc_first_two_valid = 1;
        card_type = "MASTERCARD\n";
    }
    else if (first_two > 39 && first_two < 50)
    {
        cc_first_two_valid = 1;
        card_type = "VISA\n";
    }
    // Putting it all together, all three of the valid variables must be true for the card to be valid
    if (cc_checksum == 1 && cc_num_digits_valid == 1 && cc_first_two_valid == 1)
    {
        printf("%s", card_type);
    }
    else
    {
        printf("INVALID\n");
    }
}
