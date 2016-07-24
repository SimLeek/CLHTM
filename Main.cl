/* ---------------------------------------------------------------------
 * Numenta Platform for Intelligent Computing (NuPIC)
 * Copyright (C) 2013, Numenta, Inc.  Unless you have an agreement
 * with Numenta, Inc., for a separate license for this software code, the
 * following terms and conditions apply:
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Affero Public License for more details.
 *
 * You should have received a copy of the GNU Affero Public License
 * along with this program.  If not, see http://www.gnu.org/licenses.
 *
 * http://numenta.org/licenses/
 * ---------------------------------------------------------------------
 */

#include "templates.h"

#define integer uint
#include "random.cl"

#define real float
#define T float
#include "cl_vector.h"


_kernel void main(){
    //todo: return different parts based on global kernel values.
    TEMPLATE(vector, T) v;
    TEMPLATE(vector_init, T)(&v);

    TEMPLATE(vector_add, T)(&v, 1.0);
    TEMPLATE(vector_add, T)(&v, 3.0);
    TEMPLATE(vector_add, T)(&v, 2.0);
    TEMPLATE(vector_add, T)(&v, 5.0);
    TEMPLATE(vector_add, T)(&v, 4.0);

    for (int i=0; i<TEMPLATE(vector_count, T)(&v); ++i){
        TEMPLATE(vector_add, T)(
                &v,
                TEMPLATE(vector_get, T)(&v, i)
        );
    }

    TEMPLATE(vector_delete, T)(&v, 1);
    TEMPLATE(vector_delete, T)(&v, 3);

    for (int i=0; i<TEMPLATE(vector_count, T)(&v); ++i){
        TEMPLATE(vector_add, T)(
                &v,
                TEMPLATE(vector_get, T)(&v, i)
        );
    }

    vector_free(&v);

    return;
}

/*
inline bool ASSERT(bool cond, const char* msg){
#ifdef ASSERTIONS_ON
  if(!(cond)){
    //todo: create a vector class to store the output before sending it back
    //vec << msg
    return false;
  }
#endif
  return true;
}
// thx: http://stackoverflow.com/a/2218295/782170
void TEMPLATE(ASSERT_VALID_RANGE, It)(It begin, It end, const char* msg){
    const char* descriptor = "Invalid iterators: ";
    char* message_with_descriptor;
    message_with_descriptor = malloc(strlen(descriptor)+strlen(msg));
    strcpy(message_with_descriptor, descriptor);
    strcat(message_with_descriptor, msg);
    ASSERT(begin <= end, message_with_descriptor);
    //todo: free(message_with_descriptor) eventually
}

static const real epsilon = real(1e-6);

inline bool TEMPLATE(strictlyNegative, T)(const T& a){
    return a< -epsilon;
}

inline bool TEMPLATE(strictlyPositive, T)(const T& a){
    return a> epsilon;
}

inline bool TEMPLATE(negative, T)(const T& a){
    return a<= -epsilon;
}

inline bool TEMPLATE(positive, T)(const T& a){
    return a>= epsilon;
}

//todo: I think I'm going to just replace these structs with pure functions
struct TEMPLATE(DistanceToZero, T){
    typedef T argument_type;
    typedef T result_type;

    //todo: if this doesn't work well, use abs, labs, llabs, imaxabs, fabs, fabsf, and fabsl
    //todo: use this to have structs with functions: http://stackoverflow.com/a/17052566/782170
    inline T get(const T& x) const{
        return x >= 0 ? x : -x;
    }
}

//TEMPLATE(DistanceToZero, uint).get= (const uint &x) const { return x; }

//todo: when distance to zero is actually tested, create positive version, or version that tests for unsigned

inline T TEMPLATE(DistanceToOne, T)(const T& x) const{
    return x > (T) 1 ? x - (T) 1 : (T) 1 - x;
}

inline bool TEMPLATE(IsNearlyZero, T)(const T& x) const{
    return TEMPLATE(DistanceToZero, T)(x) <= epsilon;
}

//todo: check if we have default params in c
inline bool TEMPLATE(NearlyZero)(const T &a, const T& e = epsilon){
    return a >= -e && a <= e;
}

inline bool TEMPLATE(NearlyEqual, T)(const T& a, const T& b, const T& e=epsilon){
    return TEMPLATE(NearlyZero, T)((b-a), e);
}

//returns x%m, but keeps value positive
inline integer TEMPLATE(emod, integer)(integer x, integer m){
    integer r = x % m;
    if (r<0){ return r+m;}
    else return r;
}

//todo: create cl-side and cpu-cl version of IsIncluded function
//todo: but first we need containers, like vectors or arrays
//todo: we also need a pair struct
 */