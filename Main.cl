
#include <boost/preprocessor/cat.hpp>

//highly divisible numbers (not divisible by 2) for 'randomly' accessing array after collisions.
#define hash_mask_2 1 //2^1
#define hash_mask_4 1 //2^2
#define hash_mask_8 3 //2^3
#define hash_mask_16 9 //2^4
#define hash_mask_32 15 //2^5
#define hash_mask_64 45 //2^6
#define hash_mask_128 105 //2^7
#define hash_mask_256 225 //2^8
#define hash_mask_512 315 //2^9
#define hash_mask_1024 735 //2^10
#define hash_mask_2048 1575 //2^11
#define hash_mask_4096 3465 //2^12
#define hash_mask_8192 5775 //2^13
#define hash_mask_16384 15015 //2^14
#define hash_mask_32768 24255 //2^15
#define hash_mask_65536 45045 //2^16
#define hash_mask_131072 105105 //2^17
#define hash_mask_262144 255255 //2^18
#define hash_mask_524288 315315 //2^19
#define hash_mask_1048576 765765 //2^20
#define hash_mask_2097152 1786785 //2^21
#define hash_mask_4194304 3318315 //2^22
#define hash_mask_8388608 5870865 //2^23
#define hash_mask_16777216 13018005 //2^24
#define hash_mask_33554432 29354325 //2^25
#define hash_mask_67108864 4109605 //2^26
#define hash_mask_134217728 123288165 //2^27
#define hash_mask_268435456 158513355 //2^28
#define hash_mask_536870912 475540065 //2^29
#define hash_mask_1073741824 792566775 //2^30
#define hash_mask_2147483648 1743646905 //2^31
#define hash_mask_4294967296 3645807165 //2^32

#define HASH_MASK(HASH_SIZE) BOOST_PP_CAT(hash_mask_,HASH_SIZE)

#define HASH_SIZE 256

//todo: allow hash sizes for other sizes with at least 75% 0's and error if not 75% 0's

#define HASH_TYPE int

#define BOOST_PP_3CAT(a,b,c) BOOST_PP_CAT(a,BOOST_PP_CAT(b,c))

//#include <boost/preprocessor/stringize.hpp>
//#include <iostream>
//#define PROBE(A) std::cout << BOOST_PP_STRINGIZE(A) << ": " << A << "\n"

//todo: use boost_pp_div to define a log_2 function and use that to allow boost_pp_less equal to compare values and choose smallest necessary size type


#define HASH_SIZE_TYPE size_t

typedef struct BOOST_PP_3CAT(HashValueStruct,HASH_SIZE,HASH_TYPE) {
    HASH_SIZE_TYPE key1;
    HASH_SIZE_TYPE key2;
    HASH_TYPE val;

} BOOST_PP_3CAT(HashValue,HASH_SIZE,HASH_TYPE);
#define HASH_VALUE(HASH_SIZE,HASH_TYPE) BOOST_PP_3CAT(HashValue,HASH_SIZE,HASH_TYPE)

typedef struct BOOST_PP_3CAT(HashTableStruct,HASH_SIZE,HASH_TYPE){
    HASH_VALUE(HASH_SIZE,HASH_TYPE) table[HASH_SIZE];
} BOOST_PP_3CAT(HashTable,HASH_SIZE,HASH_TYPE);
#define HASH_TABLE(HASH_SIZE,HASH_TYPE) BOOST_PP_3CAT(HashTable,HASH_SIZE,HASH_TYPE)
//todo: test whether making HashTable an array of pointers speeds things up
//todo: if so, define differently, so local versions take advantage of that only

//template stuff here
inline size_t BOOST_PP_3CAT(hash_find_unused_index,HASH_SIZE, HASH_TYPE)
        (HASH_TABLE(HASH_SIZE,HASH_TYPE)* h,
         HASH_VALUE(HASH_SIZE,HASH_TYPE)* v){
    HASH_SIZE_TYPE size_masker = (HASH_SIZE-1);
    HASH_SIZE_TYPE i= (v->key1 ^ v->key2) & size_masker; //a xor b
    while(h->table[i].val!=-1){
        HASH_SIZE_TYPE n = (i >> 1) ^ HASH_MASK(HASH_SIZE);
        i=(i+n) & size_masker;
    }
    return i;
}
#define HASH_FIND_UNUSED_INDEX(HASH_SIZE, HASH_TYPE) BOOST_PP_3CAT(hash_find_unused_index,HASH_SIZE, HASH_TYPE)

