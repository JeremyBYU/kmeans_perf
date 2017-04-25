using Images, FileIO
using FixedPointNumbers

function initial_means(img_data, k_num)
    return rand(img_data, k_num)
end

function update_groups!(k_groups, img_data, means)
    for iter in eachindex(img_data)
        distance = norm.(means .- img_data[iter])
        _, idx = findmin(distance)
        k_groups[iter] = idx
    end
    return k_groups
end

function update_means!(means, img_data, k_groups, k_num)
    # means = Array(RGB{Float64}, k_num)
    for i = 1:k_num
        mask = k_groups .== i
        pixels = img_data[mask]
        means[i] = mean(pixels)
    end
    return means
end

function k_means(img_data, k_num)
    prev_means = initial_means(img_data, k_num)
    k_groups = Array(Int64, (size(img_data, 1), size(img_data,2)))
    k_groups = update_groups!(k_groups, img_data, prev_means)
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
k = 16

img = load("mandrill-small.tiff")
img2 = load("mandrill-large.tiff")
img = float64.(img)  # convert to float 64
img2 = float64.(img2)

# Perform K Means
means = k_means(img, k)

groups = assign_groups(img2, means)

reduce_image!(img2, means, groups, k)
save("test.tiff", img2)
