# TODO
from cs50 import get_string
from sys import exit


text = get_string("Text: ")

letters = 0
words = len(text.split())
sentences = text.count("?") + text.count(".") + text.count("!")

for letter in text:
    if letter.isalpha():
        letters += 1

# Coleman-Liau index is computed as 0.0588 * L - 0.296 * S - 15.8
# L is the average number of letters per 100 words in the text
# S is the average number of sentences per 100 words in the text.

L = (letters / words) * 100
S = (sentences / words) * 100
index = 0.0588 * L - 0.296 * S - 15.8
if index < 1:
    print("Before Grade 1")
elif index > 16:
    print("Grade 16+")
else:
    print(f"Grade {round(index)}")
