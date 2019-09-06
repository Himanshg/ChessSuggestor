#include<cuda.h>
#include<stdio.h>
	
#define BOXES 64
#define PIECES 16
#define SIDE 8

__device__ int black[BOXES][PIECES + 1];
__device__ int white[BOXES][PIECES + 1];
__device__ char piece[PIECES + 1][BOXES + 1];
__device__ int piece_pos[PIECES+1];
__device__ volatile unsigned int numBlocks = 0;
__device__ volatile unsigned int numBlocks2 = 0;

__device__ void printBlack(){
	
	printf("black\n");

		for(int i = 0; i < BOXES; i++){
			printf("i: %d ",i);
			for(int j = 0; j <= PIECES; j++){
				if(black[i][j] == 1)
				printf("%d",black[i][j]);
				else
				printf("_");
			}
			printf("\n");
		}
}

__device__ void printWhite(){
		
		printf("white\n");
		
		for(int i = 0; i < BOXES; i++){
			printf("i: %d ",i);
			for(int j = 0; j <= PIECES; j++){
				if(white[i][j] == 1)
				printf("%d",white[i][j]);
				else
				printf("_");
			}
			printf("\n");
		}
}

__device__ void updateDS(int curr_piece, int x, int y, int val){
	
	int row = x*SIDE + y;
	int col = (curr_piece % 100);
	
	if(curr_piece < 100){
		//fill white DS
		white[row][col] = val;				

	} else {
		//fill black DS
		black[row][col] = val;

	}
		
}

__global__ void canAnyoneCome(int row){
	int col = threadIdx.x + 1;
	
	if(threadIdx.x == 0){
		black[row][0] = 0;
		white[row][0] = 0;
	}
	
	if(black[row][col] == 1){
		black[row][0] = 1;
	}
	
	if(white[row][col] == 1){
		white[row][0] = 1;
	}
	
	
}

__global__ void king(int *board, int pos, int turn){
	int id = threadIdx.x;
	if(id < 8 && board[pos] != 0){
		int i = pos/SIDE;
		int j = pos%SIDE;
		int curr_piece = board[pos];
		
		int x=0,y=0;
		int a,b;
		//setting the value of new position
		if(id == 0 || id == 1 || id == 2){
			
			a = -1;
			if(id == 0)
				b = -1;
			else if(id == 2)
				b = 0;
			else
				b = 1;
		
		}else if( id == 3 || id == 4 || id == 5){
			
			a = 1;
			if(id == 3)
				b = -1;
			else if(id == 4)
				b = 0;
			else
				b = 1;
			
		}else{
			a = 0;
			if(id == 6)
				b = -1;
			else
				b = 1;
		
		}
		
		 
		x = i + a;
		y = j + b;
	
		if((x < SIDE && x >= 0) && (y < SIDE && y >= 0)){
		
			updateDS(curr_piece,x,y,0);
		
			int new_piece = board[x*SIDE + y];
			int is_valid = 0;
	
			if(new_piece == 0){
				//place blank -> valid move
				is_valid = 1;
			}else{
				if((curr_piece < 100 && new_piece > 100) || (curr_piece > 100 && new_piece < 100)){
					//opposition here -> valid move
					is_valid = 1;
				}else if(turn == 0 && new_piece < 100 && curr_piece < 100){
					is_valid = 1;
				}else if(turn == 1 && new_piece > 100 && curr_piece > 100){
					is_valid = 1;
				}
			}
			
			if(is_valid)
				updateDS(curr_piece,x,y,1);

		}
	}
}


