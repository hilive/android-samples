//
//  audio_output_device.h
//  mediasdk
//
//  Created by cort xu on 2020/9/9.
//  Copyright © 2020 cortxu. All rights reserved.
//
#pragma once
#include <stdint.h>
#include <future>
#include <vector>
#include "audio_info.h"
#include "audio_output_callbacker.h"

namespace hilive {
namespace media {

struct AudioOutputSource {
    uint32_t    bus_id = 0;
    uint32_t    channel = 2;
    uint32_t    samplerate = 44100;
    MediaFormat format = kMediaFormatAudioS16;//短整型兼容性最好
};

typedef std::vector<AudioOutputSource> AudioOutputSources;

class AudioOutput {
public:
    static std::shared_ptr<AudioOutput> Create(AudioOutputCallbacker* output_callbacker, uint32_t mode = 0);
    virtual ~AudioOutput();

protected:
    AudioOutput(AudioOutputCallbacker* output_callbacker);

public:
    void OnTimerUpdate(uint32_t timer_id, uint64_t us_now);

public:
    virtual bool Init(const AudioOutputSources& input_sources, const AudioOutputSource& output_source) = 0;
    virtual bool Start() = 0;
    virtual bool UpdateVolume(uint32_t bus_id, double volume) = 0;
    virtual bool UpdateVolume(double volume) = 0;
    virtual void Stop() = 0;
    virtual void Uint() = 0;

public:
    bool is_inited() const { return inited_; }
    bool is_started() const { return started_; }

protected:
    uint32_t OutputCallback(uint32_t bus_id, uint8_t* data, uint32_t data_size);

protected:
    AudioOutputCallbacker*          output_callbacker_;
    bool                            inited_ = false;
    bool                            started_ = false;
    double                          volume_ = 1.0;
    uint64_t                        last_stats_stamp_ = 0;
};

}
}
