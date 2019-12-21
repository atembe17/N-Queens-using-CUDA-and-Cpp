#include <stdint.h>

//Method to invoke CPU implementation
uint64_t QueenCPU(const int, const int, const uint64_t, const uint64_t, const uint64_t);
//Method to invoke GPU implementation
unsigned long long QueenGPU(const int, const int);