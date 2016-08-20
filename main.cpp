#define __CL_ENABLE_EXCEPTIONS
#include <CL/cl.hpp>
#include <fstream>
#include <iostream>
#include <string>
#include <iterator>
#include <cmath>

#define VERBOSE
#ifdef VERBOSE
    #include <boost/preprocessor/stringize.hpp>
    #define PROBE(A) std::cout << BOOST_PP_STRINGIZE(A) << ": " << A << "\n"
template<class T>
inline void verbose(T& msg){std::cout<<msg;}
#else
    #define PROBE(A)
    #define verbose(A)
#endif

namespace cl {
//thanks: http://stackoverflow.com/a/24336429/782170
    const char *getErrorString(cl_int error) {
        switch (error) {
            // run-time and JIT compiler errors
            case 0:
                return "CL_SUCCESS";
            case -1:
                return "CL_DEVICE_NOT_FOUND";
            case -2:
                return "CL_DEVICE_NOT_AVAILABLE";
            case -3:
                return "CL_COMPILER_NOT_AVAILABLE";
            case -4:
                return "CL_MEM_OBJECT_ALLOCATION_FAILURE";
            case -5:
                return "CL_OUT_OF_RESOURCES";
            case -6:
                return "CL_OUT_OF_HOST_MEMORY";
            case -7:
                return "CL_PROFILING_INFO_NOT_AVAILABLE";
            case -8:
                return "CL_MEM_COPY_OVERLAP";
            case -9:
                return "CL_IMAGE_FORMAT_MISMATCH";
            case -10:
                return "CL_IMAGE_FORMAT_NOT_SUPPORTED";
            case -11:
                return "CL_BUILD_PROGRAM_FAILURE";
            case -12:
                return "CL_MAP_FAILURE";
            case -13:
                return "CL_MISALIGNED_SUB_BUFFER_OFFSET";
            case -14:
                return "CL_EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST";
            case -15:
                return "CL_COMPILE_PROGRAM_FAILURE";
            case -16:
                return "CL_LINKER_NOT_AVAILABLE";
            case -17:
                return "CL_LINK_PROGRAM_FAILURE";
            case -18:
                return "CL_DEVICE_PARTITION_FAILED";
            case -19:
                return "CL_KERNEL_ARG_INFO_NOT_AVAILABLE";

                // compile-time errors
            case -30:
                return "CL_INVALID_VALUE";
            case -31:
                return "CL_INVALID_DEVICE_TYPE";
            case -32:
                return "CL_INVALID_PLATFORM";
            case -33:
                return "CL_INVALID_DEVICE";
            case -34:
                return "CL_INVALID_CONTEXT";
            case -35:
                return "CL_INVALID_QUEUE_PROPERTIES";
            case -36:
                return "CL_INVALID_COMMAND_QUEUE";
            case -37:
                return "CL_INVALID_HOST_PTR";
            case -38:
                return "CL_INVALID_MEM_OBJECT";
            case -39:
                return "CL_INVALID_IMAGE_FORMAT_DESCRIPTOR";
            case -40:
                return "CL_INVALID_IMAGE_SIZE";
            case -41:
                return "CL_INVALID_SAMPLER";
            case -42:
                return "CL_INVALID_BINARY";
            case -43:
                return "CL_INVALID_BUILD_OPTIONS";
            case -44:
                return "CL_INVALID_PROGRAM";
            case -45:
                return "CL_INVALID_PROGRAM_EXECUTABLE";
            case -46:
                return "CL_INVALID_KERNEL_NAME";
            case -47:
                return "CL_INVALID_KERNEL_DEFINITION";
            case -48:
                return "CL_INVALID_KERNEL";
            case -49:
                return "CL_INVALID_ARG_INDEX";
            case -50:
                return "CL_INVALID_ARG_VALUE";
            case -51:
                return "CL_INVALID_ARG_SIZE";
            case -52:
                return "CL_INVALID_KERNEL_ARGS";
            case -53:
                return "CL_INVALID_WORK_DIMENSION";
            case -54:
                return "CL_INVALID_WORK_GROUP_SIZE";
            case -55:
                return "CL_INVALID_WORK_ITEM_SIZE";
            case -56:
                return "CL_INVALID_GLOBAL_OFFSET";
            case -57:
                return "CL_INVALID_EVENT_WAIT_LIST";
            case -58:
                return "CL_INVALID_EVENT";
            case -59:
                return "CL_INVALID_OPERATION";
            case -60:
                return "CL_INVALID_GL_OBJECT";
            case -61:
                return "CL_INVALID_BUFFER_SIZE";
            case -62:
                return "CL_INVALID_MIP_LEVEL";
            case -63:
                return "CL_INVALID_GLOBAL_WORK_SIZE";
            case -64:
                return "CL_INVALID_PROPERTY";
            case -65:
                return "CL_INVALID_IMAGE_DESCRIPTOR";
            case -66:
                return "CL_INVALID_COMPILER_OPTIONS";
            case -67:
                return "CL_INVALID_LINKER_OPTIONS";
            case -68:
                return "CL_INVALID_DEVICE_PARTITION_COUNT";

                // extension errors
            case -1000:
                return "CL_INVALID_GL_SHAREGROUP_REFERENCE_KHR";
            case -1001:
                return "CL_PLATFORM_NOT_FOUND_KHR";
            case -1002:
                return "CL_INVALID_D3D10_DEVICE_KHR";
            case -1003:
                return "CL_INVALID_D3D10_RESOURCE_KHR";
            case -1004:
                return "CL_D3D10_RESOURCE_ALREADY_ACQUIRED_KHR";
            case -1005:
                return "CL_D3D10_RESOURCE_NOT_ACQUIRED_KHR";
            default:
                return "Unknown OpenCL error";
        }
    }
}

