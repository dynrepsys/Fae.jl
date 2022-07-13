using Fae, CUDA

function main(num_particles, num_interactions, AT)
    FT = Float32

    # Physical space location. 
    bounds = [-4.5 4.5; -8 8]*0.15

    # Pixel grid
    res = (1080, 1920)
    pix = Pixels(res; AT = AT, logscale = false, FT = FT)

    lolli = Lolli.LolliPerson(2.0)

    Lolli.render_lolli!(pix, lolli,
                        num_particles, num_interactions, bounds, res;
                        AT = AT, FT = FT)

    filename = "out.png"
    write_image([pix], filename)
end
