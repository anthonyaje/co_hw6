#include <iostream>
#include <math.h>
#include <cstdio>

using namespace std;

struct cache_content{
	bool v;
	unsigned int  tag;
	unsigned int  data[16];
};

//GLOBAL VAR for main
const int K=1024;
//L1 Size
int cache_size=1*K;
int block_size=4;
int assoc=4;
//L2 size
int cache_size_l2=64*8;
int block_size_l2=2*8;
int assoc_l2=4;

//Global Variables for L2
cache_content *cache_l2;
int** lru_l2;
unsigned int tag_l2,index_l2;
int offset_bit_l2;
int line_l2;
int index_bit_l2 ;
unsigned int setNumber_l2;
unsigned long long missNumber_l2 = 0;
unsigned long long hitNumber_l2 = 0;

void rearrange(cache_content* arr,int index, int j, int setNum, int assoc){
	cache_content temp = arr[index+j*setNum];
	int i;
	for(i=j; i<assoc-1;i++){
		if(!arr[index+i*setNum+setNum].v)
			break;
		arr[index+i*setNum] = arr[index+i*setNum+setNum];
	}

	arr[index+(i)*setNum] = temp;
}

void rearrange(int* arr, int j, int assoc){
	int temp = arr[j];
	int i;
	for(i=j;i<assoc-1;i++){
		if(arr[i+1] == -1)
			break;
		arr[i] = arr[i+1];
	}

	arr[i] = temp;
}
void l2_lookup(){
	int j;
	for(j=0; j<assoc_l2; j++){
		if(cache_l2[index_l2+j*setNumber_l2].v){
			if(cache_l2[index_l2+j*setNumber_l2].tag == tag_l2){
				hitNumber_l2++; 			//hit
				rearrange(lru_l2[index_l2],j,assoc_l2);
				rearrange(cache_l2,index_l2,j,setNumber_l2,assoc_l2);

				break;
			}

		}
		else{
			missNumber_l2++;
			cache_l2[index_l2+j*setNumber_l2].v = true; 		// bring data to L1
			cache_l2[index_l2+j*setNumber_l2].tag = tag_l2;
			lru_l2[index_l2][j]=j;

			break;
		}
	}

	if(j==assoc_l2){
		missNumber_l2++;
		rearrange(lru_l2[index_l2],0,assoc_l2);
		rearrange(cache_l2,index_l2,0,setNumber_l2,assoc_l2);
		lru_l2[index_l2][assoc_l2-1] = lru_l2[index_l2][0];
		cache_l2[index_l2+(assoc_l2-1)*setNumber_l2].tag = tag_l2;
	}
}

void simulate(){
//------------------------------------------------------
// L-cache 1 declaration
//-------------------------------------------------------
	unsigned int tag,index,x;
	int offset_bit = (int) log2(block_size);
	int index_bit = (int) log2((cache_size/block_size)/assoc);
	int line = cache_size>>(offset_bit);
	unsigned int setNumber = line/assoc;

    FILE * fp = fopen("RADIX.txt","r");					//read file

	cache_content *cache = new cache_content[line];
	cout<<"cache line:"<<line<<endl;

	for(int j=0;j<line;j++)
		cache[j].v = false;


	unsigned long long missNumber = 0;
	unsigned long long hitNumber = 0;

	int** lru = new int* [setNumber];
	for(int i=0;i<setNumber;i++){
		lru[i] = new int[assoc];
		for(int j=0;j<assoc;j++)
			lru[i][j] = -1;
	}

//------------------------------------------------------
// L-cache 2
//-------------------------------------------------------
	offset_bit_l2 = (int) log2(block_size_l2);
	index_bit_l2 = (int) log2((cache_size_l2/block_size_l2)/assoc_l2);
	line_l2 = cache_size_l2>>(offset_bit_l2);
	setNumber_l2 = line_l2/assoc_l2;

	cache_l2 = new cache_content[line_l2];
	cout<<"cache line:"<<line_l2<<endl;

	for(int j=0;j<line_l2;j++)
		cache_l2[j].v = false;

	lru_l2 = new int* [setNumber_l2];
	for(int i=0;i<setNumber_l2;i++){
		lru_l2[i] = new int[assoc_l2];
		for(int j=0;j<assoc_l2;j++)
			lru_l2[i][j] = -1;
	}

//-------------------------------------------------
//CACHE Look-up
//-------------------------------------------------

	while(fscanf(fp,"%x",&x)!=EOF){
		index = (x>>offset_bit)&(setNumber-1);
		index_l2 = (x>>offset_bit_l2)&(setNumber_l2-1);
		tag = x>>(index_bit+offset_bit);
		tag_l2 = x>>(index_bit_l2+offset_bit_l2);

		// Check L1
		int j;
		for(j=0; j<assoc; j++){
			if(cache[index+j*setNumber].v){
				if(cache[index+j*setNumber].tag == tag){
					hitNumber++; 			//hit
					rearrange(lru[index],j,assoc);
					rearrange(cache,index,j,setNumber,assoc);

					break;
				}

			}
			else{
				missNumber++;
				cache[index+j*setNumber].v = true; 		// bring data to L1
				cache[index+j*setNumber].tag = tag;
				lru[index][j]=j;

				l2_lookup();
				break;
			}
		}

		if(j==assoc){
			missNumber++;
			l2_lookup();
			rearrange(lru[index],0,assoc);
			rearrange(cache,index,0,setNumber,assoc);
			lru[index][assoc-1] = lru[index][0];
			cache[index+(assoc-1)*setNumber].tag = tag;
		}
	}
	cout<<"miss number L1: "<<missNumber<<" hit number L1: "<<hitNumber<<endl;
	cout <<"miss rate L1: "<<(double) missNumber/(missNumber+hitNumber)<<endl;

	cout<<"miss number L2: "<<missNumber_l2<<" hit number L2: "<<hitNumber_l2<<endl;
	cout <<"miss rate L2: "<<(double) missNumber_l2/(missNumber_l2+hitNumber_l2)<<endl;

	cout<<"AMAT: "<<(1+ ((double)missNumber/(missNumber+hitNumber)*(10 + ((double)missNumber_l2/(missNumber_l2+hitNumber_l2))*100 ) ))<<" cycles"<<endl<<endl;
	fclose(fp);

	for(int i=0;i<setNumber;i++)
		delete [] lru[i];
	delete [] lru;

	delete [] cache;
}
int main(){
	// Let us simulate 4KB cache with 16B blocks
/*	int bsize_l1 = 4;          //BYTES
	double csize_l1 = 32;    //BYTES
	int assoc_l1 = 4;

	int bsize_l2 = 4;          //BYTES
	double csize_l2 = 32;    //BYTES
	int assoc_l2 = 4;
	*/
/*	cout<<"cache size: ";
	cin>>csize;
	cout<<"block size: ";
	cin>>bsize;
	int i=1;
	*/
	int i=1;
	while (i++ <= 4 ){
        while(block_size_l2 <= 16*8 ){
            cout<<"L2 Cache Size: "<<cache_size_l2<<" Bytes"<<endl;
            cout<<"L2 Block Size: "<<block_size_l2<<" Bytes"<<endl;
            simulate();
            block_size_l2 *= 2;
        }
        cache_size_l2 *= 2;
        block_size_l2 = 2*8;
	}

return 0;
}
