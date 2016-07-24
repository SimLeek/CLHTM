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

int main() {

    //CREATE OPENCL CONTEXT
    std::vector<cl::Platform> platforms;

    cl::Platform::get(&platforms);

    if(platforms.size() ==0){
        std::cout<<"No OpenCL platforms found.\n";
        return 1;
    }

    std::vector<cl::Device> devices;

    platforms[0].getDevices(CL_DEVICE_TYPE_ALL, &devices);

    cl::Device device = devices[0];

    std::cout << "Using device: " << device.getInfo<CL_DEVICE_NAME>() << std::endl;
    std::cout << "Using platform: " << platforms[0].getInfo<CL_PLATFORM_NAME>() << std::endl;

    cl::Context context(device);

    //READY ITEMS FOR SENDING TO CL
    /*cl::Buffer buffer_random_seed(context, CL_MEM_READ_WRITE, sizeof(cl_ulong));
    cl::Buffer buffer_num_results(context, CL_MEM_READ_WRITE, sizeof(cl_uint));*/


    cl_ulong random_seed =5738495793284758564;
    cl_uint num_results = 300000000;

    cl_uint * random_results = new cl_uint[num_results];

    cl::Buffer buffer_random_results(context, CL_MEM_READ_WRITE, sizeof(cl_uint)*(num_results));

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

    //queue.enqueueWriteBuffer(buffer_random_seed, CL_TRUE, 0, sizeof(cl_ulong)*1, random_seed);
    //queue.enqueueWriteBuffer(buffer_num_results, CL_TRUE, 0, sizeof(cl_uint)*1, num_results);

    cl::Kernel random(program, "random");

    random.setArg(0,random_seed);
    random.setArg(1,buffer_random_results);

    queue.finish();

    //RUN
    cl::Event e;

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
        return 1;
    }

    e.wait();

    queue.enqueueReadBuffer(buffer_random_results, CL_TRUE, 0, sizeof(cl_uint)*(num_results), random_results);

    std::cout<<"Results: \n";
    for(int i=0;i<num_results;i++){
        std::cout<<random_results[i]<<"\n";
    }
    return 0;
}