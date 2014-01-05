	#include <iostream>
#include <math.h>
#include <cstdio>

using namespace std;

struct cache_content{
	bool v;
	unsigned int  tag;
	unsigned int  data[16];
};

const int K=1024;

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

void simulate(int cache_size, int block_size, int assoc){
	unsigned int tag,index,x;

	int offset_bit = (int) log2(block_size);
	int index_bit = (int) log2((cache_size/block_size)/assoc);
	int line = cache_size>>(offset_bit);
	unsigned int setNumber = line/assoc;

	cache_content *cache = new cache_content[line];
	cout<<"cache line:"<<line<<endl;

	for(int j=0;j<line;j++)
		cache[j].v = false;

    FILE * fp = fopen("LU.txt","r");					//read file

	unsigned long long missNumber = 0;
	unsigned long long hitNumber = 0;

	int** lru = new int* [setNumber];
	for(int i=0;i<setNumber;i++){
		lru[i] = new int[assoc];
		for(int j=0;j<assoc;j++)
			lru[i][j] = -1;
	}

	while(fscanf(fp,"%x",&x)!=EOF){
		//cout<<hex<<x<<" ";
		index = (x>>offset_bit)&(setNumber-1);
		tag = x>>(index_bit+offset_bit);
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
				cache[index+j*setNumber].v = true;
				cache[index+j*setNumber].tag = tag;
				lru[index][j]=j;

				break;
			}
		}

		if(j==assoc){
			//cout<<"\nindex:"<<index<<endl;
			//cout<<"old tag: "<<cache[index].tag<<" new tag: "<<tag<<endl;
			missNumber++;
			rearrange(lru[index],0,assoc);
			rearrange(cache,index,0,setNumber,assoc);
			lru[index][assoc-1] = lru[index][0];
			cache[index+(assoc-1)*setNumber].tag = tag;
		}

	}
	cout<<"miss number: "<<missNumber<<" hit number: "<<hitNumber<<endl;
	cout <<"miss rate: "<<(double) missNumber/(missNumber+hitNumber)<<"\n"<<endl;

	fclose(fp);

	for(int i=0;i<setNumber;i++)
		delete [] lru[i];
	delete [] lru;

	delete [] cache;
}

int main(){
	// Let us simulate 4KB cache with 16B blocks
	int bsize = 4;          //BYTES
	double csize = 64;    //BYTES
	int assoc = 1;
/*	cout<<"cache size: ";
	cin>>csize;
	cout<<"block size: ";
	cin>>bsize;
	int i=1;
	*/

	int i=1;
	while (i++ <= 4 ){
        while(assoc <= 8 ){
            cout<<"Cache Size: "<<csize<<" Bytes"<<endl;
            cout<<"Assoc Size: "<<assoc<<endl;
            simulate(csize, bsize, assoc);
            assoc *= 2;
        }
        csize *= 2;
        assoc = 1;
	}

    //simulate(1024, 4, 4);

return 0;
}
