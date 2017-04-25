# Jeremy Castagno
# K Means
import cv2
import numpy as np
from itertools import izip, count
import time


IMG_TRAIN = 'mandrill-small.tiff'
IMG_FROM = 'mandrill-large.tiff'
IMG_TO = 'mandrill-large-reduced-python.tiff'


def write_img(img_data, name):
    """ Helper function to write image data"""
    cv2.imwrite(name, np.rint(img_data).astype('uint8'))

def initial_groups(img_data, k_num):
    """ Simple initialization of color groups from random pixels"""
    rows = img_data.shape[0]
    cols = img_data.shape[1]
    means = np.zeros((k_num, 3))

    rand_rows = np.random.randint(rows, size=k_num)
    rand_cols = np.random.randint(cols, size=k_num)
    for i, row, col in izip(count(), rand_rows, rand_cols):
        means[i] = img_data[row, col]
    return means


def k_means(img_data, k_num=16, order=2):
    """ Performs K-means clustering"""

    means = initial_groups(img_data, k_num)
    rows = img_data.shape[0]
    cols = img_data.shape[1]

    k_groups = assign_groups(np.zeros((rows, cols)), img_data, means, k_num)

    loop_num = 0

    while loop_num < 5:
        means = gen_means(means, img_data, k_groups, k_num)
        k_groups = assign_groups(k_groups, img_data, means, k_num)

        loop_num += 1
        print('Iteration: {:d}'.format(loop_num))
        # print(means)
    return (means, k_groups)

def gen_means(means, img_data, k_groups, k_num):
    # means = np.zeros((k_num, 3))
    for i in range(k_num):
        mask = k_groups == i        # boolean mask where only pixels belonging to color group
        pixels = img_data[mask]     # retruns only the pixels
        means[i] = np.mean(pixels, axis=0)  # Gets the mean of the pixels colors
    return means


def reduce_img(means, k_groups, img_data):
    k_num = means.shape[0]
    for i in range(k_num):
        mask = k_groups == i        # boolean mask where only pixels belonging to color group
        img_data[mask] = means[i]
    return img_data

def assign_groups(k_groups, img_data, means, k_num):
    rows = img_data.shape[0]
    cols = img_data.shape[1]

    # k_groups = np.zeros((rows, cols))
    # Loop through each row
    for row in range(rows):
        # Loop through each col
        for col in range(cols):
            min_idx = 0
            min_val = 100000000.0
            # Loop through each Color Group
            for group in range(k_num):
                # Measure the distance from the group mean
                dist = np.linalg.norm(means[group] - img_data[row, col], 2)
                if dist < min_val:
                    min_val = dist
                    min_idx = group
            # Assign pixel to group
            k_groups[row, col] = min_idx
    return k_groups


def main():
    """ Main Function execution """
    k_num = 16
    # Read in training image
    img_train = cv2.imread(IMG_TRAIN).astype('float64')
    # Perform K-means cluster, get means, and groups
    print("Starting K-Means\n")
    start_time = time.time()
    (means, _) = k_means(img_train)
    print('Finished. Elapsed Time: {:.2f}'.format(time.time() - start_time))
    # Read in larger image we wish to compress
    print('Compressing Larger Image...')
    img_from = cv2.imread(IMG_FROM).astype('float64')
    # Use previously found means to assign groups for this image
    img_groups = assign_groups(np.zeros((img_from.shape[0], img_from.shape[1])), img_from, means, k_num)
    # Reduce Image by replacing every pixel in the group with its mean
    reduced_image = reduce_img(means, img_groups, img_from)
    write_img(reduced_image, IMG_TO)
    # print('Final Color Group Means: ')
    # print(means)



# Determine K Color Groups
# Initialize Color Group by selecting K random pixels

# Loop Starts
#   Assign each pixel to each color group based on lowest distance metric to group mean
#   Re-evaluate means
#   Check if assignments have changed, if not, re loop
# End Loop

if __name__ == '__main__':
    main()
