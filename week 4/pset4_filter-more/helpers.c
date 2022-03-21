#include "helpers.h"
#include <math.h>


// Convert image to grayscale
void grayscale(int height, int width, RGBTRIPLE image[height][width])
{
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            int avg = round((image[i][j].rgbtBlue + image[i][j].rgbtGreen + image[i][j].rgbtRed) / 3.0);
            image[i][j].rgbtBlue = avg;
            image[i][j].rgbtGreen = avg;
            image[i][j].rgbtRed = avg;
        }
    }
    return;
}

// Reflect image horizontally
void reflect(int height, int width, RGBTRIPLE image[height][width])
{
    for (int i = 0; i < height; i++)
    {
        // Creating a blank rgbtriple array to store the contents of a row from image
        RGBTRIPLE row_buffer[1][width];
        // Copying the contents of the current row into row_buffer, width-j is allowing me to perform the swap
        for (int j = 0; j < width; j++)
        {
            row_buffer[0][(width - 1) - j] = image[i][j];
        }
        // Since I swapped the row's values when I copied them into row_buffer I can just swap 1 for 1 when putting them back into image
        for (int k = 0; k < width; k++)
        {
            image[i][k] = row_buffer[0][k];
        }
    }
    return;
}

// Blur image
void blur(int height, int width, RGBTRIPLE image[height][width])
{
    // Create a buffer to store new values while preserving original values
    RGBTRIPLE temp_image[height][width];
    // Loop through rows, then inner loop through columns to examine each pixel individually
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            // Variables to keep track of the avg of each r g b value
            int avg_blue = 0;
            int avg_green = 0;
            int avg_red = 0;
            float num_elements = 0.0;
            // Going to double loop through the 9 appropriate elements
            for (int k = -1; k < 2; k++)
            {
                for (int l = -1; l < 2; l++)
                {
                    if (i + k >= 0 && j + l >= 0 && i + k < height && j + l < width)
                    {
                        avg_blue = avg_blue + image[i + k][j + l].rgbtBlue;
                        avg_green = avg_green + image[i + k][j + l].rgbtGreen;
                        avg_red = avg_red + image[i + k][j + l].rgbtRed;
                        num_elements++;
                    }
                }
            }
            // Now that we have the totals for the rgb values we can get the average and assign it to image[i][j]
            temp_image[i][j].rgbtBlue = round(avg_blue / num_elements);
            temp_image[i][j].rgbtGreen = round(avg_green / num_elements);
            temp_image[i][j].rgbtRed = round(avg_red / num_elements);
        }
    }
    // Now that we have completed the loops and temp_image[][] has our new values, we need to copy them to image[][]
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            image[i][j].rgbtBlue = temp_image[i][j].rgbtBlue;
            image[i][j].rgbtGreen = temp_image[i][j].rgbtGreen;
            image[i][j].rgbtRed = temp_image[i][j].rgbtRed;
        }
    }
    return;
}

// Detect edges
void edges(int height, int width, RGBTRIPLE image[height][width])
{
    // Create a buffer to store new values while preserving original values
    RGBTRIPLE temp_image[height][width];
    // Loop through rows, then inner loop through columns to examine each pixel individually
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            // Variables to keep track of the computed value of each r g b value
            int gxblue = 0;
            int gyblue = 0;
            int gxgreen = 0;
            int gygreen = 0;
            int gxred = 0;
            int gyred = 0;
            // Defining arrays to store Gx and Gy values
            int gx[3][3] = {{-1, 0, 1}, {-2, 0, 2}, {-1, 0, 1}};
            int gy[3][3] = {{-1, -2, -1}, {0, 0, 0}, {1, 2, 1}};
            // Going to double loop through the 9 appropriate elements
            for (int k = -1; k < 2; k++)
            {
                for (int l = -1; l < 2; l++)
                {
                    // Since we multiply any pixels' rgb values by 0 if they aren't on the image we don't need to worry about them.
                    if (i + k >= 0 && j + l >= 0 && i + k < height && j + l < width)
                    {
                        // For valid elements of image[][] we need to get the 3 rgb values, then math them up and store the values in the appropriate gx/gy variable
                        gxblue = gxblue + image[i + k][j + l].rgbtBlue * gx[k + 1][l + 1];
                        gyblue = gyblue + image[i + k][j + l].rgbtBlue * gy[k + 1][l + 1];
                        gxgreen = gxgreen + image[i + k][j + l].rgbtGreen * gx[k + 1][l + 1];
                        gygreen = gygreen + image[i + k][j + l].rgbtGreen * gy[k + 1][l + 1];
                        gxred = gxred + image[i + k][j + l].rgbtRed * gx[k + 1][l + 1];
                        gyred = gyred + image[i + k][j + l].rgbtRed * gy[k + 1][l + 1];
                    }
                }
            }
            // Completed the appropriate elements for the 3x3 box for each pixel, now we need to √(Gx² + Gy²), make sure the result isn't >255, then update temp_image[][]
            temp_image[i][j].rgbtBlue = fmin(round(sqrt(pow(gxblue, 2) + pow(gyblue, 2))), 255);
            temp_image[i][j].rgbtGreen = fmin(round(sqrt(pow(gxgreen, 2) + pow(gygreen, 2))), 255);
            temp_image[i][j].rgbtRed = fmin(round(sqrt(pow(gxred, 2) + pow(gyred, 2))), 255);
        }
    }
    // Now that we have completed the loops and temp_image[][] has our new values, we need to copy them to image[][]
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            image[i][j].rgbtBlue = temp_image[i][j].rgbtBlue;
            image[i][j].rgbtGreen = temp_image[i][j].rgbtGreen;
            image[i][j].rgbtRed = temp_image[i][j].rgbtRed;
        }
    }
    return;
}
