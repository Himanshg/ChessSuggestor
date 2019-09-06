main: chess.cu
	nvcc -arch=sm_35 -rdc=true chess.cu -o chess
