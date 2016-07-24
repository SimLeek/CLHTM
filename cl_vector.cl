#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define T void//todo:DELETE THIS CLANG HELPER
#include "cl_vector.h"

//todo: put preprocessor functions in own file
#ifdef ERRORS
char* last_error;//free and
inline void throw(const char* msg){last_error = msg;}
#else
#define throw(x)
#endif

#define xstr(s) str(s)
#define str(s) #s

void TEMPLATE(vector_init, TEMPLATE(vector, T))(TEMPLATE(vector, T)* v){
    v->data = NULL;
    v->size = 0;
    v->count= 0;
}

int TEMPLATE(vector_count, TEMPLATE(vector, T))(TEMPLATE(vector, T)* v){
    return v->count;
}
void TEMPLATE(vector_add, TEMPLATE(vector, T))(TEMPLATE(vector, T)* v, T* x){
    if(v->size == 0){
        v->size = 2;//todo: check for speed of different initial settings
        v->data = malloc(sizeof(T*) * v->size);
        //todo: check if not setting zero affects anything
        //memset(v->data, '\0', sizeof(T*) * v->size);
    }
    if(v->size == v->count){
        v->size <<=1;
        v->data = realloc(v->data, sizeof(T*) * v->size);
    }

    v->data[v->count] = e;
    v->count++;
}

void TEMPLATE(vector_set, TEMPLATE(vector, T))(TEMPLATE(vector, T)* v, size_t i, T* x){
    if(i >= v->count){
        //todo: check whether I can just use perror with preprocessor setting to nothing
        //todo: check errno or somethign
        //site: https://en.wikibooks.org/wiki/C_Programming/Error_handling
        throw("Runtime Error [" xstr(TEMPLATE(vector_set, TEMPLATE(vector, T))) "]: vector index out of range.")
        return;
    }

    v->data[i] = x;
}

T* TEMPLATE(vector_get, TEMPLATE(vector, T))(TEMPLATE(vector, T)* v, size_t i){
    if(i >= v->count){
        throw("Runtime Error [" xstr(TEMPLATE(vector_get, TEMPLATE(vector, T))) "]: vector index out of range.")
        return NULL;
    }
    return v->data[i];
}

void TEMPLATE(vector_delete, TEMPLATE(vector, T))(TEMPLATE(vector, T)* v, size_t _i){
    if(_i >= v->count){
        throw("Runtime Error [" xstr(TEMPLATE(vector_delete, TEMPLATE(vector, T))) "]: vector index out of range.")
        return;
    }
    for(size_t i = _i, j=_i; i< v->count; i++){
        v->data[j] = v->data[i];
        j++;
    }

    v->count--;
}
void TEMPLATE(vector_free, TEMPLATE(vector, T))(TEMPLATE(vector, T)* v){
    free(v->data);
}