
#define HASH_SIZE 256
#define HASH_TYPE int
#include "cl_hash_map.cl"

void kernel simple_add(global const int* A, global const int* B, global int* C)
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