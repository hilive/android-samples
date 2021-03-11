//
//  audio_player_ios.cpp
//  mediasdk
//
//  Created by cort xu on 2020/6/4.
//  Copyright © 2020 cortxu. All rights reserved.
//

#include "audio_unit_output_ios.h"
#include "audio_common_ios.h"

namespace hilive {
namespace media {

#define kOutputBus 0
#define kInputBus 1

static OSStatus PlayerCallback(void* inRefCon,
                               AudioUnitRenderActionFlags* ioActionFlags,
                               const AudioTimeStamp* inTimeStamp,
                               UInt32 inBusNumber,
                               UInt32 inNumberFrames,
                               AudioBufferList* ioData) {
    AudioUnitOutputIos* output = static_cast<AudioUnitOutputIos*>(inRefCon);
    output->ProcessCallback(ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, ioData);
    
    return noErr;
}

static void AudioUnitListener(void* inRefCon, AudioUnit inUnit, AudioUnitPropertyID inID, AudioUnitScope inScope, AudioUnitElement inElement) {
    AudioUnitOutputIos* output = static_cast<AudioUnitOutputIos*>(inRefCon);
    output->ListenerCallback(inUnit, inID, inScope, inElement);
}

AudioUnitOutputIos::AudioUnitOutputIos(AudioOutputCallbacker* callbacker)
: AudioOutput(callbacker), engine_inited_(false), graph_(nullptr), mix_node_(0), output_node_(0), mix_unit_(nullptr), output_unit_(nullptr) {
}

AudioUnitOutputIos::~AudioUnitOutputIos() {
    Uint();
}

bool AudioUnitOutputIos::Init(const AudioOutputSources& input_sources, const AudioOutputSource& output_source) {
    do {
        if (inited_) {
            break;
        }
        
        if (input_sources.empty()) {
            break;
        }
        
        if (!AudioCommonIos::CreateEngine()) {
            break;
        }

        AudioCommonIos::Active();
        
        engine_inited_ = true;
        OSStatus status = 0;
        
        if ((status = NewAUGraph(&graph_)) != 0) {
            break;
        }
        
        if ((status = AUGraphOpen(graph_)) != 0) {
            break;
        }
        
        AudioComponentDescription component_output_desc;
        bzero(&component_output_desc, sizeof(component_output_desc));
        component_output_desc.componentType = kAudioUnitType_Output;
        component_output_desc.componentSubType = kAudioUnitSubType_RemoteIO;
        component_output_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
        component_output_desc.componentFlags = 0;
        component_output_desc.componentFlagsMask = 0;
        
        if ((status = AUGraphAddNode(graph_, &component_output_desc, &output_node_)) != 0) {
            break;
        }
        
        if ((status = AUGraphNodeInfo(graph_, output_node_, &component_output_desc, &output_unit_)) != 0) {
            break;
        }
        
        UInt32 buff_size = 4096;
        if ((status = AudioUnitSetProperty(output_unit_, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &buff_size, sizeof(buff_size))) != 0) {
            break;
        }
        
        AudioStreamBasicDescription stream_output_desc = {0};
        stream_output_desc.mFormatID = kAudioFormatLinearPCM;
        stream_output_desc.mFramesPerPacket = 1;
        stream_output_desc.mSampleRate = output_source.samplerate;
        stream_output_desc.mChannelsPerFrame = output_source.channel;
        if (output_source.format == kMediaFormatAudioS16) {
            stream_output_desc.mBitsPerChannel = 16;
            stream_output_desc.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        } else {
            stream_output_desc.mBitsPerChannel = 32;
            stream_output_desc.mFormatFlags = kLinearPCMFormatFlagIsFloat | kAudioFormatFlagIsPacked;
        }
        stream_output_desc.mBytesPerFrame = stream_output_desc.mBitsPerChannel * stream_output_desc.mChannelsPerFrame / 8;
        stream_output_desc.mBytesPerPacket = stream_output_desc.mBytesPerFrame * stream_output_desc.mFramesPerPacket;
        stream_output_desc.mReserved = 0;
        
        if ((status = AudioUnitSetProperty(output_unit_,
                                           kAudioUnitProperty_StreamFormat,
                                           kAudioUnitScope_Input,
                                           0,
                                           &stream_output_desc,
                                           sizeof(stream_output_desc))) != 0) {
            break;
        }

        if ((status = AudioUnitAddPropertyListener(output_unit_, kAudioOutputUnitProperty_IsRunning, AudioUnitListener, this)) != 0) {
            break;
        }
        
        AudioComponentDescription component_mix_desc;
        bzero(&component_mix_desc, sizeof(component_mix_desc));
        component_mix_desc.componentType = kAudioUnitType_Mixer;
        component_mix_desc.componentSubType = kAudioUnitSubType_MultiChannelMixer;
        component_mix_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
        component_mix_desc.componentFlags = 0;
        component_mix_desc.componentFlagsMask = 0;
        
        if ((status = AUGraphAddNode(graph_, &component_mix_desc, &mix_node_)) != 0) {
            break;
        }
        
        if ((status = AUGraphNodeInfo(graph_, mix_node_, &component_mix_desc, &mix_unit_)) != 0) {
            break;
        }
        
        if ((status = AudioUnitSetProperty(mix_unit_, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &buff_size, sizeof(buff_size))) != 0) {
            break;
        }

        if ((status = AudioUnitSetProperty(mix_unit_,
                                           kAudioUnitProperty_StreamFormat,
                                           kAudioUnitScope_Output,
                                           kOutputBus,
                                           &stream_output_desc,
                                           sizeof(stream_output_desc))) != 0) {
            goto init_failed;
        }
        
        if ((status = AUGraphConnectNodeInput(graph_, mix_node_, 0, output_node_, 0)) != 0) {
            break;
        }
        
        uint32_t source_cnt = (uint32_t)input_sources.size();
        if ((status = AudioUnitSetProperty(mix_unit_, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &source_cnt, sizeof(source_cnt))) != 0) {
            break;
        }

        uint32_t buf_idx = 0;
        for (uint32_t idx = 0; idx < source_cnt; ++ idx) {
            buf_idx = idx;
            auto& source = input_sources[idx];
            
            AudioStreamBasicDescription stream_mix_desc = {0};
            stream_mix_desc.mFormatID = kAudioFormatLinearPCM;
            stream_mix_desc.mFramesPerPacket = 1;
            stream_mix_desc.mSampleRate = source.samplerate;
            stream_mix_desc.mChannelsPerFrame = source.channel;
            if (source.format == kMediaFormatAudioS16) {
                stream_mix_desc.mBitsPerChannel = 16;
                stream_mix_desc.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
            } else {
                stream_mix_desc.mBitsPerChannel = 32;
                stream_mix_desc.mFormatFlags = kLinearPCMFormatFlagIsFloat | kAudioFormatFlagIsPacked;
            }
            stream_mix_desc.mBytesPerFrame = stream_mix_desc.mChannelsPerFrame * stream_mix_desc.mBitsPerChannel / 8;
            stream_mix_desc.mBytesPerPacket = stream_mix_desc.mBytesPerFrame * stream_mix_desc.mFramesPerPacket;
            stream_mix_desc.mReserved = 0;
            
            if ((status = AudioUnitSetProperty(mix_unit_,
                                               kAudioUnitProperty_StreamFormat,
                                               kAudioUnitScope_Input,
                                               buf_idx,
                                               &stream_mix_desc,
                                               sizeof(stream_mix_desc))) != 0) {
                goto init_failed;
            }

            AURenderCallbackStruct callback;
            callback.inputProc = PlayerCallback;
            callback.inputProcRefCon = this;
            
            if ((status = AUGraphSetNodeInputCallback(graph_, mix_node_, buf_idx, &callback)) != 0) {
                goto init_failed;
            }
        }
        
        if ((status = AUGraphInitialize(graph_)) != 0) {
            break;
        }
        
        AudioOutputUnitStop(output_unit_);
        
        input_sources_ = input_sources;
        
        inited_ = true;
        return true;
    } while (false);

init_failed:

    return false;
}

bool AudioUnitOutputIos::Start() {
    do {
        if (!inited_) {
            break;
        }
        
        if (started_) {
            break;
        }
        
        OSStatus status = 0;
        if ((status = AUGraphStart(graph_)) != 0) {
            break;
        }
        
        if ((status = AudioOutputUnitStart(output_unit_)) != 0) {
            break;
        }
        
        UpdateVolume(volume_);
        started_ = true;
    } while (false);
    
    return started_;
}

bool AudioUnitOutputIos::UpdateVolume(uint32_t bus_id, double volume) {
    if (!inited_ || !started_) {
        return false;
    }
    
    volume_ = volume;
    
    AudioUnitSetParameter(mix_unit_, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, bus_id, volume, 0);
    return true;
}

bool AudioUnitOutputIos::UpdateVolume(double volume) {
    if (!inited_ || !started_) {
        return false;
    }
    
    volume_ = volume;
    
    AudioUnitSetParameter(mix_unit_, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, 0, volume, 0);
    return true;
}

void AudioUnitOutputIos::Stop() {
    if (!inited_ || !started_) {
        return;
    }
    
    AudioOutputUnitStop(output_unit_);
    AUGraphStop(graph_);
    started_ = false;
    last_stats_stamp_ = 0;
}

void AudioUnitOutputIos::Uint() {
    if (output_unit_) {
        AudioOutputUnitStop(output_unit_);
    }
    
    if (graph_) {
        AUGraphStop(graph_);
        AUGraphUninitialize(graph_);
    }
    
    if (engine_inited_) {
        AudioCommonIos::ReleaseEngine();
    }
    
    mix_unit_ = nullptr;
    output_unit_ = nullptr;
    last_stats_stamp_ = 0;
    mix_node_ = 0;
    output_node_ = 0;
    graph_ = nullptr;
    engine_inited_ = false;
    started_ = false;
    inited_ = false;
}

void AudioUnitOutputIos::ProcessCallback(AudioUnitRenderActionFlags* ioActionFlags,
                                           const AudioTimeStamp* inTimeStamp,
                                           UInt32 inBusNumber,
                                           UInt32 inNumberFrames,
                                           AudioBufferList* ioData) {
    uint8_t* data = (uint8_t*)ioData->mBuffers[0].mData;
    uint32_t size = ioData->mBuffers[0].mDataByteSize;
    memset(data, 0, size);

    if (inBusNumber >= input_sources_.size()) {
        return;
    }

    auto& source = input_sources_[inBusNumber];
    
    ioData->mBuffers[0].mDataByteSize = OutputCallback(source.bus_id, data, size);  
//    LOGI(logger_wrapper_, "%s bus: %u frames: %u", kDevicePrefix, inBusNumber, inNumberFrames);
}

void AudioUnitOutputIos::ListenerCallback(AudioUnit inUnit, AudioUnitPropertyID inID, AudioUnitScope inScope, AudioUnitElement inElement) {
}

}
}
