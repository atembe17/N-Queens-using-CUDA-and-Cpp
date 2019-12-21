#include "common.h"

//CPU method to calculate NxN board queens solution
//Uses Backtracking and recursion to find all possible combinations of queen positions on the NxN chess board
uint64_t QueenCPU(const int N,const int depth = 0, const uint64_t left_neg = 0, const uint64_t mid = 0,const uint64_t right_pos = 0) {
	if (depth == N) {
		return 1;
	}
	uint64_t sum_total = 0;
	for (uint64_t pos = (((uint64_t)1 << N) - 1) & ~(left_neg | mid | right_pos); pos; pos &= pos - 1) {
		uint64_t bit = pos & -pos;
		sum_total += QueenCPU(N, depth + 1, (left_neg | bit) << 1, mid | bit, (right_pos | bit) >> 1);
	}
	return sum_total;
}