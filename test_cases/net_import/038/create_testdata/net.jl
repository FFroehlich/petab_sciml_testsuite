using Lux, StableRNGs
using PEtabSciMLTestsuite: save_ps, save_io, write_yaml

nn_model = @compact(
    layer1 = Dense(2, 5),
    layer2 = Dense(5, 1),
) do x
    embed = layer1(x)
    embed = elu.(embed)
    out = layer2(embed)
    out .= elu.(out, 2.0)
    @return out
end

input_order_jl, input_order_py = ["W"], ["W"]
output_order_jl, output_order_py = ["W"], ["W"]
dirsave = joinpath(@__DIR__, "..")
for i in 1:3
    rng = StableRNG(i)
    ps, st = Lux.setup(rng, nn_model)
    input = rand(rng, Float32, 2)
    output = nn_model(input, ps, st)[1]
    save_ps(dirsave, i, nn_model, ps)
    save_io(dirsave, i, input, input_order_jl, input_order_py, :input)
    save_io(dirsave, i, output, output_order_jl, output_order_py, :output)
end
write_yaml(dirsave, input_order_jl, input_order_py, output_order_jl, output_order_py)
