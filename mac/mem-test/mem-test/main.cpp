//
//  main.cpp
//  mem-test
//
//  Created by cort xu on 2020/8/12.
//  Copyright © 2020 cort xu. All rights reserved.
//

#include <iostream>
#include <benchmark/benchmark.h>

const uint32_t kBuffSize = 720 * 1280 * 4;
const uint32_t kTestTimes = 10000;

void bm_malloc_test(benchmark::State& state) {
    auto size = state.range(0);
    for (auto _ : state) {
        uint8_t* data = (uint8_t*)malloc(size);
        free(data);
    }
}

BENCHMARK(bm_malloc_test)->Iterations(kTestTimes)->Arg(kBuffSize);

void bm_memset_test(benchmark::State& state) {
    auto size = state.range(0);
    for (auto _ : state) {
        uint8_t* data = (uint8_t*)malloc(size);
        memset(data, 0, size);
        free(data);
    }
}

BENCHMARK(bm_memset_test)->Iterations(kTestTimes)->Arg(kBuffSize);


void bm_memcpy_test(benchmark::State& state) {
    uint8_t* src = (uint8_t*)malloc(kBuffSize);

    auto size = state.range(0);
    for (auto _ : state) {
        uint8_t* data = (uint8_t*)malloc(size);
        memcpy(data, src, kBuffSize);
        free(data);
    }

    free(src);
}

BENCHMARK(bm_memcpy_test)->Iterations(kTestTimes)->Arg(kBuffSize);


BENCHMARK_MAIN();

