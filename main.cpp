#include<iostream>
#include "common.h"
#include <ctime> // time(), clock()


long double calculateError(uint64_t,uint64_t);
const int ITERS = 1;

int main() {
	// Timing data  
	float tcpu, tgpu;  
	clock_t start, end; 
	uint64_t solGPU, solCPU;
	int size;
	//Enter the size of chess board
	std::cout << "Enter the size of the board" << std::endl;
	std::cin >> size;
	//Start the clock
	start = clock(); 
	uint32_t excl = (1 << ((size / 2) ^ 0)) - 1;
	for (int i = 0; i < ITERS; i++) {
		//Find CPU solutions
		solCPU = QueenCPU(size, 0, 0, 0, 0);
	}
	std::cout << "No of solutions by CPU are " << solCPU << std::endl;
	end = clock();
	//Find the CPU time
	tcpu = (float)(end - start) * 1000 / (float)CLOCKS_PER_SEC / ITERS;
	std::cout << "CPU time (ms): " << tcpu << std::endl;
	start = clock();
	for (int i = 0; i < ITERS; i++) {
		//Find the GPU solution
		solGPU = QueenGPU(size, 4)<<1;
	}
	std::cout << "No of solutions by CPU and GPU are " << solGPU << std::endl;
	end = clock();
	//Find the GPU time
	tgpu = (float)(end - start) * 1000 / (float)CLOCKS_PER_SEC / ITERS;
	std::cout << "GPU time (ms): " << tgpu << std::endl;
	std::cout << "Performance Speedup= " << tcpu / tgpu << std::endl;
	std::cout << "The error count between CPU and GPU solutions is " << calculateError(solGPU, solCPU) << std::endl;;
	return 0;
}

//Method to calculate error between CPU and GPU solutions
long double calculateError(uint64_t solGPU, uint64_t solCPU) {
	long double err = solCPU - solGPU;
	err = abs(err);
	return err;
}