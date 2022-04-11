## words starting with q, x, y or z, words less than 4 characters long, words greater than 18 characters long excluded
## Rest are split by first letter, then add the ascii value of each letter and devide by 26 to see where they end up

d = {}

# open words_alpha.txt
with open('/workspaces/24396811/speller/dictionaries/large') as f:
    for line in f:
        word = line.strip()
        # if length of word is greater than 3 and less than 19
        if len(word) > 3 and len(word) < 19:
            ## sum ascii values of all letters in word
            sum = 0
            for i in range(len(word)):
                for j in range(len(word[i:])):
                    sum += ord(word[j])
            # divide sum by 3 rounded to nearest integer plus word[0]-a
            sum = int((sum / 3) + ord(word[0]) - 380)
            # key is sum, value is incremented by 1
            d[sum] = d.get(sum, 0) + 1


## print each key-value pair to a file called buckettest1.txt
for key, value in d.items():
    print(key, value, file=open('dictionaryLargetest.txt', 'a'))