//todo: optimize rangom number generator
//todo: implement other nupic util algorthim

#define __CL_ENABLE_EXCEPTIONS
#include <CL/cl.hpp>
#include <fstream>
#include <iostream>
#include <string>
#include <iterator>
#include <math.h>


std::string readFile(std::string filename){
    std::ifstream ifs(filename);
    std::string str((std::istreambuf_iterator<char>(ifs)), std::istreambuf_iterator<char>());
    return str;
}

//now I can type std::cout<<vector! =P
//todo: move to it's own file
template<class T>
std::ostream& operator<<(std::ostream& os, std::vector<T>& v){
    typename std::vector<T>::iterator it;
    os<<"[ ";
    for(it=v.begin(); it!=v.end(); ++it){
        os << " " << (*it) << ((++it)!=v.end())?",":"";
        --it;
    }
    os << "]";
    return os;
}

std::ostream& operator<<(std::ostream& os, cl::Platform& cl_platform){
    os<<cl_platform.getInfo<CL_PLATFORM_NAME>();
    return os;
}

std::ostream& operator<<(std::ostream& os, cl::Device& cl_device){
    os<<cl_device.getInfo<CL_DEVICE_NAME>();
    return os;
}

class RandomProgram{
public:
    RandomProgram():
            random_seed(5738495793284758564),
            num_results(300000000),
            random_results(new cl_uint[num_results])
    {
    }

    void ready_buffer(cl::Context& context){
        buffer_random_results=cl::Buffer(context, CL_MEM_READ_WRITE, sizeof(cl_uint)*(num_results));
    }

    void ready_kernel(cl::Program& program){
        random=cl::Kernel(program, "random");

        random.setArg(0,random_seed);
        random.setArg(1,buffer_random_results);


    }

    void ready_queue(cl::Device& device, cl::CommandQueue& queue, cl::Event& e){

        //queue.enqueueWriteBuffer(buffer_random_seed, CL_TRUE, 0, sizeof(cl_ulong)*1, random_seed);
        //queue.enqueueWriteBuffer(buffer_num_results, CL_TRUE, 0, sizeof(cl_uint)*1, num_results);

        std::vector<size_t> work_item_sizes;
        cl_device_info info = CL_DEVICE_MAX_WORK_ITEM_SIZES;
        cl_int err = device.getInfo(info, &work_item_sizes);
        std::cout<<"work item sizes 0:"<<work_item_sizes[0]<<"\n";
        std::cout<<"work item sizes 1:"<<work_item_sizes[1]<<"\n";

        size_t x_size = work_item_sizes[0];
        size_t y_size = work_item_sizes[0];

        info = CL_DEVICE_MAX_WORK_GROUP_SIZE;
        size_t work_group_size;
        err = device.getInfo(info, &work_group_size);
        std::cout<<"work group size:"<<work_group_size<<"\n";

        x_size = (sqrt(work_group_size)<x_size)?(size_t)sqrt(work_group_size):x_size;
        y_size = (sqrt(work_group_size)<y_size)?(size_t)sqrt(work_group_size):y_size;


        try {
            queue.enqueueNDRangeKernel(random, cl::NullRange, cl::NDRange(num_results/work_group_size), cl::NDRange(work_group_size), 0, &e);
        }catch(cl::Error e) {
            std::cout<<"Error: "<<e.err()<<";"<<e.what()<<"\n";
            return;
        }
    }

    void read_output(cl::CommandQueue& queue){
        queue.enqueueReadBuffer(buffer_random_results, CL_TRUE, 0, sizeof(cl_uint)*(num_results), random_results);

        std::cout<<"Results: \n";
        for(int i=0;i<num_results;i++){
            std::cout<<random_results[i]<<"\n";
        }
    }

private:
    cl_ulong random_seed;
    cl_uint num_results;
    cl_uint * random_results;
    cl::Buffer buffer_random_results;
    cl::Kernel random;
};







class VectorTestProgram{
public:
    VectorTestProgram():
            max_tests(20),
            max_message_size(100),
            test_results(new cl_char*[max_tests])
    {
        for(int i=0; i<max_tests;++i){
            test_results[i]= new cl_char[max_message_size];
        }
    }

    void ready_buffer(cl::Context& context){
        buffer_test_results=cl::Buffer(context, CL_MEM_READ_WRITE, sizeof(cl_char)*(max_tests)*(max_message_size));
    }

    void ready_kernel(cl::Program& program){
        kernel=cl::Kernel(program, "vector_test");

        kernel.setArg(0,buffer_test_results);
    }

