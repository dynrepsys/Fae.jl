export Colors, create_color

module Colors

import Fae.@fum

previous = @fum function previous()
end

custom = @fum function custom(; red = 0, green = 0, blue = 0, alpha = 0)
    red = red
    green = green
    blue = blue
    alpha = alpha
end

red = @fum function red()
    red = 1
    green = 0
    blue = 0
    alpha = 1
end

green = @fum function green()
    red = 0
    green = 1
    blue = 0
    alpha = 1
end

blue = @fum function blue()
    red = 0
    green = 0
    blue = 1
    alpha = 1
end

magenta = @fum function magenta()
    red = 1
    green = 0
    blue = 1
    alpha = 1
end
end

create_color(a::FractalUserMethod) = a

function create_color(a::Union{Array, Tuple, RGB, RGBA})
    if isa(a, Array) || isa(a, Tuple)
        if length(a) == 3
            choice = "_" * string(round(a[1]; digits=4))*
                           string(round(a[2]; digits=4))*
                           string(round(a[3]; digits=4))
            choice = replace(choice, "." => "_")
            return Colors.custom(red = a[1],
                                 green = a[2],
                                 blue = a[3],
                                 alpha = 1, name = choice)
        elseif length(a) == 4
            if a[4] > 0
                choice = "_" * string(round(a[1]; digits=4))*
                               string(round(a[2]; digits=4))*
                               string(round(a[3]; digits=4))*
                               string(round(a[4]; digits=4))
                choice = replace(choice, "." => "_")
                return Colors.custom(red = a[1],
                                     green = a[2],
                                     blue = a[3],
                                     alpha = a[4], name = choice)
            else
                return Colors.previous
            end
        else
            error("Colors must have either 3 or 4 elements!")
        end
    elseif isa(a, RGB)
        choice = "_" * string(round(a.r; digits=4))*
                       string(round(a.g; digits=4))*
                       string(round(a.b; digits=4))
        choice = replace(choice, "." => "_")
        return Colors.custom(red = a.r,
                             green = a.g,
                             blue = a.b,
                             alpha = 1, name = choice)
    elseif isa(a, RGBA)
        choice = "_" * string(round(a.r; digits=4))*
                       string(round(a.g; digits=4))*
                       string(round(a.b; digits=4))*
                       string(round(a.alpha; digits=4))
        choice = replace(choice, "." => "_")
        if a.alpha > 0
            return Colors.custom(red = a.r,
                                 green = a.g,
                                 blue = a.b,
                                 alpha = a.alpha, name = choice)
        else
                return Colors.previous
        end
    else
        error("Element " * string(i) * " of color array is a " *
              string(typeof(a)) *
              " which cannot be converted to Fractal User Method!")
    end
end