//now I can type std::cout<<vector! =P
//todo: move to it's own file
template<class T>
std::ostream& operator<<(std::ostream& os, std::vector<T>& v){
    typename std::vector<T>::iterator it;
    os<<"[ ";
    for(it=v.begin(); it!=v.end(); ++it){
        if(it!=v.begin()){
            os<<",";
        }
        os << " " << (*it);
    }
    os << "]";
    return os;
}

template<class A, class B>
std::ostream& operator<<(std::ostream& os, std::pair<A, B>& p){
    os<<"( "<< p.first << ", " << p.second << " )";
    return os;
};

std::ostream& operator<<(std::ostream& os, cl::Platform& cl_platform){
    os<<cl_platform.getInfo<CL_PLATFORM_NAME>();
    return os;
}

std::ostream& operator<<(std::ostream& os, cl::Device& cl_device){
    os<<cl_device.getInfo<CL_DEVICE_NAME>();
    return os;
}

std::string readFile(std::string fileName)
{
    std::ifstream t(fileName);
    std::string str((std::istreambuf_iterator<char>(t)), std::istreambuf_iterator<char>());
    return str;
}


class XYHashTester{
public:
    XYHashTester()
    {
        A= new int[10];
        B= new int[10];
        for(int i=0; i<size; ++i){
            A[i]=i;
            B[i]=i%3;
        }
    }

    void ready_buffer(cl::Context& context){
        try{
            verbose("Creating buffer...\n");
                    cl_int err;
            buffer_A = cl::Buffer(context, CL_MEM_READ_WRITE, sizeof(int) * size);
            buffer_B = cl::Buffer(context, CL_MEM_READ_WRITE, sizeof(int) * size);
            buffer_C = cl::Buffer(context, CL_MEM_READ_WRITE, sizeof(int) * size);
        }catch(cl::Error& e){
            std::cout<<"Error: "<<cl::getErrorString(e.err())<<";"<<"\n";
            throw(e);
        }
    }

