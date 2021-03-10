//
//  audio_openal_ios.h
//  mediasdk
//
//  Created by cort xu on 2020/9/15.
//  Copyright © 2020 cortxu. All rights reserved.
//

#pragma once
#include "../audio_output.h"
#include <OpenAL/OpenAL.h>
#include <unordered_map>

namespace hilive {
namespace media {

class AudioOpenalOutputIos : public AudioOutput {
    struct OpenalOutputSource {
        static const uint32_t       kBuffSize = 8192;
        uint8_t                     buff[kBuffSize] = {0};
        AudioOutputSource           source;
    };

    typedef std::unordered_map<ALuint, OpenalOutputSource> OpenalOutputSources;
    
public:
    AudioOpenalOutputIos(AudioOutputCallbacker* callbacker);
    ~AudioOpenalOutputIos();

public:
    bool Init(const AudioOutputSources& input_sources, const AudioOutputSource& output_source) override;
    bool Start() override;
    bool UpdateVolume(uint32_t bus_id, double volume) override;
    bool UpdateVolume(double volume) override;
    void Stop() override;
    void Uint() override;

private:
    void OnThreadRun();

private:
    void ProcessCallback(uint32_t bus_id);

private:
    OpenalOutputSources             input_sources_;
    ALCdevice*                      device_;
    ALCcontext*                     context_;
    ALuint                          output_source_id_;
    ALuint*                         input_buffs_;
    ALuint                          input_buff_cnt_;
    std::atomic_bool                terminal_;
    std::shared_ptr<std::thread>    thread_;
};

}
}