__global__ void queen(int *board, int pos, int turn){
	int id = threadIdx.x;
	
	if(id < 8 && board[pos] != 0){
		int i = pos/SIDE;
		int j = pos%SIDE;
		int curr_piece = board[pos];
		
		int x=0,y=0;
		int a,b;
		//setting the value of new position
		if(id == 0 || id == 1 || id == 2){
			
			a = -1;
			if(id == 0)
				b = -1;
			else if(id == 2)
				b = 0;
			else
				b = 1;
		
		}else if( id == 3 || id == 4 || id == 5){
			
			a = 1;
			if(id == 3)
				b = -1;
			else if(id == 4)
				b = 0;
			else
				b = 1;
			
		}else{
			a = 0;
			if(id == 6)
				b = -1;
			else
				b = 1;
		
		}
		
		 
		x = i + a;
		y = j + b;
		int flag = 0;	
		
		while((x < SIDE && x >= 0) && (y < SIDE && y >= 0) ){
			
			updateDS(curr_piece,x,y,0);
			
			int new_piece = board[x*SIDE + y];
			int is_valid = 0;
			
			if(new_piece == 0){
				//place blank -> valid move
				is_valid = 1;
			}else{
				if((curr_piece < 100 && new_piece > 100) || (curr_piece > 100 && new_piece < 100)){
					//opposition here -> valid move
					is_valid = 1;
				}else if(turn == 0 && new_piece < 100 && curr_piece < 100){
					is_valid = 1;
				}else if(turn == 1 && new_piece > 100 && curr_piece > 100){
					is_valid = 1;
				}
				flag = 1;
			}
			
			if(is_valid)
				updateDS(curr_piece,x,y,1);
				
			if(flag)
				break;
			else{
				x += a;
				y += b;
			}
		}	
	}
}


__global__ void knight(int *board, int pos, int turn){
	int id = threadIdx.x;
	
	if(id < 8 && board[pos] != 0){
		int i = pos/SIDE;
		int j = pos%SIDE;
		int curr_piece = board[pos];
		
		int x=0,y=0;
		//setting the value of new position
		if(id == 0 || id == 1){
			
			x = i - 2;
			if(id == 0)
				y = j - 1;
			else
				y = j + 1;
		
		}else if( id == 2 || id == 3){
			
			x = i + 2;
			if(id == 2)
				y = j - 1;
			else
				y = j + 1;
			
		}else if( id == 4 || id == 5){
			
			y = j - 2;
			if(id == 4)
				x = i - 1;
			else
				x = i + 1;
			
		}else{
			
			y = j + 2;
			if(id == 6)
				x = i - 1;
			else
				x = i + 1;
		
		}
		
		if((x < SIDE && x >= 0) && (y < SIDE && y >= 0)){
			
			updateDS(curr_piece,x,y,0);
			
			int new_piece = board[x*SIDE + y];
			int is_valid = 0;
			
			if(new_piece == 0){
				//place blank -> valid move
				is_valid = 1;
			}else{
				if((curr_piece < 100 && new_piece > 100) || (curr_piece > 100 && new_piece < 100)){
					//opposition here -> valid move
					is_valid = 1;
				}else if(turn == 0 && new_piece < 100 && curr_piece < 100){
					is_valid = 1;
				}else if(turn == 1 && new_piece > 100 && curr_piece > 100){
					is_valid = 1;
				}
			}
			
			if(is_valid)
				updateDS(curr_piece,x,y,1);
		}
	}
	
}