inline size_t BOOST_PP_3CAT(hash_find_used_index,HASH_SIZE, HASH_TYPE)
        (HASH_TABLE(HASH_SIZE,HASH_TYPE)* h,
         HASH_VALUE(HASH_SIZE,HASH_TYPE)* v){
    HASH_SIZE_TYPE size_masker = (HASH_SIZE-1);
    HASH_SIZE_TYPE i= (v->key1 ^ v->key2) & size_masker; //a xor b
    int counter=0;
    while(h->table[i].key1 != v->key1 || h->table[i].key2 != v->key2){
        counter++;
        HASH_SIZE_TYPE n = (i >> 1) ^ HASH_MASK(HASH_SIZE);
        i=(i+n) & size_masker;
        if(counter>=10) return i;
    }
    return i;
}
#define HASH_FIND_USED_INDEX(HASH_SIZE, HASH_TYPE) BOOST_PP_3CAT(hash_find_used_index,HASH_SIZE, HASH_TYPE)


void  BOOST_PP_3CAT(insert_hash_table,HASH_SIZE, HASH_TYPE)
        (HASH_TABLE(HASH_SIZE,HASH_TYPE)* h,
         HASH_VALUE(HASH_SIZE,HASH_TYPE)* v){
    HASH_SIZE_TYPE i = HASH_FIND_UNUSED_INDEX(HASH_SIZE, HASH_TYPE)(h,v);
    h->table[i] = *v;

}
#define HASH_TABLE_INSERT(HASH_SIZE, HASH_TYPE) BOOST_PP_3CAT(insert_hash_table,HASH_SIZE, HASH_TYPE)

void  BOOST_PP_3CAT(remove_hash_table,HASH_SIZE, HASH_TYPE)
        (HASH_TABLE(HASH_SIZE,HASH_TYPE)* h,
         HASH_VALUE(HASH_SIZE,HASH_TYPE)* v){
    HASH_SIZE_TYPE i = HASH_FIND_USED_INDEX(HASH_SIZE, HASH_TYPE)(h,v);
    h->table[i].key1 = -1;
    h->table[i].key2 = -1;
    h->table[i].val = -1;
}
#define HASH_TABLE_REMOVE(HASH_SIZE, HASH_TYPE) BOOST_PP_3CAT(remove_hash_table,HASH_SIZE, HASH_TYPE)

BOOST_PP_3CAT(HashValue,HASH_SIZE,HASH_TYPE)*
BOOST_PP_3CAT(get_hash_table,HASH_SIZE, HASH_TYPE)
        (HASH_TABLE(HASH_SIZE,HASH_TYPE)* h,
         HASH_VALUE(HASH_SIZE,HASH_TYPE)* v){
    HASH_SIZE_TYPE i = HASH_FIND_USED_INDEX(HASH_SIZE, HASH_TYPE)(h,v);
    return &(h->table[i]);
}
#define HASH_TABLE_GET(HASH_SIZE, HASH_TYPE) BOOST_PP_3CAT(get_hash_table,HASH_SIZE, HASH_TYPE)

