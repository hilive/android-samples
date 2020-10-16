//
//  ViewController.m
//  font-test
//
//  Created by cort xu on 2020/7/29.
//  Copyright © 2020 cort xu. All rights reserved.
//

#import "ViewController.h"
#import <CoreText/CoreText.h>
#include <unordered_map>
#include <vector>
#include <string>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lbTest0;
@property (weak, nonatomic) IBOutlet UILabel *lbTest1;
@property (weak, nonatomic) IBOutlet UILabel *lbTest2;
@property (weak, nonatomic) IBOutlet UILabel *lbTest3;
@property (weak, nonatomic) IBOutlet UILabel *lbTest4;
@property (weak, nonatomic) IBOutlet UILabel *lbTest5;
@property (weak, nonatomic) IBOutlet UILabel *lbTest6;
@property (weak, nonatomic) IBOutlet UILabel *lbTest7;
@property (weak, nonatomic) IBOutlet UILabel *lbTest8;
@property (weak, nonatomic) IBOutlet UILabel *lbTest9;
@property (weak, nonatomic) IBOutlet UILabel *lbTest10;

@end

@implementation ViewController


static std::vector<CGFloat> fontWeightConfig = {
//    -1.00, -0.70, -0.50, -0.23, -0.00, 0.20, 0.30, 0.40, 0.60, 0.80, 1.00
    -1.00, UIFontWeightThin, UIFontWeightUltraLight, UIFontWeightLight, UIFontWeightRegular,
    UIFontWeightMedium, UIFontWeightSemibold, UIFontWeightBold, UIFontWeightHeavy, UIFontWeightBlack, 1.00
};

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)onClickSysFont:(id)sender {
    int size = 20;
    for (int i = 0; i < (int)fontWeightConfig.size(); ++ i) {
        CGFloat fontWeigth = fontWeightConfig[i];
        UIFont* font = [UIFont systemFontOfSize:size weight:fontWeigth];
        UILabel* lb = (UILabel*)[self.view viewWithTag:(100 + i)];
        if (!font || !lb) {
            continue;
        }
        
        lb.font = font;
    }
}

- (IBAction)onClickCusFont:(id)sender {
    int size = 20;
    for (int i = 0; i < (int)fontWeightConfig.size(); ++ i) {
        CGFloat fontWeigth = fontWeightConfig[i];
        
        UIFontDescriptorSymbolicTraits symbolic = 0;
        
        symbolic |= UIFontDescriptorTraitBold;
        symbolic |= UIFontDescriptorTraitItalic;

        UIFontDescriptor* fontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:@{
            UIFontDescriptorSizeAttribute:@(size),
       //     UIFontDescriptorFamilyAttribute: @"Arial",//
            UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
      //      UIFontDescriptorFamilyAttribute: @".AppleSystemUIFont",
            UIFontDescriptorTraitsAttribute: @{
                UIFontWeightTrait: @(fontWeigth),
          //      UIFontSymbolicTrait: @(symbolic),
            },
        }];
        
        UIFont* font = [UIFont fontWithDescriptor:fontDescriptor size:size];
        
        UILabel* lb = (UILabel*)[self.view viewWithTag:(100 + i)];
        if (!font || !lb) {
            continue;
        }
        
        lb.font = font;
    }
}

@end
