
disp('Compiling MEX file MULTEMMat')
mex -g -largeArrayDims -IGeneral -I/opt/cuda/include ...
      Multislice' Code'/MULTEMMat.cu ...
      General/hAtomTypesGPU.cu  ...
      General/hDetectorGPU.cu ...
      General/hgeneralGPU.cu ...
      General/hIncidentWaveGPU.cu ...
      General/hMicroscopeEffectsGPU.cu ...
      General/hMulSliGPU.cu ...
      General/hPotentialConv.cu ...
      General/hPotentialGPU.cu ...
      General/hTEMIm.cu ...
      General/hAtomicData.cpp ...
      General/hCrystalCPU.cpp ...
      General/hfegCPU.cpp ...
      General/hfxegTabData.cpp ...
      General/hfxgCPU.cpp ...
      General/hgeneralCPU.cpp ...
      General/hGridCPU.cpp ...
      General/hMatlab2Cpp.cpp ...
      General/hPotentialCPU.cpp ...
      General/hQuadrature.cpp ...
      General/hrhorCPU.cpp ...
      General/hSpecimenCPU.cpp

disp('Compiling MEX file CreateCrystalbyLayers')
mex -g -largeArrayDims -IGeneral -I/opt/cuda/include ...
    Build' Crystal'/CreateCrystalbyLayers.cpp ...
    General/hCrystalCPU.cpp ...
    General/hMatlab2Cpp.cpp ...
