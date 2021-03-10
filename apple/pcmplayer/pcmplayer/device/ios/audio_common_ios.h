//
//  audio_common_ios.hpp
//  mediasdk
//
//  Created by cort xu on 2020/6/4.
//  Copyright © 2020 cortxu. All rights reserved.
//
#pragma once
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#include <stdint.h>

@interface AudioDeviceMgr : NSObject
+ (AudioDeviceMgr *)sharedInstance;
- (bool) initAudio;
- (void) activeAudio;
@end

namespace hilive {
namespace media {

class AudioCommonIos {
public:
    static bool CreateEngine();
    static void Active();
    static void ReleaseEngine();
    
private:
    static int                     audio_engine_ref_count_;
};

}
}