BOOST_PP_3CAT(HashValue,HASH_SIZE,HASH_TYPE)*
BOOST_PP_3CAT(pop_hash_table,HASH_SIZE, HASH_TYPE)
        (HASH_TABLE(HASH_SIZE,HASH_TYPE)* h,
         HASH_VALUE(HASH_SIZE,HASH_TYPE)* v){
    HASH_SIZE_TYPE i = HASH_FIND_USED_INDEX(HASH_SIZE, HASH_TYPE)(h,v);
    HASH_VALUE(HASH_SIZE,HASH_TYPE)* t = &(h->table[i]);
    h->table[i].key1 = -1;
    h->table[i].key2 = -1;
    h->table[i].val = -1;
    return t;
}
#define HASH_TABLE_POP(HASH_SIZE, HASH_TYPE) BOOST_PP_3CAT(pop_hash_table,HASH_SIZE, HASH_TYPE)
void kernel simple_add(global const int* A, global const int* B, global int* C)
{
HASH_TABLE(HASH_SIZE,HASH_TYPE) hashy;
for(int i=0; i<256; ++i){
    hashy.table[i].key1=-1;
    hashy.table[i].key2=-1;
    hashy.table[i].val=-1;
}

HASH_VALUE(HASH_SIZE,HASH_TYPE) hish;
hish.key1 = A[get_global_id(0)];
hish.key2 = B[get_global_id(0)];

int D = A[get_global_id(0)] + B[get_global_id(0)];

hish.val = D;

HASH_TABLE_INSERT(HASH_SIZE, HASH_TYPE)(&hashy, &hish);

HASH_VALUE(HASH_SIZE,HASH_TYPE) hosh;
hosh.key1 = A[get_global_id(0)];
hosh.key2 = B[get_global_id(0)];

C[get_global_id(0)] = (HASH_TABLE_GET(HASH_SIZE, HASH_TYPE)(&hashy, &hosh))->val;

}

/* PSEUDOCODE
 *  do not run until every function is defined

//Good for Atmel FPGA chips, not so good for GPUs
void kernel tiny_NNs_step(local int* activation_strengths,
                          local int* activations,
                          local int* connections,
                          local HashMap connection_strengths,
                          local int num_neurons)
{

 //work item should only do part of work.
    for(int n=0; n<num_neurons; ++n){
        if(activations[n]>activation_strengths[n]){
            for(k=0; k<connections_per_neuron; ++k){
                int con = get_connection(connections[n], k);
                int con_str=connection_strengths(n, con);
                activations[con]+=con_str;
            }
        }
    }
}

void kernel nn_step(
                    //global is kept in memory as kernel argument through clenqueuendrangekernel until it is dequeued
                    //remove const if you want to edit nn in place
                    //for not, nn will be edited on cpu side for simplicity
                    //later, it will optionally be edited on gpu side for fast learning

                    global const SerializedCluster* clusters,
                    global const int* cluster_groups,
                    global const int* cluster_connections,
                    global const HashMap    cluster_connection_strengths,
                    global const SerializedNN* networks,

                    global int* input;//give neurons 1 to n additional activation equal to input, can include cache-in
                    global int* output;//take activation of neurons n+1 to m as output, can include cache-out
                    global int* cache;//give neurons m+1 to k prev cycle's cache out, and record k+1 to l as this cycle's
                    //cache. use l+1 to t as
                    )
{



    local int* network_groups;
    local int* network_connections;
    local HashMap network_connection_strengths;

    uint global_id = get_global_id(0);

    //quick inline deserialization
    // work item only serializes partial (LocalMemoryExample)
    deserializeCluster(clusters[cluster_groups[global_id] ],
            network_groups,
            network_connections,
            network_connection_strengths);

    private int* activation_strengths;
    private int* connections;
    private HashMap connection_strengths;//if not in map, str is 1
    private int num_neurons;

    uint local_id = get_local_id(0);

    //quick inline deserialization
    deserializeNN(networks[network_groups[local_id] ],
            activation_strengths,
            connections,
            connection_strengths,
            num_neurons);

    local int[lcache_size] lcache;
    private int[pcache_size] pcache;

    for(int i=0; i<lcache_size; ++i){//unroll?
        for(int j=0; j<pcache_size; ++j){
            for(int n=0; n<num_neurons; ++n){
                if(activations[n]>activation_strengths[n]){
                    for(k=0; k<connections_per_neuron; ++k){
                        int con = get_connection(connections[n], k);
                        int con_str=connection_strengths(n, con);
                        activations[con]+=con_str;
                    }
                }
            }
        }
    }

}
 */