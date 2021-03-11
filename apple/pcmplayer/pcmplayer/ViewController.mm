//
//  ViewController.m
//  pcmplayer
//
//  Created by cort xu on 2021/3/10.
//

#import "ViewController.h"
#include "device/audio_output.h"
#include <stdio.h>
#include <deque>
#include <list>

using namespace hilive::media;

int g_channels = 1;
int g_samplerate = 22050;
MediaFormat g_media_format = kMediaFormatAudioS16;

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

    return ReadFile2(bus_id, data, data_size);
  }

  uint32_t ReadFile1(uint32_t bus_id, uint8_t* data, uint32_t data_size) {
      uint32_t sample_size = data_size / 2;
    int8_t* buff = new int8_t[sample_size];
    size_t ret = fread(buff, 1, sample_size, fp_);
    if (ret <= 0) {
      fseek(fp_, 0, SEEK_SET);
      ret = 0;
    }

    float max_num = 128;
    int16_t* sbuff = (int16_t*)data;
    for (uint32_t i = 0; i < sample_size; ++ i) {
        int num = buff[i];
        int16_t n_num = (num / max_num) * 32768;
        sbuff[i] = n_num;
    }

    delete[] buff;

    size_t cnt = ret / 1;
    int8_t* ptr = (int8_t*)data;
    printf("bytes:");
    for (int i = 0; i < cnt && i < 6; ++ i) {
        printf(" %d", ptr[i]);
    }
    printf("\r\n");

    return data_size;
  }

  uint32_t ReadFile2(uint32_t bus_id, uint8_t* data, uint32_t data_size) {
    size_t ret = fread(data, 1, data_size, fp_);
    if (ret <= 0) {
      fseek(fp_, 0, SEEK_SET);
      ret = 0;
    }

    for (size_t i = 0; i < ret; ++ i) {
      data[i] %= 128;
    }

    return (uint32_t)ret;
  }
 private:
  FILE* fp_;
};

@interface ViewController ()

@end

@implementation ViewController {
  std::shared_ptr<AudioOutput> audio_output_;
  dispatch_queue_t queue_;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  queue_ = dispatch_queue_create("worker", DISPATCH_QUEUE_CONCURRENT);

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
//  audio_output_->UpdateVolume(0.3);
}

- (IBAction)onClickHex:(id)sender {
  dispatch_async(queue_, ^{
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* filePath = [documentsDir stringByAppendingPathComponent:@"hex.bin"];
    FILE* fpoutput = fopen([filePath UTF8String], "wb");


    NSString* res = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/pcm/tmp.pcm"];

    FILE* fpinput = fopen([res UTF8String], "rb");

    do {
      if (!fpoutput || !fpinput) {
        break;
      }

      const uint32_t kSize = 32;
      uint8_t buff[kSize + 1] = {0};
      size_t ret = 0;

      std::deque<std::string> hexs;

      while ((ret = fread(buff, 1, kSize, fpinput)) > 0) {
        for (size_t i = 0; i < ret; ++ i) {
          char num[5] = {0};
          snprintf(num, sizeof(num), "%2x ", buff[i]);

       //   hexs.push_back(std::string(num));

          fwrite(num, 1, strlen(num), fpoutput);
        }

        const char* ne = "\r\n";
        fwrite(ne, 1, strlen(ne), fpoutput);
      }
    } while (false);

    if (fpinput) {
      fclose(fpinput);
    }

    if (fpoutput) {
      fclose(fpoutput);
    }

    printf("write (%s) complete \r\n", [filePath UTF8String]);
  });
}

@end
