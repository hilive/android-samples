//
//  main.cpp
//  mem-test
//
//  Created by cort xu on 2020/8/12.
//  Copyright © 2020 cort xu. All rights reserved.
//

#include <iostream>
#include <time.h>
#include <sys/time.h>

uint64_t GetUsTickCount() {
    struct timeval now;
    gettimeofday(&now, NULL);
    return (uint64_t)now.tv_sec * 1000000 + now.tv_usec;
}


int main(int argc, const char * argv[]) {
    const uint32_t kBuffSize = 720 * 1280 * 4;
    const uint32_t kTestTimes = 10000;

    {
        uint64_t start_stamp = GetUsTickCount();
        
        uint32_t i = 0;
        while (i ++ < kTestTimes) {
            uint8_t* data = (uint8_t*)malloc(kBuffSize);
            free(data);
        }
        
        uint64_t spent = GetUsTickCount() - start_stamp;

        printf("%d spent: %llu avg: %llu\n", __LINE__, spent, spent / kTestTimes);
    }

    {
        uint64_t start_stamp = GetUsTickCount();
        
        uint32_t i = 0;
        while (i ++ < kTestTimes) {
            uint8_t* data = (uint8_t*)malloc(kBuffSize);
            memset(data, 0, kBuffSize);
            free(data);
        }
        
        uint64_t spent = GetUsTickCount() - start_stamp;

        printf("%d spent: %llu avg: %llu\n", __LINE__, spent, spent / kTestTimes);
    }

    {
        uint8_t* src = (uint8_t*)malloc(kBuffSize);

        uint64_t start_stamp = GetUsTickCount();
        
        uint32_t i = 0;
        while (i ++ < kTestTimes) {
            uint8_t* data = (uint8_t*)malloc(kBuffSize);
            memcpy(data, src, kBuffSize);
            free(data);
        }
        
        uint64_t spent = GetUsTickCount() - start_stamp;
        
        free(src);

        printf("%d spent: %llu avg: %llu\n", __LINE__, spent, spent / kTestTimes);
    }
    
    return 0;
}
