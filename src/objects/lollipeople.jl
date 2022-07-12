export Lolli

module Lolli

import Fae: @fum, FractalUserMethod, FractalInput, Colors,
            define_circle, update_circle!,
            define_rectangle, update_rectangle!, Pixels

mutable struct LolliPerson
    head::FractalUserMethod
    eyes::Vector{FractalUserMethod}
    body::FractalUserMethod
    angle::Union{Float32, Float64, FractalInput}
    foot_pos::Union{Tuple{FT}, FractalInput} where FT <: Union{Float32, Float64}
    head_height::Union{Float32, Float64, FractalInput}

    eye_color::FractalUserMethod
    body_color::FractalUserMethod

    transform::Union{Nothing, FractalUserMethod}
    head_transform::Union{Nothing, FractalUserMethod}
    body_transform::Union{Nothing, FractalUserMethod}
end

place_eyes = @fum function place_eyes(x, y;
                                      eye_radius = 0,
                                      eye_angle = 0,
                                      head_position = (0,0),
                                      head_radius = 1,
                                      right_eye = 0)

    y = (y * 2) * head_radius * 0.5 + head_position[1] + eye_radius *
        sin(eye_angle)
    x += head_position[2] + eye_radius * cos(eye_angle) - 
         head_radius * (0.25 - 0.5 * right_eye)

end

function LolliPerson(height; angle=0, foot_pos=(0,0), body_multiplier = 1,
                     eye_color = Colors.white, body_color = Colors.black,
                     head_position = (0,0), head_radius = 1,
                     eye_radius = 0, eye_angle = 0,
                     name = "", AT = Array, diagnostic = true)

    body = define_rectangle((-height, 0), 0, body_multiplier, height,
                            body_color; name = "body"*name,
                            diagnostic = diagnostic, AT = AT)

    head = define_circle((0, 0), 1, body_color;
                         name = "head"*name, diagnostic = diagnostic,
                         AT = AT)

    eyeball = define_circle((0, 0), 1, body_color;
                            name = "head"*name, diagnostic = diagnostic,
                            AT = AT)

    eyes = fee([place_eyes(eye_radius = eye_radius, eye_angle = eye_angle,
                           head_position = head_position,
                           head_radius = head_radius, right_eye = 0),
                place_eyes(eye_radius = eye_radius, eye_angle = eye_angle,
                           head_position = head_position,
                           head_radius = head_radius, right_eye = 1)])

    return LolliPerson(head, [eyeball, eyes], body, angle,
                       foot_pos, height, eye_color,
                       body_color, nothing, nothing, nothing)
    
end

function render_lolli(lolli::LolliPerson, head_smear, eye_smear, body_smear,
                      num_particles, num_iterations, bounds, res;
                      logscale = false, AT = Array, FT = Float32,
                      num_ignore = 20, diagnostic = false, numthreads = 256,
                      numcores = 4)
    pix = Pixels(res; AT = AT, FT = FT, logscale = logscale)

    render_lolli!(pix, lolli, head_smear, eye_smear, body_smear,
                  num_particles, num_iterations, bounds, res;
                  AT = AT, FT = FT, num_ignore = num_ignore, 
                  diagnostic = diagnostic, numthreads = numthreads,
                  numcores = numcores)

    return pix
end

function render_lolli!(pix::Pixels, lolli::LolliPerson, head_smear, eye_smear,
                       body_smear, num_particles, num_iterations, bounds;
                       AT = Array, FT = Float32, num_ignore = 20,
                       diagnostic = false, numthreads = 256, numcores = 4)

    fractal_flame!(pix, lolli.body, body_smear, num_particles, num_iterations,
                   bounds, res; AT = AT, FT = FT, diagnostic = diagnostic,
                   num_ignore = num_ignore, numthreads = numthreads,
                   numcores = numcores)

    fractal_flame!(pix, lolli.head, head_smear, num_particles, num_iterations,
                   bounds, res; AT = AT, FT = FT, diagnostic = diagnostic,
                   num_ignore = num_ignore, numthreads = numthreads,
                   numcores = numcores)

    final_eyes = fee([lolli.eyes[2:end]..., eye_smear]; final = true,
                     diagnostic = diagnostic)
    fractal_flame!(pix, lolli.eyes[1], final_eyes,
                   num_particles, num_iterations,
                   bounds, res; AT = AT, FT = FT, diagnostic = diagnostic,
                   num_ignore = num_ignore, numthreads = numthreads,
                   numcores = numcores)
end

# This brings a lolli from loc 1 to loc 2
# 1. Changes fis
# 2. adds smears for body / head
function step!(lolli::LolliPerson, loc1, loc2, time)
end

# This adds quotes above a lolli head and bounces them up and down
# 1. we need some way of syncing the end of a bounce to the end "time"
#    IE, if the bounce is 2pi, but a T is 3.5 periods, we need to round
function speak!(lolli::LolliPerson, head_angle, time)
end

# This creates an exclamation mark over a lolli head
function exclaim!(lolli::LolliPerson, head_angle, time)
end

# This creates a question mark over a lolli head
function question!(lolli::LolliPerson, head_angle, time)
end

# This creates a heart over the lollihead
function love!(lolli::LolliPerson, head_angle, time)
end

# This makes a lolliperson seem drowsy
function nod_off!(lolli::LolliPerson, time)
end

# This causes a LolliPerson to blink. Should be used on a regular interval
function blink!(lolli::LolliPerson, time)
end
end
