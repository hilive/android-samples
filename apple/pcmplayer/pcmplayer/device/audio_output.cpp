//
//  audio_output.cpp
//  mediasdk
//
//  Created by cort xu on 2020/9/9.
//  Copyright © 2020 cortxu. All rights reserved.
//

#include "audio_output.h"
#include "../device/ios/audio_unit_output_ios.h"
#include "../device/ios/audio_openal_output_ios.h"

namespace hilive {
namespace media {

std::shared_ptr<AudioOutput> AudioOutput::Create(AudioOutputCallbacker* output_callbacker, uint32_t mode) {
  
#if defined(HILIVE_SYS_ANDROID)
    return std::make_shared<AudioSlesOutputAndroid>(output_callbacker);
#elif defined(HILIVE_SYS_IOS)
    if (mode == 0) {//default
        return std::make_shared<AudioUnitOutputIos>(output_callbacker);
    } else if (mode == 1) {//openal
        return std::make_shared<AudioOpenalOutputIos>(output_callbacker);
    }
#else
#endif

    return nullptr;
}

AudioOutput::AudioOutput(AudioOutputCallbacker* output_callbacker) : output_callbacker_(output_callbacker) {
}

AudioOutput::~AudioOutput() {
  delete output_callbacker_;
  output_callbacker_ = nullptr;
}

void AudioOutput::OnTimerUpdate(uint32_t timer_id, uint64_t us_now) {
}

uint32_t AudioOutput::OutputCallback(uint32_t bus_id, uint8_t* data, uint32_t data_size) {
    return output_callbacker_->OnAudioOutputBuffCB(bus_id, data, data_size);
}

}
}
