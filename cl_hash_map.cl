/* cl_xy_hash_map.cl Implements hash maps that store (x,y) positions with respective values
 *
 * Copyright © 2016 Joshua Miklos under the MIT License
 * See LICENSE file or go to https://opensource.org/licenses/MIT for more details.
 */

#ifdef HASH_SIZE
#ifdef HASH_TYPE

#include <boost/preprocessor/cat.hpp>
#define BOOST_PP_3CAT(a,b,c) BOOST_PP_CAT(a,BOOST_PP_CAT(b,c))
//#include <boost/preprocessor/facilities/expand.hpp>

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

//todo: allow hash sizes for other sizes with at least 75% 0's and error if not 75% 0's

//todo: use boost_pp_div to define a log_2 function and use that to allow boost_pp_less equal to compare values and choose smallest necessary size type

#define HASH_SIZE_TYPE size_t

/**
 * Holds the x and y positions as well as the value at that position
 *
 * @param key1 x location
 * @param key2 y location
 * @param val value at the x,y location
 */
typedef struct BOOST_PP_3CAT(XYHashValueStruct,HASH_SIZE,HASH_TYPE) {
    HASH_SIZE_TYPE key1;
    HASH_SIZE_TYPE key2;
    HASH_TYPE val;

} BOOST_PP_3CAT(XYHashValue,HASH_SIZE,HASH_TYPE);
#define XY_HASH_VALUE(HASH_SIZE,HASH_TYPE) BOOST_PP_3CAT(XYHashValue,HASH_SIZE,HASH_TYPE)

/**
 * Holds an array of XY_HASH_VALUE(HASH_SIZE,HASH_TYPE)s.
 * it holds HASH_SIZE positions at max.
 *
 * @param table the hash table
 */
typedef struct BOOST_PP_3CAT(XYHashTableStruct,HASH_SIZE,HASH_TYPE){
    XY_HASH_VALUE(HASH_SIZE,HASH_TYPE) table[HASH_SIZE];
} BOOST_PP_3CAT(XYHashTable,HASH_SIZE,HASH_TYPE);
#define XY_HASH_TABLE(HASH_SIZE,HASH_TYPE) BOOST_PP_3CAT(XYHashTable,HASH_SIZE,HASH_TYPE)
//todo: test whether making XYHashTable an array of pointers speeds things up
//todo: if so, define differently, so local versions take advantage of that only

/**
 * Computes hashes of the x and y values until it finds the first unused slot in the table.
 *
 * @param h a pointer to the hash table
 * @param v a pointer to the hash value containing the x and y values
 */
inline size_t BOOST_PP_3CAT(xy_hash_find_unused_index,HASH_SIZE, HASH_TYPE)
        (XY_HASH_TABLE(HASH_SIZE,HASH_TYPE)* h,
         XY_HASH_VALUE(HASH_SIZE,HASH_TYPE)* v){
    HASH_SIZE_TYPE size_masker = (HASH_SIZE-1);
    HASH_SIZE_TYPE i= (v->key1 ^ v->key2) & size_masker; //a xor b
    while(h->table[i].val!=-1){
        HASH_SIZE_TYPE n = (i >> 1) ^ HASH_MASK(HASH_SIZE);
        i=(i+n) & size_masker;
    }
    return i;
}
#define XY_HASH_FIND_UNUSED_INDEX(HASH_SIZE, HASH_TYPE) BOOST_PP_3CAT(xy_hash_find_unused_index,HASH_SIZE, HASH_TYPE)

/**
 * Computes hashes of the x and y values until it finds the first filled slot in the table.
 *
 * @param h a pointer to the hash table
 * @param v a pointer to the hash value containing the x and y values
 */
