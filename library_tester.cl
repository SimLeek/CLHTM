#define HASH_SIZE 256
#define HASH_TYPE int
#include "CLCTL/xy_hash_map.cl"

#define NUMBER_TYPE int
#include "CLCTL/random.cl"

/**
 * A horribly inefficient implementation of hash tables.
 * It works for quick testing though.
 */
void kernel hash_add_test(global const int* A, global const int* B, global int* C)
{
XY_HASH_TABLE(HASH_SIZE,HASH_TYPE) hashy;
for(int i=0; i<256; ++i){
hashy.table[i].key1=-1;
hashy.table[i].key2=-1;
hashy.table[i].val=-1;
}

XY_HASH_VALUE(HASH_SIZE,HASH_TYPE) hish;
hish.key1 = A[get_global_id(0)];
hish.key2 = B[get_global_id(0)];

int D = A[get_global_id(0)] + B[get_global_id(0)];

hish.val = D;

XY_HASH_TABLE_INSERT(HASH_SIZE, HASH_TYPE)(&hashy, &hish);

XY_HASH_VALUE(HASH_SIZE,HASH_TYPE) hosh;
hosh.key1 = A[get_global_id(0)];
hosh.key2 = B[get_global_id(0)];
XY_HASH_TABLE_GET(HASH_SIZE, HASH_TYPE)(&hashy, &hosh);

C[get_global_id(0)] = hosh.val;

}

void kernel random_number_generator_test(global const int* A, global const int* seed){
    size_t globalID = get_global_id(0)*get_local_id(0)+get_local_id(0);
    A[globalID] = JAVA_RANDOM(NUMBER_TYPE)(seed,globalID);
}