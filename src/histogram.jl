@inline function find_bin(histogram_output, input,
                          tid, dims, bounds, bin_widths)

    bin = ceil(Int, input[tid, 1] - bounds[1, 1] / bin_widths[1])
    slab = 1

    for i = 2:dims
        slab *= size(histogram_output)[i-1]
        bin += Int(ceil((input[tid, i]-1) - bounds[i, 1] / bin_widths[1])*slab)
    end

    return bin

end

# This a 1D histogram kernel where the histogramming happens on shmem
@kernel function histogram_kernel!(histogram_output, input,
                                   bounds, bin_widths, dims)
    tid = @index(Global, Linear)
    lid = @index(Local, Linear)

    @uniform warpsize = Int(32)

    @uniform gs = @groupsize()[1]
    @uniform N = length(histogram_output)

    shared_histogram = @localmem Int (gs)

    # This will go through all input elements and assign them to a location in
    # shmem. Note that if there is not enough shem, we create different shmem
    # blocks to write to. For example, if shmem is of size 256, but it's
    # possible to get a value of 312, then we will have 2 separate shmem blocks,
    # one from 1->256, and another from 256->512
    @uniform max_element = 1
    for min_element = 1:gs:N

        # Setting shared_histogram to 0
        @inbounds shared_histogram[lid] = 0
        @synchronize()

        # I want to turn this in to an @uniform, but that fails on CPU (#274)
        bin = find_bin(histogram_output, input, tid, dims, bounds, bin_widths)

        max_element = min_element + gs
        if max_element > N + 1
            max_element = N+1
        end

        # Defining bin on shared memory and writing to it if possible
        if bin >= min_element && bin < max_element
            bin -= min_element-1
            atomic_add!(pointer(shared_histogram, bin), Int(1))
        end

        @synchronize()

        if ((lid+min_element-1) <= N)
            atomic_add!(pointer(histogram_output, lid+min_element-1),
                        shared_histogram[lid])
        end

    end

end


function histogram!(histogram_output, input; dims = ndims(histogram_output),
                    bounds = zeros(dims,2),
                    bin_widths = [1 for i = 1:dims],
                    numcores = 4, numthreads = 256)

    AT = Array
    if isa(input, Array)
        kernel! = histogram_kernel!(CPU(), numcores)
    else
        kernel! = histogram_kernel!(CUDADevice(), numthreads)
        AT = CuArray
    end

    kernel!(histogram_output, input, AT(bounds), AT(bin_widths), dims,
            ndrange=size(input)[1])
end
