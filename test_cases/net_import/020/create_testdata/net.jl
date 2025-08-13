using Lux, StableRNGs
using PEtabSciMLTestsuite: save_ps, save_io, write_yaml

nn_model = @compact(layer1=Dense(10, 2),
    drop=AlphaDropout(0.5f0)) do x
    x1 = drop(x)
    out = layer1(x1)
    @return out
end

input_order_jl, input_order_py = ["W"], ["W"]
output_order_jl, output_order_py = ["W"], ["W"]
dirsave = joinpath(@__DIR__, "..")
for i in 1:3
    rng = StableRNG(i)
    ps, st = Lux.setup(rng, nn_model)
    input = rand(rng, Float32, 10)
    output = zeros(Float32, 2)
    for _ in 1:50000
        _output, st = nn_model(input, ps, st)
        output += _output
    end
    output ./= 50000
    save_ps(dirsave, i, nn_model, :net0, ps)
    save_io(dirsave, i, input, input_order_jl, input_order_py, :input)
    save_io(dirsave, i, output, output_order_jl, output_order_py, :output)
end
write_yaml(dirsave, input_order_jl, input_order_py,
    output_order_jl, output_order_py; dropout = true)
