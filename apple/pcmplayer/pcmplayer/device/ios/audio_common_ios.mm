//
//  audio_common_ios.cpp
//  mediasdk
//
//  Created by cort xu on 2020/6/4.
//  Copyright © 2020 cortxu. All rights reserved.
//

#include "audio_common_ios.h"

@interface AudioDeviceMgr() {
}
@end

@implementation AudioDeviceMgr {
}

- (instancetype) init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(InterruptionNotification:) name:AVAudioSessionInterruptionNotification object:nil];
    }
    
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)InterruptionNotification:(NSNotification*)notification {
    NSLog(@"[hilive] InterruptionNotification %@", notification.userInfo);
}

+ (AudioDeviceMgr *)sharedInstance {
    static AudioDeviceMgr* instance = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        instance = [[self.class alloc] init];
    });
    
    return instance;
}

- (bool) initAudio {
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    if (!audioSession) {
        return false;
    }
    
    NSLog(@"[hilive] initAudio current category %@", audioSession.category);
    
    if ([audioSession.category isEqualToString:AVAudioSessionCategorySoloAmbient]) {
        NSError *error = nil;
        [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:(AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionDuckOthers) error:&error];
        //支持与其它app音频mix，系统智能调低其它app音量

        if (error) {
            NSLog(@"[hilive] initAudio setCategory error: %@", error);
            return false;
        }
    }
    
    NSError *error = nil;
    [audioSession setActive:YES error:&error];
    if (error) {
        NSLog(@"[hilive] initAudio setActive error: %@", error);
        return false;
    }
    
    return true;
}

- (void) activeAudio {
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    if (!audioSession) {
        return;
    }
    
    NSError *error = nil;
    [audioSession setActive:YES error:&error];
    if (error) {
        NSLog(@"[hilive] activeAudio setActive error: %@", error);
    }
}

@end



namespace hilive {
namespace media {


int AudioCommonIos::audio_engine_ref_count_ = 0;

bool AudioCommonIos::CreateEngine() {
    if (audio_engine_ref_count_ == 0) {
        if (![[AudioDeviceMgr sharedInstance] initAudio]) {
            return false;
        }
    }
    
    ++ audio_engine_ref_count_;
    return true;
}

void AudioCommonIos::Active() {
    [[AudioDeviceMgr sharedInstance] activeAudio];
}

void AudioCommonIos::ReleaseEngine() {
    -- audio_engine_ref_count_;
}

}
}
