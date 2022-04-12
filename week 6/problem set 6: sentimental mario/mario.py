# TODO
from cs50 import get_int

# Prompt user for height, reprompt if not a positive int between 1 and 8

while True:
    height = get_int("Height: ")
    if height > 0 and height < 9:
        break

# Each half pyramid should have a space of 2 between them
# Lowest level should have no spaces before the 1st # or after the last #
for i in range(height):
    print(" " * (height - i-1), end="")
    print("#" * (i+1), end="  ")
    print("#" * (i+1))