__global__ void bishop(int *board,int pos, int turn){
	int id = threadIdx.x;
	if( id < 4 && board[pos]!=0 ){
		int i = pos/SIDE;
		int j = pos%SIDE;
		int curr_piece = board[pos];
		
		int x=0,y=0;
		int a,b;
		
		//Assigning Initial Values of position
		if( id == 0 ){
			//For north east pos
			a = -1;
			b = 1;
			
		}else if( id == 1){
			//For north west pos
			a = -1;
			b = -1;
		
		}else if( id == 2){
			//For south east pos 
			a = 1;
			b = 1;
		
		}else if( id == 3){
			//For south west pos
			a = 1;
			b = -1;
		
		}
		x = i + a;
		y = j + b;
		int flag = 0;
		while( (x < SIDE && x >= 0) && (y < SIDE && y >= 0) ){
			
			//printf("thread:%d %d %d\n",id, x, y);
			
			updateDS(curr_piece,x,y,0);
			
			int is_valid = 0;
			int new_piece = board[x*SIDE + y];
			
			if( new_piece == 0){
				//Valid Move
				is_valid = 1;
				
			} else {
				if( (new_piece < 100 && curr_piece > 100) || (new_piece < 100 && curr_piece > 100) ){
					//Valid Move and STOPPING the loop
					is_valid = 1;				
				}else if(turn == 0 && new_piece < 100 && curr_piece < 100){
					is_valid = 1;
				}else if(turn == 1 && new_piece > 100 && curr_piece > 100){
					is_valid = 1;
				}
				flag = 1;
			
			}
			
			if( is_valid )
				updateDS(curr_piece,x,y,1);
				
			if( flag == 1 )
					break;
					
			x+=a;
			y+=b;
		}
	}
}


__global__ void rook(int* board,int pos,int turn){
	int id = threadIdx.x;
	if( id < 4 && board[pos]!=0 )
	{
		int i = pos/SIDE;
		int j = pos%SIDE;
		int curr_piece = board[pos];
		
		int x,y;
		int itr= 1;
		int flag = 0;
		
		//Assigning initial values to x and y
		if( id == 0 ){
			//For left pos
			x = i;
			y = j - itr;
		}else if( id == 1){
			//For right pos
			x = i;
			y = j + itr;
		}else if( id == 2){
			//For upper pos 
			x = i - itr;
			y = j;
		}else if( id == 3){
			//For lower pos
			x = i + itr;
			y = j;
		}
		itr = itr + 1;
		while((x < SIDE && x >= 0) && (y < SIDE && y >= 0) ){
			
			updateDS(curr_piece,x,y,0);
			
			int is_valid = 0;		
			int new_piece = board[x*SIDE + y];
			
			if( new_piece == 0){
				//Valid Move
				is_valid = 1;
			}
			else{
				if( (new_piece < 100 && curr_piece > 100) || (new_piece < 100 && curr_piece > 100) )
				{
					//Valid Move and STOPPING the loop
					is_valid = 1;				
				}else if(turn == 0 && new_piece < 100 && curr_piece < 100){
					is_valid = 1;
				}else if(turn == 1 && new_piece > 100 && curr_piece > 100){
					is_valid = 1;
				}
				flag = 1;
			}
			
			if( is_valid )
				updateDS(curr_piece,x,y,1);
				
			if( flag == 1 )
					break;
			
			//Finding the new position in x and y
			if( id == 0 )
			{
				//For left pos
				x = i;
				y = j - itr;
			}else if( id == 1){
				//For right pos
				x = i;
				y = j + itr;
			}else if( id == 2){
				//For upper pos 
				x = i - itr;
				y = j;
			}else if( id == 3){
				//For lower pos
				x = i + itr;
				y = j;
			}
			itr++;

		}
	}
}
	

__global__ void pawn(int *board,int pos,int turn){
	
	int id  = threadIdx.x;
	
	int i = pos/SIDE;
	int j = pos%SIDE;

	int curr_piece = board[pos];
	
	//x=row y=col of new position 
	
	int x,y;
	
	if(curr_piece > 100){
		x = i+1;
		y = j+(id-1);
		
	}else{
		x = i-1;
		y = j+(id-1);
		
	}
	
	if((x < SIDE && x >= 0) && (y < SIDE && y >= 0)){
		
		updateDS(curr_piece,x,y,0);
		
		int new_piece = board[x*SIDE + y];
		int is_valid = 0;
		if( j == y ){
			//blank in front
			if(new_piece == 0){
				
				//valid move
				if((turn == 0 && curr_piece > 100) || (turn == 1 && curr_piece < 100))
					is_valid = 1;
				
			}
		} else {
			//piece off opposite side
			if(	(new_piece > 100 && curr_piece < 100)||  
				(new_piece < 100 && new_piece != 0 && curr_piece > 100)){
				//valid move
				is_valid = 1;		
			}else if((turn == 0 && curr_piece < 100) ||
					 (turn == 1 && curr_piece > 100)){  //turn of black but piece is white
				is_valid = 1;
			}
			
			
		}
		
		if(is_valid){
			updateDS(curr_piece,x,y,1);
		}
	}  
	
}


