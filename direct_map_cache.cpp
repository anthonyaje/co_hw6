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

void simulate(int cache_size, int block_size){
	unsigned int tag,index,x;

	int offset_bit = (int) log2(block_size);
	int index_bit = (int) log2(cache_size/block_size);
	int line = cache_size>>(offset_bit);

	cache_content *cache = new cache_content[line];
	cout<<"cache line:"<<line<<endl;

	for(int j=0;j<line;j++)
		cache[j].v = false;

  FILE * fp = fopen("DCACHE.txt","r");					//read file
	unsigned long long missNumber = 0;
	unsigned long long hitNumber = 0;

	while(fscanf(fp,"%x",&x)!=EOF){
		//cout<<hex<<x<<" ";
		index = (x>>offset_bit)&(line-1);
		tag = x>>(index_bit+offset_bit);
		if(cache[index].v && cache[index].tag==tag){
			hitNumber++;
			cache[index].v = true; 			//hit
		}
		else{
			//cout<<"\nindex:"<<index<<endl;
			//cout<<"old tag: "<<cache[index].tag<<" new tag: "<<tag<<endl;
			missNumber++;
			cache[index].v = true;			//miss
			cache[index].tag = tag;
		}
	}

	cout <<"miss rate: "<<(double) missNumber/(missNumber+hitNumber)<<"\n"<<endl;

	fclose(fp);

	delete [] cache;
}

int main(){
	// Let us simulate 4KB cache with 16B blocks
	int bsize = 4;          //BYTES
	double csize = 32;    //BYTES
/*	cout<<"cache size: ";
	cin>>csize;
	cout<<"block size: ";
	cin>>bsize; */
	int i=1;
	while (i++ <= 4 ){
        while(bsize <= 32 ){
            cout<<"Cache Size: "<<csize<<" Bytes"<<endl;
            cout<<"Block Size: "<<bsize<<" Bytes"<<endl;
            simulate(csize, bsize);
            bsize *= 2;
        }
        csize *= 2;
        bsize = 8;
	}

return 0;
}
