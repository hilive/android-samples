//
//  audio_openal_ios.m
//  mediasdk
//
//  Created by cort xu on 2020/9/15.
//  Copyright © 2020 cortxu. All rights reserved.
//
#include "audio_openal_output_ios.h"
#include "audio_common_ios.h"

namespace hilive {
namespace media {

AudioOpenalOutputIos::AudioOpenalOutputIos(AudioOutputCallbacker* callbacker)
: AudioOutput(callbacker), device_(nullptr), context_(nullptr), output_source_id_(0), input_buffs_(nullptr), input_buff_cnt_(0), terminal_(false), thread_(nullptr) {
}

AudioOpenalOutputIos::~AudioOpenalOutputIos() {
    Uint();
}

bool AudioOpenalOutputIos::Init(const AudioOutputSources& input_sources, const AudioOutputSource& output_source) {
    do {
        if (inited_) {
            break;
        }

        if (!AudioCommonIos::CreateEngine()) {
            break;
        }

        AudioCommonIos::Active();

        device_ = alcOpenDevice(NULL);
        if (!device_) {
            break;
        }
        
        context_ = alcCreateContext(device_, NULL);
        if (!context_) {
            break;
        }
        
        alcMakeContextCurrent(context_);

        ALenum ret = alGetError();
        if(ret != AL_NO_ERROR) {
            break;
        }

        alGenSources(1, &output_source_id_);
        ret = alGetError();
        if(ret != AL_NO_ERROR) {
            break;
        }

        alSpeedOfSound(1.0);
        ret = alGetError();
        if(ret != AL_NO_ERROR) {
            break;
        }

        alDopplerVelocity(1.0);
        ret = alGetError();
        if(ret != AL_NO_ERROR) {
            break;
        }

        alDopplerFactor(1.0);
        ret = alGetError();
        if(ret != AL_NO_ERROR) {
            break;
        }
        
        alSourcef(output_source_id_, AL_PITCH, 1.0f);
        ret = alGetError();
        if(ret != AL_NO_ERROR) {
            break;
        }

        alSourcef(output_source_id_, AL_GAIN, 1.0f);
        ret = alGetError();
        if(ret != AL_NO_ERROR) {
            break;
        }

        alSourcei(output_source_id_, AL_LOOPING, AL_FALSE);
        ret = alGetError();
        if(ret != AL_NO_ERROR) {
            break;
        }

     //   alSourcef(output_source_id_, AL_SOURCE_TYPE, AL_STREAMING);//只读属性，设置多个音源时自动是streaming类型

        input_buff_cnt_ = (ALuint)input_sources.size();
        input_buffs_ = (ALuint*)malloc(sizeof(ALuint) * input_buff_cnt_);
        
        alGenBuffers(input_buff_cnt_, input_buffs_);
        
        ret = alGetError();
        if(ret != AL_NO_ERROR) {
            break;
        }

        for (uint32_t idx = 0; idx < input_buff_cnt_; ++ idx) {
            ALuint buff_id = input_buffs_[idx];

            auto& input_source = input_sources_[buff_id];
            input_source.source = input_sources[idx];

            ALenum fmt = AL_FORMAT_MONO16;
            if (input_source.source.channel == 2) {
                fmt = AL_FORMAT_STEREO16;
            }

            alBufferData(buff_id, fmt, input_source.buff, input_source.kBuffSize, input_source.source.samplerate);
            alSourceQueueBuffers(output_source_id_, 1, &buff_id);
        }
        
     //   alDistanceModel(AL_NONE);
        inited_ = true;
        
        thread_ = std::make_shared<std::thread>(&AudioOpenalOutputIos::OnThreadRun, this);
        return true;
    } while (false);
    
    return false;
}

bool AudioOpenalOutputIos::Start() {
    do {
        if (!inited_) {
            break;
        }
        
        if (started_) {
            break;
        }
        
        int state = 0;
        alGetSourcei(output_source_id_, AL_SOURCE_STATE, &state);

        if (state != AL_PLAYING) {
            alSourcePlay(output_source_id_);
            int ret = 0;
            if ((ret = alGetError()) != AL_NO_ERROR) {
                break;
            }

            ALint val = 0;
            alGetSourcei(output_source_id_, AL_SOURCE_STATE, &val);
            if (val != AL_PLAYING) {
            }
        }
        
        started_ = true;
    } while (false);
    
    return false;
}

bool AudioOpenalOutputIos::UpdateVolume(uint32_t bus_id, double volume) {
    return false;
}

bool AudioOpenalOutputIos::UpdateVolume(double volume) {
    do {
        if (!inited_) {
            break;
        }
        
        alSourcef(output_source_id_, AL_GAIN, volume);
    } while (false);
    
    return false;
}

void AudioOpenalOutputIos::Stop() {
    if (!inited_ || !started_) {
        return;
    }
    
    alSourceStop(output_source_id_);
    started_ = false;
}

void AudioOpenalOutputIos::Uint() {
    terminal_ = true;
    
    if (thread_) {
        thread_->join();
    }
    
    alSourceStop(output_source_id_);
    
    if (context_) {
        alcMakeContextCurrent(NULL);
        alcDestroyContext(context_);
    }
    
    if (device_) {
        alcCloseDevice(device_);
    }
    
    if (input_buffs_) {
        alDeleteBuffers(input_buff_cnt_, input_buffs_);
        free(input_buffs_);
    }
    
    alDeleteSources(1, &output_source_id_);
    
    context_ = nullptr;
    device_ = nullptr;
    input_buff_cnt_ = 0;
    input_buffs_ = nullptr;
    output_source_id_ = 0;
    thread_ = nullptr;
}

void AudioOpenalOutputIos::OnThreadRun() {
    while (!terminal_) {
        std::this_thread::sleep_for(std::chrono::milliseconds(5));

        if (!started_) {
            continue;
        }

        ALint processed = 0;
        alGetSourcei(output_source_id_, AL_BUFFERS_PROCESSED, &processed);

        while (processed --) {
            ALuint buff_id = 0;
            alSourceUnqueueBuffers(output_source_id_, 1, &buff_id);

            ProcessCallback(buff_id);
        }

        ALint val = 0;
        alGetSourcei(output_source_id_, AL_SOURCE_STATE, &val);
        if (val != AL_PLAYING) {
            alSourcePlay(output_source_id_);
       //     LOGD(logger_wrapper_, "palystatus: %u", val);
        }
    }
}

void AudioOpenalOutputIos::ProcessCallback(uint32_t bus_id) {
    auto it = input_sources_.find(bus_id);
    if (it == input_sources_.end()) {
        return;
    }
    
    auto& source = it->second;

    uint32_t data_size = source.kBuffSize;
    uint32_t ret = OutputCallback(source.source.bus_id, source.buff, source.kBuffSize);
    if (ret > 0) {
        data_size = ret;
    }

    ALenum fmt = AL_FORMAT_MONO16;
    if (source.source.channel == 2) {
        fmt = AL_FORMAT_STEREO16;
    }
    
    alBufferData(bus_id, fmt, source.buff, data_size, source.source.samplerate);
    alSourceQueueBuffers(output_source_id_, 1, &bus_id);
}

}
}