__global__ void markUnsafe(int col, int turn){
			
		int row = threadIdx.x;
		
		if(turn == 0){
			if(black[col][row + 1] == 1){
				piece[row+1][col+1] = 'U';
				piece[row+1][0] = 'p';	//moves present
			}
		}else{
			if(white[col][row + 1] == 1){
				piece[row+1][col+1] = 'U';
				piece[row+1][0] = 'p';	//moves present
			}
		}
		
		
}

__global__ void markSafe(int col, int turn){
			
		int row = threadIdx.x;
		
		if(turn == 0){
			if(black[col][row + 1] == 1){
				piece[row+1][col+1] = 'S';
				piece[row+1][0] = 'p';	//moves present
			}
		}else{
			if(white[col][row + 1] == 1){
				piece[row+1][col+1] = 'S';
				piece[row+1][0] = 'p';	//moves present
			}
		}
		
		
}

__global__ void markAttackingUnsafe(int col, int turn){
			
		int row = threadIdx.x;
		
		if(turn == 0){
			if(black[col][row + 1] == 1){
				piece[row+1][col+1] = 'A';
				piece[row+1][0] = 'p';	//moves present
			}
		}else{
			if(white[col][row + 1] == 1){
				piece[row+1][col+1] = 'A';
				piece[row+1][0] = 'p';	//moves present
			}
		}
		
}

__global__ void markAttackingSafe(int col, int turn){
			
		int row = threadIdx.x;
		
		if(turn == 0){
			if(black[col][row + 1] == 1){
				piece[row+1][col+1] = 'X';
				piece[row+1][0] = 'p';	//moves present
			}
		}else{
			if(white[col][row + 1] == 1){
				piece[row+1][col+1] = 'X';
				piece[row+1][0] = 'p';	//moves present
			}
		}
		
		
}


__device__ void markCurrentUnsafe(int *board, int curr_pos){
	
	int row = board[curr_pos] % 100;
	int col = curr_pos + 1;
	
	piece[row][col] = '?';
	
}


__device__ void markCurrentSafe(int *board, int curr_pos){
	int row = board[curr_pos] % 100;
	int col = curr_pos + 1;
	
	piece[row][col] = '#';
}