    void ready_kernel(cl::Program& program, cl::CommandQueue& queue){

        queue.enqueueWriteBuffer(buffer_A, CL_TRUE, 0, sizeof(int) * size, A);
        queue.enqueueWriteBuffer(buffer_B, CL_TRUE, 0, sizeof(int) * size, B);

        kernel = cl::Kernel(program, "hash_add_test");//todo:template name or other

        kernel.setArg(0, buffer_A);
        kernel.setArg(1, buffer_B);
        kernel.setArg(2, buffer_C);
    }

    void ready_queue(cl::CommandQueue& queue, cl::Event& e){
        try {
            queue.enqueueNDRangeKernel(kernel, cl::NullRange, cl::NDRange(size), cl::NullRange, 0, &e);
        }catch(cl::Error e) {
            std::cout<<"Error: "<<cl::getErrorString(e.err())<<";"<<e.what()<<"\n";
            return;
        }
    }

    void read_output(cl::CommandQueue& queue){
        queue.enqueueReadBuffer(buffer_C, CL_TRUE, 0, sizeof(int) * size, C);

//prints the array
        std::cout << "Result:" << std::endl;
        for (int i = 0; i < size; i++)
        {
            std::cout << A[i] << " + " << B[i] << " = " << C[i] << std::endl;
        }
    }


private:
    static const int size = 10;
    int* A;
    int* B;
    int C[size];

protected:
    cl::Buffer buffer_A, buffer_B, buffer_C;

    cl::Kernel kernel;
};

//todo: make 'templated' to test different numeric types using the -D compiler option.
class JavaRandomTester{
public:
    JavaRandomTester():
            random_seed(5738495546584)
    {
    }

    void ready_buffer(cl::Context& context){
        buffer_random_results=cl::Buffer(context, CL_MEM_READ_WRITE, sizeof(cl_ulong)*num_results);
    }

    void ready_kernel(cl::Program& program){
        verbose("setting kernel to rng\n");
        kernel=cl::Kernel(program, "random_number_generator_test");

        verbose("setting kernel random seed\n");
        PROBE(random_seed);
        kernel.setArg(0,random_seed);
        verbose("setting kernel buffer\n");
        kernel.setArg(1,buffer_random_results);
        verbose("finished setting stuff\n");
    }

    void ready_queue(cl::Device& device, cl::CommandQueue& queue, cl::Event& e) {
        /*std::vector<size_t> work_item_sizes;
        cl_device_info info = CL_DEVICE_MAX_WORK_ITEM_SIZES;
        cl_int err = device.getInfo(info, &work_item_sizes);
        std::cout << "work item sizes 0: " << work_item_sizes[0] << "\n";
        std::cout << "work item sizes 1: " << work_item_sizes[1] << "\n";

        size_t x_size = work_item_sizes[0];
        size_t y_size = work_item_sizes[0];

        info = CL_DEVICE_MAX_WORK_GROUP_SIZE;
        size_t work_group_size;
        err = device.getInfo(info, &work_group_size);
        std::cout << "work group size:" << work_group_size << "\n";

        x_size = (sqrt(work_group_size) < x_size) ? (size_t) sqrt(work_group_size) : x_size;
        y_size = (sqrt(work_group_size) < y_size) ? (size_t) sqrt(work_group_size) : y_size;

        try {
            queue.enqueueNDRangeKernel(kernel,
                                       cl::NullRange,
                                       cl::NDRange(num_results / work_group_size),
                                       cl::NDRange(work_group_size),
                                       0,
                                       &e
            );
        } catch (cl::Error e) {
            std::cout << "Error: " << cl::getErrorString(e.err()) << ";" << e.what() << "\n";
            throw(e);
        }*/

        try {
            queue.enqueueNDRangeKernel(kernel, cl::NullRange, cl::NDRange(num_results), cl::NullRange, 0, &e);
        }catch(cl::Error e) {
            std::cout<<"Error: "<<cl::getErrorString(e.err())<<";"<<e.what()<<"\n";
            return;
        }
    }

