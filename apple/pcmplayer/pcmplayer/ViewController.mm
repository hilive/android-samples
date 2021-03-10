//
//  ViewController.m
//  pcmplayer
//
//  Created by cort xu on 2021/3/10.
//

#import "ViewController.h"
#include "device/audio_output.h"
#include <stdio.h>

using namespace hilive::media;

int g_channels = 1;
int g_samplerate = 16000;
MediaFormat g_media_format = kMediaFormatAudioS8;

class AudioOutputCallbackerIos : public AudioOutputCallbacker {
 public:
  AudioOutputCallbackerIos(const char* file_path) {
    fp_ = fopen(file_path, "rb");
  }
  virtual ~AudioOutputCallbackerIos() {
    if (fp_) {
      fclose(fp_);
      fp_ = nullptr;
    }
  }

 public:
  uint32_t OnAudioOutputBuffCB(uint32_t bus_id, uint8_t* data, uint32_t data_size) override {
    if (!fp_) {
      return 0;
    }

    size_t ret = fread(data, 1, data_size, fp_);
    if (ret <= 0) {
      fseek(fp_, 0, SEEK_SET);
      ret = 0;
    }

    size_t cnt = ret / 1;
    uint8_t* ptr = (uint8_t*)data;
    printf("bytes:");
    for (int i = 0; i < cnt && i < 6; ++ i) {
        printf(" %d", data[i]);
    }
    printf("\r\n");

    return (uint32_t)ret;
  }

 private:
  FILE* fp_;
};

@interface ViewController ()

@end

@implementation ViewController {
  std::shared_ptr<AudioOutput> audio_output_;

}

- (void)viewDidLoad {
  [super viewDidLoad];

//  NSString* res = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/pcm/t.wav"];
  NSString* res = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/pcm/tmp.pcm"];
  audio_output_ = AudioOutput::Create(new AudioOutputCallbackerIos([res UTF8String]));
}

- (IBAction)onClickPlay:(id)sender {
  audio_output_->Uint();

  AudioOutputSource source;
  source.channel = g_channels;
  source.samplerate = g_samplerate;
  source.format = g_media_format;

  AudioOutputSources input_sources;
  input_sources.push_back(source);

  audio_output_->Init(input_sources, source);
  audio_output_->Start();
  audio_output_->UpdateVolume(0.3);
}

@end
