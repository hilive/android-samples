//
//  ViewController.m
//  DCPaintBoard
//
//  Created by Wade on 16/4/25.
//  Copyright © 2016年 Wade. All rights reserved.
//

#import "ViewController.h"
#import "DCCommon.h"
#import "DCOpenGLDrawView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet DCOpenGLDrawView *openGlDrawView;

@property (weak, nonatomic) IBOutlet UIButton *selectColorBtn;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UIButton *eraseBtn;

@property (nonatomic, assign)DCPaintColor  selectPaintColor;
@property (nonatomic, assign) BOOL isErase;


@property (nonatomic, strong) UIColor *paintColor;

@end

@implementation ViewController
/**
 *  画笔颜色set方法
 *
 *  @param selectPaintColor <#selectPaintColor description#>
 */
- (void)setSelectPaintColor:(DCPaintColor)selectPaintColor
{
  _selectPaintColor = selectPaintColor;
  switch (selectPaintColor) {
    case DCPaintColorRed:
      self.paintColor = [UIColor redColor];
      break;
    case DCPaintColorBlue:
      self.paintColor = [UIColor blueColor];
      break;
    case DCPaintColorGreen:
      self.paintColor = [UIColor greenColor];
      break;
    case DCPaintColorBlack:
      self.paintColor = [UIColor blackColor];
      break;
    default:
      self.paintColor = [UIColor blackColor];
      break;
  }
  
  self.openGlDrawView.lineColor = self.paintColor;
}

- (void)setIsErase:(BOOL)isErase{
  _isErase = isErase;
  self.openGlDrawView.isErase = isErase;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpresseraseBtn:)];
  longpress.minimumPressDuration = 0.5; //定义按的时间
  [self.eraseBtn addGestureRecognizer:longpress];
}

- (void)longpresseraseBtn:(UILongPressGestureRecognizer *)gest{
  [self.openGlDrawView clear];
}


- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self selectColorBtnClick:_selectColorBtn];
  self.selectPaintColor = DCPaintColorBlack;
  
  self.openGlDrawView.backgroundColor = [UIColor clearColor];
}


/**
 *  画笔颜色按钮
 *
 *  @param sender 画笔按钮
 */
- (IBAction)selectColorBtnClick:(UIButton *)sender {
  sender.selected = !sender.selected;
  self.colorView.hidden = sender.selected;
}

/**
 *  颜色选择按钮
 *
 *  @param sender 颜色按钮
 */
- (IBAction)colorBtnSelect:(UIButton *)sender {
  if (sender.tag == 105) {
    
  }else{
    self.selectPaintColor = (DCPaintColor)sender.tag - 100;
  }
  switch (self.selectPaintColor) {
    case DCPaintColorRed:
    {
      [self.selectColorBtn setImage:[UIImage imageNamed:@"btn_mark_red"] forState:UIControlStateSelected];
      break;
    }
    case DCPaintColorBlue:
    {
      [self.selectColorBtn setImage:[UIImage imageNamed:@"btn_mark_blue"] forState:UIControlStateSelected];
      break;
    }
    case DCPaintColorGreen:
    {
      [self.selectColorBtn setImage:[UIImage imageNamed:@"btn_mark_green"] forState:UIControlStateSelected];
      break;
    }
      
    default:
    case DCPaintColorBlack:
    {
      [self.selectColorBtn setImage:[UIImage imageNamed:@"btn_mark_black"] forState:UIControlStateSelected];
      break;
    }
  }
  self.colorView.hidden = YES;
  self.selectColorBtn.selected = YES;
}


/**
 *  点击橡皮擦按钮
 *
 *  @param sender 橡皮擦按钮
 */
- (IBAction)eraseBtnClick:(UIButton *)sender {
  sender.selected = !sender.selected;
  self.isErase = sender.selected;
}

@end
