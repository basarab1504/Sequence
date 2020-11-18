#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <ctime>
#include <stdio.h>
#include <iostream>
#include <string>

__global__ void squareKernel(int* data, int N);

int main(int argc, char** argv)
{
	int* h_data;
	int* d_data;
	//количество квадратов + 1
	int n = 10;
	std::string name;

	// выделяем page-locked память на хосте
	// эту функцию лучше всего использовать экономно для выделения промежуточных областей для обмена данными между хостом и устройством.
	cudaHostAlloc(&h_data, n * sizeof(int), cudaHostAllocPortable);

	//cudaMemcpy(h_data, arr, n * sizeof(int), cudaMemcpyHostToDevice);

	// выделяем память на устройстве
	cudaMalloc(&d_data, n * sizeof(int));

	dim3 block(512);
	dim3 grid((n + block.x - 1) / block.x);

	//grid - количество блоков
	//block - размер блока
	squareKernel<<<grid, block>>>(d_data, n);

	//копируем данные с устройства (d_data) на хост (h_data)
	cudaMemcpy(h_data, d_data, n * sizeof(int), cudaMemcpyDeviceToHost);

	for (int j = 0; j < n; j++)
	{
		name += std::to_string(h_data[j]);
	}

	for (int j = 1; j < name.size()-1; j+=2)
	{
		std::cout << name[j] << name[j+1] << std::endl;
	}

	return 0;
}

__global__ void squareKernel(int* data, int N)
{
	//threadIdx – номер нити в блоке
	//blockIdx – номер блока, в котором находится нить
	//blockDim – размер блока

	//глобальный индекс нити внутри сети
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	data[i] = powf(2, threadIdx.x);
}
