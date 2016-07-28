#ifndef TEMPLATES_H_
#define TEMPLATES_H_

//http://stackoverflow.com/a/17670232/782170
//todo: see if there's a way to make sure only first template instatntiation works
#define CAT(X,Y) X##_##Y
#define TEMPLATE(X,Y) CAT(X,Y)

/*#define CAT(X,Y,Z) X##_##Y##_##Z   //concatenate words
#define TEMPLATE(X,Y,Z) CAT(X,Y,Z)*/

#endif