__global__ void computeMoves(int *board,int turn){
	//pos of a piece
	
	int curr_pos = (blockDim.x * blockIdx.x) + threadIdx.x;
	
	if(curr_pos < BOXES && board[curr_pos] != 0){
		
		//val of a piece
		int curr_piece = board[curr_pos];
		
		//num corresponding piece
		int piece = curr_piece % 100;
		
		switch(piece){
			
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
			case 6:
			case 7:
			case 8:
				pawn<<<1,3>>>(board,curr_pos,turn);
				break;
			
			case 9:
			case 10:
				rook<<<1,4>>>(board,curr_pos,turn);
				break;
			
			case 11:
			case 12:
				knight<<<1,8>>>(board,curr_pos,turn);
				break;
			
			case 13:
			case 14:
				bishop<<<1,4>>>(board,curr_pos,turn);
				break;
			
			case 15:
				queen<<<1,8>>>(board,curr_pos,turn);
				break;
				
			case 16: 
				king<<<1,8>>>(board,curr_pos,turn);
				break;
			
		}
		
	}
	
	__syncthreads();
	//synchronize across all blocks
	
	if(threadIdx.x == 0){
		atomicAdd((unsigned int*)&numBlocks, 1);
	}
	
	while(numBlocks != gridDim.x);
	
	
	/*for all now select the safe moves
	 *
	 *  S=> safe
	 * 	U=> unsafe
	 * 	X=> attacking safe
	 * 	A=> attacking unsafe
	 * 
	 * 	turn
	 * 		0=> black
	 * 		1=> white 
	 * 
	 */ 
	
	
	//which positions black and white can come  
	
	canAnyoneCome<<<1,16>>>(curr_pos);
	if(threadIdx.x == 0){
		atomicAdd((unsigned int *)&numBlocks2, 1);
		numBlocks = 0;
	}
	
	while(numBlocks2 != gridDim.x);
	
	int col = curr_pos;
	
	cudaDeviceSynchronize();
	
	//black turn
	if(turn == 0){
		
		if(board[curr_pos] == 0){
			
			//unsafe if white can come
			if(white[curr_pos][0] == 1){
				//unsafe
				markUnsafe<<<1,16>>>(col,turn);
				
			} else {
				//safe
				markSafe<<<1,16>>>(col,turn);
			}
		}else{
		
			//black can come and not zero means white is there
			//attacking
			if(black[curr_pos][0] == 1){
				
				//if other white can come there
				if(white[curr_pos][0] == 1){
					//unsafe
					markAttackingUnsafe<<<1,16>>>(col,turn);
				} else {
					//safe
					markAttackingSafe<<<1,16>>>(col,turn);
				}

			} else if(board[curr_pos] > 100){ //black is present there
				//if other white can come there
				if(white[curr_pos][0] == 1){
					//unsafe
					markCurrentUnsafe(board,curr_pos);
				} else {
					//safe
					markCurrentSafe(board,curr_pos);
				}
			}
		}
	} else {
		
		if(board[curr_pos] == 0){
			
			//unsafe if black can come
			if(black[curr_pos][0] == 1){
				//unsafe
				markUnsafe<<<1,16>>>(col,turn);
			} else {
				//safe
				markSafe<<<1,16>>>(col,turn);
			}
			
		}else{
			
			//white can come and not zero means black is there
			//attacking
			if(white[curr_pos][0] == 1){
				
				//if other black can come there
				if(black[curr_pos][0] == 1){
					//unsafe
					markAttackingUnsafe<<<1,16>>>(col,turn);
				} else {
					//safe
					markAttackingSafe<<<1,16>>>(col,turn);
				}
			
			} else if(board[curr_pos] < 100){
				
				//if other black can come there
				if(black[curr_pos][0] == 1){
					//unsafe
					markCurrentUnsafe(board,curr_pos);
				} else {
					//safe
					markCurrentSafe(board,curr_pos);
				}
			
			}
			
		}
	}
	
	__syncthreads();
	if(threadIdx.x == 0){
		atomicAdd((unsigned int *)&numBlocks, 1);
		numBlocks2 = 0;
	}
	
	while(numBlocks != gridDim.x);
	
	
	/*
	if(threadIdx.x == 0)
	for(int i=0; i <= PIECES; i++){
		for(int j=0; j <= BOXES; j++){
			printf("%d\t", piece[i][j]);
		}
		printf("\n");
	}
	
	*/
	
	if(turn == 0){
		if(board[curr_pos] > 100){
			int piece = board[curr_pos] %100;
			piece_pos[piece] = curr_pos;
		}
	} else {
		if(board[curr_pos] < 100 && board[curr_pos] != 0){
			int piece = board[curr_pos] %100;
			piece_pos[piece] = curr_pos;
		}
	}
	
	
	__syncthreads();
	if(threadIdx.x == 0){
		atomicAdd((unsigned int *)&numBlocks2, 1);
		numBlocks = 0;
	}
	
	while(numBlocks2 != gridDim.x);
	cudaDeviceSynchronize();
	/*
	if(threadIdx.x == 0)
	for(int i=0; i <= PIECES; i++){
		printf("i:%d ", i);
		for(int j=0; j <= BOXES; j++){
			printf("%c-", piece[i][j]);
		}
		printf("\n");
	}
	
	if(threadIdx.x == 0)
	printf("\n");
	
	if(threadIdx.x == 0)	
	for(int i=0; i <= PIECES; i++){
	printf("%d ", piece_pos[i]);
	}
	
	*/
	
	
	if(threadIdx.x  == 0 && blockIdx.x ==0){
		printf("\n");
		printf("# => represents your piece Currently Safe \n");
		printf("? => represents your piece Currently UnSafe \n");
	
		printf("S => represents a Safe Move \n");
		printf("U => represents an Unsafe Move \n");
		printf("A => represents Attacking Unsafe Move \n");
		printf("X => represents Attacking Safe Move \n");
		printf("\n");
		
		for(int i = 0; i < 16 ; i++){
			int pos = piece_pos[i+1];
			int dice = board[pos]%100;
			int val = dice;
			//int x = piece_pos[dice];
			
			if(turn == 0)
				val = dice + 100;
			
			//printf("%d , %d , %c\n",dice, val,piece[dice][0]);
			
			if(piece[dice][0] == 'p'){
				
				printf("possible moves for piece: %d\n", val);
				
				for(int i=0; i < SIDE; i++){
					for(int j=0; j < SIDE; j++){
						
						if(piece[dice][ SIDE*i + j + 1] == '\0'){
							printf("- ");
						}else
							printf("%c ", piece[dice][ SIDE*i + j + 1]);
					}
					printf("\n");
				}
				
				printf("\n");
				
			}
		}
		
	}
	
	
	//chk for all attacking places
	
	/*
	if(curr_pos == 0){
		printBlack();
		printWhite();
	}
	*/
}