    void read_output(cl::CommandQueue& queue){
        verbose("Enqueing Read Buffer...");
        try {
            queue.enqueueReadBuffer(buffer_random_results, CL_TRUE, 0, sizeof(cl_ulong)*num_results, random_results);
        }catch(cl::Error e) {
            std::cout<<"Error: "<<cl::getErrorString(e.err())<<";"<<e.what()<<"\n";
            throw(e);
        }

        std::cout<<"Random results: \n";
        for(int i=0; i<num_results; ++i){
            std::cout<<random_results[i]<<"\n";
        }
    }

private:
    cl_ulong random_seed;
    static const size_t num_results = 300;
    cl::Buffer buffer_random_results;
    cl_ulong random_results[num_results];
    cl::Kernel kernel;
};

int main(int arg, char* args[])
{
    //CREATE OPENCL CONTEXT
    std::vector<cl::Platform> platforms;

    cl::Platform::get(&platforms);
    std::cout<<"Platforms: "<<platforms<<"\n";

    if (platforms.size() == 0)
    {
        std::cout << "No OpenCL platforms found" << std::endl;//This means you do not have an OpenCL compatible platform on your system.
        exit(1);
    }

    std::vector<cl::Device> devices;

    platforms[0].getDevices(CL_DEVICE_TYPE_ALL, &devices);
    std::cout<<"Devices: "<<devices<<"\n";
    cl::Device device = devices[0];

    std::cout << "Using device: " << device.getInfo<CL_DEVICE_NAME>() << std::endl;
    std::cout << "Using platform: " << platforms[0].getInfo<CL_PLATFORM_NAME>() << std::endl;

    cl::Context context(device);

    //OPEN CL FILE AND COMPILE
    cl::Program::Sources sources;
    verbose("Reading cl file into string...\n");

    std::string kernel_code = readFile("library_tester.cl");

    sources.push_back({ kernel_code.c_str(),kernel_code.length() });

    verbose("Creating program object...\n");

    cl::Program program;
    try{
        program = cl::Program(context, sources);
    }catch(cl::Error& e){
        std::cout<<"Error: "<<cl::getErrorString(e.err())<<";"<<e.what()<<"\n";
        return e.err();
    }

    try{
        verbose("Building program...\n");
        int err = program.build({device},"-I . -I C:\\msys64\\mingw64\\include");
        if(err!=CL_SUCCESS){
            std::cout<<"Error building: \n"<< program.getBuildInfo<CL_PROGRAM_BUILD_LOG>(device, &err) <<"\n";
        }
    }catch(cl::Error& e){
        std::cout<<"Error: "<<cl::getErrorString(e.err())<<";"<<e.what()<<"\n";
        std::cout<<"Error building: \n"<< program.getBuildInfo<CL_PROGRAM_BUILD_LOG>(device) <<"\n";
        return e.err();
    }

    //Create command queue using our OpenCL context and device
    cl::CommandQueue queue(context, device, NULL, NULL);

    //XYHashTest
    verbose("creating XYHashTester class...\n");
    XYHashTester xy_test;
    verbose("readying buffer for XYHashTester class...\n");
    xy_test.ready_buffer(context);
    verbose("readying kernel for XYHashTester class...\n");
    xy_test.ready_kernel(program, queue);

    queue.finish();
    cl::Event e;
    xy_test.ready_queue(queue, e);
    e.wait();
    xy_test.read_output(queue);

    //JavaRandomTest
    verbose("creating JavaRandomTester class...\n");
    JavaRandomTester java_rand_test;
    verbose("readying buffer for JavaRandomTester class...\n");
    java_rand_test.ready_buffer(context);
    verbose("readying kernel for JavaRandomTester class...\n");
    java_rand_test.ready_kernel(program);
    verbose("kernel is readied.");
    queue.finish();
    //cl::Event e;
    java_rand_test.ready_queue(device, queue, e);
    e.wait();
    java_rand_test.read_output(queue);

    return 0;
}