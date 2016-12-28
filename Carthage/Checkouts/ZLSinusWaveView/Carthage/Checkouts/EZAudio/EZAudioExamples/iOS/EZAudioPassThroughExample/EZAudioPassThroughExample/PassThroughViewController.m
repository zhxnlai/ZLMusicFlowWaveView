//
//  PassThroughViewController.m
//  EZAudioPassThroughExample
//
//  Created by Syed Haris Ali on 12/20/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "PassThroughViewController.h"

@interface PassThroughViewController (){
  TPCircularBuffer _circularBuffer;
}
#pragma mark - UI Extras
@property (nonatomic,weak) IBOutlet UILabel *microphoneTextLabel;
@end

@implementation PassThroughViewController

#pragma mark - Customize the Audio Plot
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  /*
   Customizing the audio plot's look
   */
  // Background color
  self.audioPlot.backgroundColor = [UIColor colorWithRed: 0.569 green: 0.82 blue: 0.478 alpha: 1];
  // Waveform color
  self.audioPlot.color           = [UIColor colorWithRed: 1.000 green: 1.000 blue: 1.000 alpha: 1];
  // Plot type
  self.audioPlot.plotType        = EZPlotTypeBuffer;
  
  /**
   Initialize the circular buffer
   */
  [EZAudio circularBuffer:&_circularBuffer
                 withSize:1024];
  
  /*
   Start the microphone
   */
  [EZMicrophone sharedMicrophone].microphoneDelegate = self;
  [[EZMicrophone sharedMicrophone] startFetchingAudio];
  self.microphoneTextLabel.text = @"Microphone On";
  
  /**
   Start the output
   */
  [EZOutput sharedOutput].outputDataSource = self;
  [[EZOutput sharedOutput] startPlayback];
  
}

#pragma mark - Actions
-(void)changePlotType:(id)sender {
  NSInteger selectedSegment = [sender selectedSegmentIndex];
  switch(selectedSegment){
    case 0:
      [self drawBufferPlot];
      break;
    case 1:
      [self drawRollingPlot];
      break;
    default:
      break;
  }
}

-(void)toggleMicrophone:(id)sender {
  if( ![(UISwitch*)sender isOn] ){
    [[EZMicrophone sharedMicrophone] stopFetchingAudio];
    self.microphoneTextLabel.text = @"Microphone Off";
  }
  else {
    [[EZMicrophone sharedMicrophone] startFetchingAudio];
    self.microphoneTextLabel.text = @"Microphone On";
  }
}

#pragma mark - Action Extensions
/*
 Give the visualization of the current buffer (this is almost exactly the openFrameworks audio input eample)
 */
-(void)drawBufferPlot {
  // Change the plot type to the buffer plot
  self.audioPlot.plotType = EZPlotTypeBuffer;
  // Don't mirror over the x-axis
  self.audioPlot.shouldMirror = NO;
  // Don't fill
  self.audioPlot.shouldFill = NO;
}

/*
 Give the classic mirrored, rolling waveform look
 */
-(void)drawRollingPlot {
  self.audioPlot.plotType = EZPlotTypeRolling;
  self.audioPlot.shouldFill = YES;
  self.audioPlot.shouldMirror = YES;
}

#pragma mark - EZMicrophoneDelegate
-(void)microphone:(EZMicrophone *)microphone
 hasAudioReceived:(float **)buffer
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
  });
}

// Append the AudioBufferList from the microphone callback to a global circular buffer
-(void)microphone:(EZMicrophone *)microphone
    hasBufferList:(AudioBufferList *)bufferList
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
  /**
   Append the audio data to a circular buffer
   */
  [EZAudio appendDataToCircularBuffer:&_circularBuffer
                  fromAudioBufferList:bufferList];
}

#pragma mark - EZOutputDataSource
-(TPCircularBuffer *)outputShouldUseCircularBuffer:(EZOutput *)output {
  return [EZMicrophone sharedMicrophone].microphoneOn ? &_circularBuffer : nil;
}

#pragma mark - Cleanup
-(void)dealloc {
  TPCircularBufferClear(&_circularBuffer);
}

@end
