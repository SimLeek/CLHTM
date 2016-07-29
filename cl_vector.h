//WARNING: TRY NOT TO USE THIS

//if you're using a vector, usually that means you're working on a list of items, piece by piece
// opencl is for doing things in parallel. So unless you have a LOT of lists...
// well, the number of real use cases for this should actually be low

//MIT Liscense to: https://gist.github.com/EmilHernvall/953968

#ifndef VECTOR_H_
#define VECTOR_H_

#include "templates.h"

//I could define function pointers in here, but I'm not sure it's actually a good idea
// via: http://stackoverflow.com/a/12642862/782170
// and: http://eddmann.com/posts/implementing-a-dynamic-vector-array-in-c/

//right now I'm happy with just heaping everything onto the preprocessor with the templates
typedef struct TEMPLATE(vector_, T){
    T* data;
    size_t size;
    size_t count;

} TEMPLATE(vector, T);

void TEMPLATE(vector_init, T)(TEMPLATE(vector, T) *v);
size_t TEMPLATE(vector_count, T)(TEMPLATE(vector, T) *v);
void TEMPLATE(vector_add, T)(TEMPLATE(vector, T) *v, T);
void TEMPLATE(vector_set, T)(TEMPLATE(vector, T) *v, size_t, T);
T TEMPLATE(vector_get, T)(TEMPLATE(vector, T) *v, size_t);
void TEMPLATE(vector_delete, T)(TEMPLATE(vector, T) *v, size_t);
void TEMPLATE(vector_free, T)(TEMPLATE(vector, T) *v);

#endif