//
//  ZLMusicFlowWaveView.m
//  ZLMusicFlowWaveViewDemo
//
//  Created by Zhixuan Lai on 11/17/14.
//  Copyright (c) 2014 Zhixuan Lai. All rights reserved.
//

#import "ZLMusicFlowWaveView.h"
#import "ZLMusicFlowDecorativeView.h"

@implementation ZLMusicFlowWaveView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self Setup];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self Setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self Setup];
    }
    return self;
}

- (void)Setup {
    self.backgroundColor = [UIColor colorWithRed:0.937 green:0.933 blue:0.914 alpha:1.000];
    // Waveform color
    self.color           = [UIColor colorWithRed:0.165 green:0.043 blue:0.000 alpha:1.000];
    // Plot type
    self.plotType        = EZPlotTypeBuffer;
    // Fill
    self.shouldFill      = YES;
    // Mirror
    self.shouldMirror    = YES;
    
    self.dampingFactor = 0.97;
    self.phaseShift = -0.25;
    self.waveWidth = 3;
    self.waveInsets = UIEdgeInsetsMake(250, 60, 250, 60);

    CGFloat decorativeViewWidth = 20;
    self.leftDecorativeView = [[ZLMusicFlowDecorativeView alloc] initWithFrame:CGRectMake(0, 0, decorativeViewWidth, decorativeViewWidth)];
    self.rightDecorativeView = [[ZLMusicFlowDecorativeView alloc] initWithFrame:CGRectMake(0, 0, decorativeViewWidth, decorativeViewWidth)];
}

@end
