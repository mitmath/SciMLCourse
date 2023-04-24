using PackageCompiler
create_sysimage(["DifferentialEquations"], sysimage_path="DiffEqSysImage.so")
using DifferentialEquations