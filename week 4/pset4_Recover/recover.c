#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

// Function prototypes
int jpeg_open_close (int count);

typedef uint8_t BYTE;
char jpeg_name_buffer[8];
FILE *jpeg_name;

int main(int argc, char *argv[])
{
    // Program should only have one argument
    if (argc != 2)
    {
        printf("Usage: ./recover IMAGE\n");
        return 1;
    }

    // Open the memory card raw data
    FILE *card_raw = fopen(argv[1], "r");
    // Make sure we were able to open the file
    if (card_raw == NULL)
    {
        printf("Could not open file %s.\n", argv[1]);
        return 1;
    }

    // We'll be using 512 byte chunks of data repeatedly so making a variable to make things easier
    const int BLOCK_SIZE = 512;

    // Creating a buffer for fread/fwrite to use
    BYTE buffer[BLOCK_SIZE];

    // Setting a variable we can increment so that we'll know what we should name the next .jpg file
    int jpeg_count = 0;

    // Since we're reading the file in 512 byte chunks fread should return either 512 or 0 allowing us to know when to end while
    while (fread(buffer, sizeof(BYTE), BLOCK_SIZE, card_raw) == BLOCK_SIZE)
    {
        if (buffer[0] == 0xff && buffer[1] == 0xd8 && buffer[2] == 0xff && (buffer[3] & 0xf0) == 0xe0)
        {
            // Helper function to handle opening and closing .jpg files
            if (jpeg_open_close(jpeg_count) > 0)
            {
                fclose(jpeg_name);
                fclose(card_raw);
                return 2;
            }
            jpeg_count++;

            // Now that a file is opened we need to write to it
            if (fwrite (buffer, sizeof(BYTE), BLOCK_SIZE, jpeg_name) != BLOCK_SIZE)
            {
                printf("Error writing file.\n");
                fclose(jpeg_name);
                fclose(card_raw);
                return 3;
            }
        }
        else
        {
            // Lets make sure a file is open
            if (jpeg_count > 0)
            {
                if (fwrite (buffer, sizeof(BYTE), BLOCK_SIZE, jpeg_name) != BLOCK_SIZE)
                {
                    printf("Error writing file.\n");
                    fclose(jpeg_name);
                    fclose(card_raw);
                    return 4;
                }
            }
        }
    }
    fclose(card_raw);
    fclose(jpeg_name);
    return 0;
}


int jpeg_open_close (int count)
{
// Is this our first jpeg?
    if (count == 0)
    {
        sprintf(jpeg_name_buffer, "%03i.jpg", count);
        jpeg_name = fopen(jpeg_name_buffer, "a");
        if (jpeg_name == NULL)
        {
            return 1;
        }
    }
    else
    {
        // Not the first .jpg so we need to close the current .jpg
        fclose(jpeg_name);

        // Create next file name.
        sprintf(jpeg_name_buffer, "%03i.jpg",count);

        // Open new file
        jpeg_name = fopen(jpeg_name_buffer, "a");
        if (jpeg_name == NULL)
        {
            return 1;
        }
    }
    return 0;
}