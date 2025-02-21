#!/bin/sh
echo "Currently in: $(pwd)"

nvcc -std=c++11 \
	-o bin/CalDTWDistMatrixMNSigroot \
	cuda/CalDTWDistMatrixMNSigroot.cu \
	-Xcompiler \
	-fopenmp \
	-arch=sm_86

nvcc -std=c++11 \
	-o bin/CalDTWDistMatrixMN \
	cuda/CalDTWDistMatrixMN.cu \
	-Xcompiler \
	-fopenmp

nvcc -std=c++11 \
	-o bin/FpsCudaDTWThreshold \
	cuda/FpsCudaDTWThreshold.cu \
	-Xcompiler \
	-fopenmp

echo "compile finished!"