    void ready_queue(cl::Device& device, cl::CommandQueue& queue, cl::Event& e){

        //queue.enqueueWriteBuffer(buffer_random_seed, CL_TRUE, 0, sizeof(cl_ulong)*1, random_seed);
        //queue.enqueueWriteBuffer(buffer_num_results, CL_TRUE, 0, sizeof(cl_uint)*1, num_results);

        std::vector<size_t> work_item_sizes;
        cl_device_info info = CL_DEVICE_MAX_WORK_ITEM_SIZES;
        cl_int err = device.getInfo(info, &work_item_sizes);
        std::cout<<"work item sizes 0:"<<work_item_sizes[0]<<"\n";
        std::cout<<"work item sizes 1:"<<work_item_sizes[1]<<"\n";

        size_t x_size = work_item_sizes[0];
        size_t y_size = work_item_sizes[0];

        info = CL_DEVICE_MAX_WORK_GROUP_SIZE;
        size_t work_group_size;
        err = device.getInfo(info, &work_group_size);
        std::cout<<"work group size:"<<work_group_size<<"\n";

        x_size = (sqrt(work_group_size)<x_size)?(size_t)sqrt(work_group_size):x_size;
        y_size = (sqrt(work_group_size)<y_size)?(size_t)sqrt(work_group_size):y_size;


        try {
            queue.enqueueNDRangeKernel(kernel, cl::NullRange, cl::NDRange(max_tests/work_group_size), cl::NDRange(work_group_size), 0, &e);
        }catch(cl::Error e) {
            std::cout<<"Error: "<<e.err()<<";"<<e.what()<<"\n";
            return;
        }
    }

    void read_output(cl::CommandQueue& queue){
        queue.enqueueReadBuffer(buffer_test_results, CL_TRUE, 0, sizeof(cl_char)*(max_tests)*(max_message_size), test_results);

        std::cout<<"Results: \n";
        for(int i=0;i<max_tests;i++){
            std::cout<<test_results[i]<<"\n";
        }
    }

private:
    cl_uint max_tests;
    cl_uint max_message_size;
    cl_char ** test_results;
    cl::Buffer buffer_test_results;
    cl::Kernel kernel;
};

int main() {

    //CREATE OPENCL CONTEXT
    std::vector<cl::Platform> platforms;

    cl::Platform::get(&platforms);
    std::cout<<"Platforms: "<<platforms;

    if(platforms.size() ==0){
        std::cout<<"No OpenCL platforms found.\n";
        return 1;
    }

    std::vector<cl::Device> devices;

    platforms[0].getDevices(CL_DEVICE_TYPE_ALL, &devices);
    std::cout<<"Devices: "<<devices;

    cl::Device device = devices[0];

    std::cout << "Using device: " << device.getInfo<CL_DEVICE_NAME>() << std::endl;
    std::cout << "Using platform: " << platforms[0].getInfo<CL_PLATFORM_NAME>() << std::endl;

    cl::Context context(device);

    //READY ITEMS FOR SENDING TO CL
    /*cl::Buffer buffer_random_seed(context, CL_MEM_READ_WRITE, sizeof(cl_ulong));
    cl::Buffer buffer_num_results(context, CL_MEM_READ_WRITE, sizeof(cl_uint));*/
    VectorTestProgram prog;
    prog.ready_buffer(context);

    //OPEN CL FILE AND COMPILE
    cl::Program::Sources sources;
    std::string kernal_code = readFile("Main.cl");

    sources.push_back({kernal_code.c_str(), kernal_code.length()});

    cl::Program program(context, sources);

    try{
        int err = program.build({device});
        if(err!=CL_SUCCESS){
            std::cout<<"Error building: \n"<< program.getBuildInfo<CL_PROGRAM_BUILD_LOG>(device, &err) <<"\n";
        }
    }catch(cl::Error e){
        std::cout<<"Error: "<<e.err()<<";"<<e.what()<<"\n";
        //std::cout<<"Error building: \n"<< program.getBuildInfo<CL_PROGRAM_BUILD_LOG>(device) <<"\n";
        return 1;
    }


    //CL COMMAND QUEUE
    cl::CommandQueue queue(context, device, NULL, NULL);

    prog.ready_kernel(program);

    queue.finish();

    //RUN
    cl::Event e;

    prog.ready_queue(device, queue, e);

    e.wait();

    prog.read_output(queue);

    return 0;
}