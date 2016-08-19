# CLCTL
OpenCL C "Template" Library

##Installation and Usage

###In your CL file:

Before you include the files, you'll have to set the necessary defines. Some types have different preprocessor variables that need to be defined.

####cl_xy_hash_map.cl example:



```
#define HASH_SIZE 256
#define HASH_TYPE int
#include "cl_hash_map.cl"
```
###In your C/C++ file:

You'll need to set the include directory to both include this file, as well as the boost preprocessor library.

For example:

```
program.build({device},"-I . -I C:\\msys64\\mingw64\\include");
```

##Todo

*Create a type on the C/C++ side for sharing data between CL and the host.
*Find a way to add include guards
