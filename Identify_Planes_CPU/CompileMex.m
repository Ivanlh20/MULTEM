clc; clear all;
mexCPU(1, 'getPlanes.cpp', '../General_CPU_GPU', 'hQuadrature.cpp'...
    , 'hAtomicData.cpp', 'hPotential_CPU.cpp', 'hMT_General_CPU.cpp'...
    , 'hMT_AtomTypes_CPU.cpp', 'hMT_Slicing_CPU.cpp', 'hMT_Specimen_CPU.cpp');