/*
 * white piece 1-16
 * 			1-8 	pawns
 * 			9-10 	rook
 * 			11-12 	knight
 * 			13-14	bishop
 * 			15		Queen
 * 			16		King
 * 
 * Black Side	101 - 116 (correponding values)
 */

int main(void){
	
	
	int *h_board,*d_board,turn;
	
	/* 	turn
	 * 		0=> black
	 * 		1=> white 
	 * 
	 */ 
	
	
	scanf("%d",&turn);
	
	h_board = (int *) malloc(BOXES * sizeof(int));
	
	for(int i=0; i < SIDE; i++){
		for(int j=0; j < SIDE; j++){
			scanf("%d", &h_board[ SIDE*i + j]);
		}
	}	
	
	cudaMalloc(&d_board, BOXES * sizeof(int));
	
	
	cudaMemcpy(d_board, h_board, BOXES * sizeof(int) , cudaMemcpyHostToDevice);
	
	computeMoves<<<8,8>>>(d_board,turn);
	
	cudaDeviceSynchronize();
	
	
	printf("Current Board Position \n\n");
	
	for(int i=0; i < SIDE; i++){
		for(int j=0; j < SIDE; j++){
			//printf("%d\t", h_board[ SIDE*i + j]);
			
			int piece = h_board[ SIDE*i + j] % 100;
			
			switch(piece){
			
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
			case 6:
			case 7:
			case 8:
				if(h_board[ SIDE*i + j] < 100)
					printf("p ");
				else
					printf("P ");
				break;
			
			case 9:
			case 10:
				if(h_board[ SIDE*i + j] < 100)
					printf("r ");
				else
					printf("R ");
				break;
			
			case 11:
			case 12:
				if(h_board[ SIDE*i + j] < 100)
					printf("h ");
				else
					printf("H ");
				break;
			
			case 13:
			case 14:
				if(h_board[ SIDE*i + j] < 100)
					printf("b ");
				else
					printf("B ");
				break;
			
			case 15:
				if(h_board[ SIDE*i + j] < 100)
					printf("q ");
				else
					printf("Q ");
				break;
				
			case 16: 
				if(h_board[ SIDE*i + j] < 100)
					printf("k ");
				else
					printf("K ");
				break;
			default:
				printf("- ");
				break;
			}
			
		}
		printf("\n");
	}
	
	return 0;
}
