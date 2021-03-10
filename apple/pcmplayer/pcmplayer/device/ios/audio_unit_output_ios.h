//
//  audio_player_ios.hpp
//  mediasdk
//
//  Created by cort xu on 2020/6/4.
//  Copyright © 2020 cortxu. All rights reserved.
//

#pragma once
#include "../audio_output.h"
#include <AudioToolbox/AUGraph.h>

namespace hilive {
namespace media {

class AudioUnitOutputIos : public AudioOutput {
public:
    AudioUnitOutputIos(AudioOutputCallbacker* callbacker);
    virtual ~AudioUnitOutputIos();
    
public:
    bool Init(const AudioOutputSources& input_sources, const AudioOutputSource& output_source) override;
    bool Start() override;
    bool UpdateVolume(uint32_t bus_id, double volume) override;
    bool UpdateVolume(double volume) override;
    void Stop() override;
    void Uint() override;
    
public:
    void ProcessCallback(AudioUnitRenderActionFlags* ioActionFlags,
                         const AudioTimeStamp* inTimeStamp,
                         UInt32 inBusNumber,
                         UInt32 inNumberFrames,
                         AudioBufferList* ioData);
    void ListenerCallback(AudioUnit inUnit, AudioUnitPropertyID inID, AudioUnitScope inScope, AudioUnitElement inElement);
    
private:
    bool                            engine_inited_;
    AUGraph                         graph_;
    AUNode                          mix_node_;
    AUNode                          output_node_;
    AudioUnit                       mix_unit_;
    AudioUnit                       output_unit_;
    AudioOutputSources              input_sources_;
};

}
}
