using Images, FileIO
using FixedPointNumbers

function initial_means(img_data, k_num)
    return rand(img_data, k_num)
end

function update_groups!(k_groups, img_data, means)
    for iter in eachindex(img_data)
        min_idx = 1
        min_val = 1000.0 # Marking this as float made a big difference as well
        for i = 1:16
            dist = norm(means[i] - img_data[iter])
            if dist < min_val
                min_val = dist
                min_idx = i
            end
        end
        k_groups[iter] = min_idx
        # This was the previous code that was not optimal and had a lot of gc
        # Got 2x speedup by refactoring to above
        # local distance = norm.(means .- img_data[iter])
        # _, idx = findmin(distance)
        # k_groups[iter] = idx
    end
end

function update_means!(means, img_data, k_groups, k_num::Int64)
    # means = Array(RGB{Float64}, k_num)
    for i = 1:k_num
        mask = k_groups .== i
        pixels = img_data[mask]
        means[i] = mean(pixels)
    end
end

function k_means(img_data, k_num)
    means = initial_means(img_data, k_num)
    k_groups = Array(Int64, (size(img_data, 1), size(img_data,2)))
    update_groups!(k_groups, img_data, means)
    loop_num = 0
    while loop_num < 5
        update_means!(means, img_data, k_groups, k_num)
        update_groups!(k_groups,img_data, means)
        loop_num += 1
        print("Iteration $loop_num \n")
    end
    return means
end

function reduce_image!(img2, means, k_groups, k_num)
    for i = 1:k_num
        mask = k_groups .== i
        img2[mask] = means[i]
    end
end
## Main script here....
srand(1234)  # random seed
const k= 16  # How many clusters in k-means

# Load Images, Small Mandrill and large Mandrill
img1_ = load("mandrill-small.tiff")
img2_ = load("mandrill-large.tiff")
# Convert the images to float values and assign with const
const img = float64.(img1_)  # convert to float 64
const img2 = float64.(img2_)

# Perform K Means
means = k_means(img, k)

# Use the Means to compress the larger madrill picture
groups = Array(Int64, (size(img2, 1), size(img2,2)))
update_groups!(groups, img2, means)
reduce_image!(img2, means, groups, k)
save("mandrill-large-reduced-julia.tiff", img2)
