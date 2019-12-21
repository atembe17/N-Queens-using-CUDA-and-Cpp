# N-Queens-using-CUDA-and-Cpp
N-Queens solution algorithm implementation using CUDA and C++. 
The algorithm uses traditional backtracking approach to solve N-queens problem in CUDA and C++.
Due to chess board symmetry along the y-axis, only half number of solutions are computed in CUDA for a N size board.
In case of GPU implementation, the solutions are precalculated using CPU upto a certain depth. These solutions are then indexed using CUDA threads to further calculate the solutions for the remaining board size.
Due to highly recursive calls, the GPU is unable to predetermine the thread stack size. Hence for devices with low memory, the solution count is 0 for board size (N) > 15. This issue does not exist for devices with large memory such as Tesla K-80.
A significant speedup is observed by CPU+GPU combined over CPU alone for board sizes (N) > 12.
