#include "templates.h"


//return via global pointer
__kernel integer TEMPLATE(random, integer)(/*__local const ulong* random_seed*/
        integer random_seed,
        __global integer* random_results){
    size_t globalID = get_global_id(0)*get_local_id(0)+get_local_id(0);
    integer seed = random_seed + globalID;
    seed = (seed * 0x5DEECE66DL + 0xBL) & ((1L << 48) - 1);
    random_results[globalID] = seed >> 16;
}

//gpugems3/gpugems3_ch37
//S1, S2, S3 are all constants
/*uint TausStep(uint& z, unit S1, uint S2, uint S3, uint M){
    size_t z = get_global_id(0)*get_local_id(0)+get_local_id(0);
    uint b=(((z<<S1)^z)>>S2);
    return z=(((z & M) << S3) ^ b);
}

uint LCGStep(uint& z, uint A, uint C){
    return z=(A*z+C);
}
*/
