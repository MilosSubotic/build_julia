
Pkg.init()

Pkg.add("BinDeps")

Pkg.add("Compat")
Pkg.build("Compat")

Pkg.add("PyCall")

Pkg.add("HDF5")
#Pkg.add("Silo")
Pkg.clone("https://github.com/MilosSubotic/Silo.jl")
Pkg.build("Silo")
using Silo

Pkg.add("FastAnonymous")
Pkg.add("Lumberjack")

Pkg.add("GZip")
Pkg.add("ZipFile")

Pkg.add("PyPlot")
Pkg.add("Winston")
Pkg.add("Gadfly")
Pkg.add("Interact")
Pkg.clone("https://github.com/jverzani/GtkInteract.jl")

Pkg.add("SymPy")

#Pkg.add("DSP")
Pkg.clone("https://github.com/JuliaDSP/DSP.jl")
Pkg.add("Wavelets")
Pkg.clone("https://github.com/JayKickliter/Radio.jl")

Pkg.clone("https://github.com/jlep/Multicombinations.jl")
Pkg.add("Combinatorics")

Pkg.add("Iterators")
Pkg.add("Cartesian")

Pkg.add("Polynomials")
Pkg.add("PowerSeries")

Pkg.add("Roots")
Pkg.clone("https://github.com/JuliaControl/Control.jl")

Pkg.add("Distributions")
Pkg.add("Regression")
Pkg.add("Optim")
Pkg.add("NLopt")
Pkg.add("JuMP")

Pkg.add("Interpolations")

