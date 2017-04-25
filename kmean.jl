using Images, FileIO
using FixedPointNumbers

function initial_means(img_data, k_num)
    return rand(img_data, k_num)
end

function update_groups!(k_groups, img_data, means)
    for iter in eachindex(img_data)
        local distance = norm.(means .- img_data[iter])
        _, idx = findmin(distance)
        k_groups[iter] = idx
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
    while true && loop_num < 500
        update_means!(means, img_data, k_groups, k_num)
        update_groups!(k_groups,img_data, means)
        loop_num += 1
        print("Iteration $loop_num \n")
        # @show means
    end
    return means
end

function reduce_image!(img2, means, k_groups, k_num)
    for i = 1:k_num
        mask = k_groups .== i
        img2[mask] = means[i]
    end
end



srand(1234)
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
save("test.tiff", img2)




k_groups = Array(Int64, (size(img, 1), size(img,2)))
update_groups!(k_groups, img, means)
@time update_means!(means, img, k_groups, k)
