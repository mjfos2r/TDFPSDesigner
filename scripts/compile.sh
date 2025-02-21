#!/bin/sh

nvcc -std=c++11 \
	-o ../bin/CalDTWDistMatrixMNSigroot \
	../cuda/CalDTWDistMatrixMNSigroot.cu \
	-Xcompiler \
	-fopenmp \
	-arch=sm_86 \
	-gencode=arch=compute_86,code=sm_86

nvcc -std=c++11 \
	-o ../bin/CalDTWDistMatrixMN \
	../cuda/CalDTWDistMatrixMN.cu \
	-Xcompiler \
	-fopenmp \
	-arch=sm_86 \
	-gencode=arch=compute_86,code=sm_86

nvcc -std=c++11 \
	-o ../bin/FpsCudaDTWThreshold \
	../cuda/FpsCudaDTWThreshold.cu \
	-Xcompiler \
	-fopenmp \
	-arch=sm_86 \
	-gencode=arch=compute_86,code=sm_86

echo compile  finished!
