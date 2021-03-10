//
//  audio_output_callbacker.h
//  mediasdk
//
//  Created by cort xu on 2020/9/9.
//  Copyright © 2020 cortxu. All rights reserved.
//

#pragma once
#include <stdint.h>


namespace hilive {
namespace media {

#define AUDIO_PLAYER_BUFF_SIZE  4096


class AudioOutputCallbacker {
public:
    AudioOutputCallbacker() {}
    virtual ~AudioOutputCallbacker() {}

public:
    virtual uint32_t OnAudioOutputBuffCB(uint32_t bus_id, uint8_t* data, uint32_t data_size) { return 0; }
};

}
}
