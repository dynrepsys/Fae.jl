using Fae, Images, CUDA

if has_cuda_gpu()
    using CUDAKernels
    CUDA.allowscalar(false)
end

AT = CuArray
FT = Float32

frames = 60

f_set = :(U(Fae.swirl, Fae.heart, Fae.rotate, Fae.horseshoe))
color_set = [[0,1,0,1], [0,0,1,1], [1,0,1,1], [1,0,0,1]]
final_fx(x,y) = Fae.polar_play
final_clr = (FT(1.0), FT(0.5), FT(1.0), FT(1.0))
prob_set = (0.25, 0.25, 0.25, 0.25)
#prob_set = (0.33, 0.33, 0.34)

H = Fae.Hutchinson(f_set, color_set, prob_set; AT = AT, FT = FT)

num_particles = 10000
num_iterations = 10000
#num_particles = 10
#num_iterations = 10
#bounds = [-2 2; -2 2]
#res = (1000, 1000)
bounds = [-1.125 1.125; -2 2]
res = (1080, 1920)

filename = "check"*lpad(0,5,"0")*".png"

Fae.fractal_flame(H, num_particles, num_iterations, bounds, res; AT = AT,
                  FT = FT, final_clr = final_clr,
                  filename = filename)
