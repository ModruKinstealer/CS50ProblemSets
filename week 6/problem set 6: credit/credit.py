# TODO
from cs50 import get_string
from sys import exit


def main():
    # Prompt user for credit card number
    while True:
        # Saving as a string so we can slice it
        cc = get_string("Number: ")

        # Valid CC numbers are between 13 and 16 digits per specs
        if len(cc) > 12 and len(cc) < 17 and int(cc) > 0 and cc.isnumeric():
            break
        if (len(cc) < 13 or len(cc) > 16) and cc.isnumeric():
            print("INVALID")
            exit(0)

    # Verify if the number provided starts with a valid numbers
    cc_type = cc_start(cc)
    if cc_type == "INVALID":
        print("INVALID")
        exit(0)
    if checksum(cc) != 0:
        print("INVALID")
        exit(0)
    else:
        print(f"{cc_type}")


def checksum(cc_string):
    # The fun of Luhn's Algorithm
    sum = 0
    n = 1
    for i in cc_string[::-1]:
        if n % 2 == 1:
            sum += int(i)
        else:
            digits = int(i)*2
            for j in str(digits):
                sum += int(j)
        n += 1
    return sum % 10
    

def cc_start(cc_string):
    # Check for valid starting numbers
    # Amex starts with 34 or 37, visa with 4, and MC with 51-55
    cc_start_Amex = ["34", "37"]
    cc_start_MC = ["51", "52", "53", "54", "55"]
    if cc_string[:2] in cc_start_Amex:
        return "AMEX"
    if cc_string[:2] in cc_start_MC:
        return "MASTERCARD"
    if cc_string[0] == "4":
        return "VISA"
    return "INVALID"


main()