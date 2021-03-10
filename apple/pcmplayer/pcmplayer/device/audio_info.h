//
//  audio_info.h
//  pcmplayer
//
//  Created by cort xu on 2021/3/10.
//

#pragma once
#include <stdint.h>

namespace hilive {
namespace media {


enum MediaFormat {
    kMediaFormatNone = -1,
    kMediaFormatVideoYuvBegin = 0,
    kMediaFormatVideoYuv420p = 1,
    kMediaFormatVideoNv12 = 2,
    kMediaFormatVideoNv21 = 3,
    kMediaFormatVideoYuvJ420p = 4,
    kMediaFormatVideoYuvEnd,
    
    kMediaFormatVideoPixelBegin = 49,
    kMediaFormatVideoRgb24 = 50,
    kMediaFormatVideoBgr24 = 51,
    kMediaFormatVideoRgba32 = 52,
    kMediaFormatVideoBgra32 = 53,
    kMediaFormatVideoArgb32 = 54,
    kMediaFormatVideoAbgr32 = 55,
    kMediaFormatVideoPixelEnd,
    
    kMediaFormatAudioBegin = 100,
    kMediaFormatAudioS8,//signed 8 bits
    kMediaFormatAudioS16,//signed 16 bits
    kMediaFormatAudioS32,//signed 32 bits
    kMediaFormatAudioFlt,//float
    kMediaFormatAudioDbl,//double
    kMediaFormatAudioS8p,//signed 8 bits, planar
    kMediaFormatAudioS16p,//signed 16 bits, planar
    kMediaFormatAudioS32p,//signed 32 bits, planar
    kMediaFormatAudioFltp,//float, planar
    kMediaFormatAudioDblp,//double, planar
    kMediaFormatAudioEnd,
};

}
}