inline size_t BOOST_PP_3CAT(xy_hash_find_used_index,HASH_SIZE, HASH_TYPE)
        (XY_HASH_TABLE(HASH_SIZE,HASH_TYPE)* h,
         XY_HASH_VALUE(HASH_SIZE,HASH_TYPE)* v){
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
#define XY_HASH_FIND_USED_INDEX(HASH_SIZE, HASH_TYPE) BOOST_PP_3CAT(xy_hash_find_used_index,HASH_SIZE, HASH_TYPE)

/**
 * Inserts a variable into the hash table.
 *
 * @param h a pointer to the hash table
 * @param v a pointer to the hash value to be inserted into the table
 */
void  BOOST_PP_3CAT(insert_xy_hash_table,HASH_SIZE, HASH_TYPE)
        (XY_HASH_TABLE(HASH_SIZE,HASH_TYPE)* h,
         XY_HASH_VALUE(HASH_SIZE,HASH_TYPE)* v){
    HASH_SIZE_TYPE i = XY_HASH_FIND_UNUSED_INDEX(HASH_SIZE, HASH_TYPE)(h,v);
    h->table[i] = *v;

}
#define XY_HASH_TABLE_INSERT(HASH_SIZE, HASH_TYPE) BOOST_PP_3CAT(insert_xy_hash_table,HASH_SIZE, HASH_TYPE)

/**
 * Removes a variable from the hash table.
 *
 * @param h a pointer to the hash table
 * @param v a pointer to the hash value containing the x and y position
 */
void  BOOST_PP_3CAT(remove_xy_hash_table,HASH_SIZE, HASH_TYPE)
        (XY_HASH_TABLE(HASH_SIZE,HASH_TYPE)* h,
         XY_HASH_VALUE(HASH_SIZE,HASH_TYPE)* v){
    HASH_SIZE_TYPE i = XY_HASH_FIND_USED_INDEX(HASH_SIZE, HASH_TYPE)(h,v);
    h->table[i].key1 = -1;
    h->table[i].key2 = -1;
    h->table[i].val = -1;
}
#define XY_HASH_TABLE_REMOVE(HASH_SIZE, HASH_TYPE) BOOST_PP_3CAT(remove_xy_hash_table,HASH_SIZE, HASH_TYPE)

/**
 * Returns a variable from the hash table.
 *
 * @param h a pointer to the hash table
 * @param v a pointer to the hash value containing the x,y location,
 *          it will have its value filled.
 */
void BOOST_PP_3CAT(get_xy_hash_table,HASH_SIZE, HASH_TYPE)
        (XY_HASH_TABLE(HASH_SIZE,HASH_TYPE)* h,
         XY_HASH_VALUE(HASH_SIZE,HASH_TYPE)* v){
    HASH_SIZE_TYPE i = XY_HASH_FIND_USED_INDEX(HASH_SIZE, HASH_TYPE)(h,v);
    v->val=h->table[i].val;
}
#define XY_HASH_TABLE_GET(HASH_SIZE, HASH_TYPE) BOOST_PP_3CAT(get_xy_hash_table,HASH_SIZE, HASH_TYPE)

/**
 * Pops a variable from the hash table.
 *
 * @param h a pointer to the hash table
 * @param v a pointer to the hash value containing the x,y location to be popped,
 *          it will have its value filled.
 */
void BOOST_PP_3CAT(pop_xy_hash_table,HASH_SIZE, HASH_TYPE)
        (XY_HASH_TABLE(HASH_SIZE,HASH_TYPE)* h,
         XY_HASH_VALUE(HASH_SIZE,HASH_TYPE)* v){
    HASH_SIZE_TYPE i = XY_HASH_FIND_USED_INDEX(HASH_SIZE, HASH_TYPE)(h,v);
    v->val=h->table[i].val;
    h->table[i].key1 = -1;
    h->table[i].key2 = -1;
    h->table[i].val = -1;
}
#define XY_HASH_TABLE_POP(HASH_SIZE, HASH_TYPE) BOOST_PP_3CAT(pop_xy_hash_table,HASH_SIZE, HASH_TYPE)

#endif
#endif