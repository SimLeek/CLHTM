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
                                                  const NUMBER_TYPE id,){
    NUMBER_TYPE seed = random_seed + id;
    seed = (seed * 0x5DEECE66DL + 0xBL) & ((1L << 48) - 1);
    return seed >> 16;
}
#define JAVA_RANDOM(NUMBER_TYPE) BOOST_PP_CAT(java_random,NUMBER_TYPE)

#endif