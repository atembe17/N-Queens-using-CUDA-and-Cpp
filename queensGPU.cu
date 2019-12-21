#include <iostream>
#include<cuda.h>
#include <cuda_runtime_api.h>
#include <vector>
#include "common.h"
#include <device_launch_parameters.h>

//Method which takes each precalculated CPU board setting as the input
//Returns the solution till the boeard size
__device__ uint32_t solveGPURecursion(const int N, const int depth = 0, const uint32_t left_neg = 0, const uint32_t mid = 0, 
	const uint32_t right_pos = 0) {
	if (depth == N) {
		return 1;
	}
	uint32_t sum = 0;
	for (uint32_t pos = (((uint32_t)1 << N) - 1) & ~(left_neg | mid | right_pos); pos; pos &= pos - 1) {
		uint32_t bit = pos & -pos;
		sum += solveGPURecursion(N, depth + 1, (left_neg|bit) << 1, mid | bit, (right_pos|bit) >> 1);
	}
	return sum;
}

//Kernel method where each thread index holds the precalcuated board arrangement upto a certain depth
__global__ void NQueenKernel(const int N, const int depth, const uint32_t* const left_vec,const uint32_t* const mid_vec,const uint32_t* const right_vec,
	uint32_t* const result_vec,
	const size_t size) {
	int tid = threadIdx.x + blockIdx.x * blockDim.x;
	if (tid < size) {
		result_vec[tid] = solveGPURecursion(N, depth, left_vec[tid], mid_vec[tid], right_vec[tid]);
	}
}

//Class declared to precalculate board setting through CPU and load the blocking diagonals and columns 
//till depth using vectors (dynamic arrays).
class NQueenCPU {
public:
	std::vector<uint32_t> left_vec, mid_vec, right_vec;
	void precalculate(int N,int M, uint32_t ex1, uint32_t ex2, int depth = 0, uint32_t left = 0, uint32_t mid = 0, uint32_t right = 0) {
		if (depth == M) {
			left_vec.push_back(left);
			mid_vec.push_back(mid);
			right_vec.push_back(right);
			return;
		}
		for (uint32_t pos = (((uint32_t)1 << N) - 1) & ~(left | mid | right | ex1); pos; pos &= pos - 1) {
			uint32_t bit = pos & -pos;
			precalculate(N, M, ex2, 0, depth + 1, (left | bit) << 1, mid | bit, (right | bit) >> 1);
			ex2 = 0;
		}
	}
};

//Helper method to allocate and copy memory for the kernel launch
uint64_t QueenGPU(const int N, const int depth) {
	NQueenCPU nqe;
	uint32_t excl = (1 << ((N / 2) ^ 0)) - 1;
	//Calculate board solution upto depth
	nqe.precalculate(N, depth,excl, N % 2 ? excl : 0);
	//Size of precalculated board combinations
	const size_t length = nqe.left_vec.size();
	//Vectors storing the blocking diagonals and columns
	uint32_t* left_d_vec;
	uint32_t* mid_d_vec;
	uint32_t* right_d_vec;
	uint32_t sum = 0;
	//Allocate memory 
	cudaMalloc((void**)&left_d_vec, sizeof(uint32_t) * length);
	cudaMalloc((void**)&mid_d_vec, sizeof(uint32_t) * length);
	cudaMalloc((void**)&right_d_vec, sizeof(uint32_t) * length);
	//Variable to store the solution count
	uint32_t* result_device;
	std::vector<uint32_t> result(length);
	cudaMalloc((void**)&result_device, sizeof(uint32_t) * length);
	cudaMemcpy(left_d_vec, nqe.left_vec.data(), sizeof(uint32_t) * length, cudaMemcpyHostToDevice);
	cudaMemcpy(mid_d_vec, nqe.mid_vec.data(), sizeof(uint32_t) * length, cudaMemcpyHostToDevice);
	cudaMemcpy(right_d_vec, nqe.right_vec.data(), sizeof(uint32_t) * length, cudaMemcpyHostToDevice);
	//No of threads per block
	const int threadsPerBlock = 16;
	//No of blocks depends on length (No of precalculated combinations) 
	const int noBlocks = (length + threadsPerBlock - 1) / threadsPerBlock;
	//Invoke the kernel
	NQueenKernel << <noBlocks, threadsPerBlock >> > (N, depth, left_d_vec, mid_d_vec, right_d_vec, result_device, length);
	cudaMemcpy(result.data(), result_device, sizeof(uint32_t) * length, cudaMemcpyDeviceToHost);
	//Iterate through each resut vector
	for (size_t i = 0; i < length; ++i) 
		sum += result[i];
	//Free the memory
	cudaFree(mid_d_vec);
	cudaFree(left_d_vec);
	cudaFree(result_device);
	cudaFree(right_d_vec);
	return sum;
}
