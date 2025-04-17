using Lux, StableRNGs
using PEtabSciMLTestsuite: save_ps, save_io, write_yaml

nn_model = @compact(
    layer1 = Conv((5, 5, 5), 3 => 4; cross_correlation = true),
    layer2 = Conv((5, 5, 5), 4 => 1; cross_correlation = true),
    norm1 = BatchNorm(3),
    norm2 = BatchNorm(4)
) do x
    embed = norm1(x)
    embed = layer1(embed)
    embed = norm2(embed)
    out = layer2(embed)
    @return out
end

# TODO: Issue on Float64 input required
input_order_jl, input_order_py = ["W", "H", "D", "C", "N"], ["N", "C", "D", "H", "W"]
output_order_jl, output_order_py = ["W", "H", "D", "C", "N"], ["N", "C", "D", "H", "W"]
dirsave = joinpath(@__DIR__, "..")
for i in 1:3
    rng = StableRNG(i)
    ps, st = Lux.setup(rng, nn_model)
    input = rand(rng, Float32, 12, 11, 10, 3, 2)
    output = nn_model(input, ps, st)[1]
    save_ps(dirsave, i, nn_model, ps)
    save_io(dirsave, i, input, input_order_jl, input_order_py, :input)
    save_io(dirsave, i, output, output_order_jl, output_order_py, :output)
end
write_yaml(dirsave, input_order_jl, input_order_py, output_order_jl, output_order_py)
