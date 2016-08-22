/* random.cl Implements random variable generation algorithms
 *
 * Copyright © 2016 Joshua Miklos under the MIT License
 * See LICENSE file or go to https://opensource.org/licenses/MIT for more details.
 */

#ifdef NUMBER_TYPE

#include <boost/preprocessor/cat.hpp>

/**
 *  Takes in a seed and an id and returns a unique random number
 */
NUMBER_TYPE BOOST_PP_CAT(java_random,NUMBER_TYPE)(const NUMBER_TYPE* random_seed,
                                                  const NUMBER_TYPE id){
    NUMBER_TYPE seed = (*random_seed) + id;
    seed = (seed * 0xCE66DL + 0xBL) & ((1L << 24) - 1);
    return seed >> 8;
}
#define JAVA_RANDOM(NUMBER_TYPE) BOOST_PP_CAT(java_random,NUMBER_TYPE)


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

#endif