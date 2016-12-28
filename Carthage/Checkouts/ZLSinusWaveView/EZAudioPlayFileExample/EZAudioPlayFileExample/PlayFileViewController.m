//
//  PlayFileViewController.m
//  EZAudioPlayFileExample
//
//  Created by Syed Haris Ali on 12/16/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "PlayFileViewController.h"

@interface PlayFileViewController (){
  float  *_waveformData;
  UInt32 _waveformDrawingIndex;
  UInt32 _waveformFrameRate;
  UInt32 _waveformTotalBuffers;
}
@end

@implementation PlayFileViewController
@synthesize audioFile = _audioFile;
@synthesize audioPlot = _audioPlot;
@synthesize eof = _eof;
@synthesize framePositionSlider = _framePositionSlider;

#pragma mark - Initialization
-(id)init {
  self = [super init];
  if(self){
    [self initializeViewController];
  }
  return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if(self){
    [self initializeViewController];
  }
  return self;
}

#pragma mark - Initialize View Controller Here
-(void)initializeViewController {
}

#pragma mark - Customize the Audio Plot
-(void)viewDidLoad {
  
  [super viewDidLoad];
  
  /*
   Customizing the audio plot's look
   */
  // Background color
  self.audioPlot.backgroundColor = [UIColor colorWithRed: 0.816 green: 0.349 blue: 0.255 alpha: 1];
  // Waveform color
  self.audioPlot.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
  // Plot type
  self.audioPlot.plotType        = EZPlotTypeBuffer;
  // Fill
  self.audioPlot.shouldFill      = YES;
  // Mirror
  self.audioPlot.shouldMirror    = YES;
    
    self.audioPlot.maxAmplitude = 1/10.0;
  /*
   Try opening the sample file
   */
  [self openFileWithFilePathURL:[NSURL fileURLWithPath:kAudioFileDefault]];
  
}

//-(void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//    
//    CGPoint center = self.audioPlot.center;
//    CGRect frame = self.audioPlot.frame;
//    
//    NSLog(@"audioPlot frame: %f %f %f %f", self.audioPlot.frame.origin.x, self.audioPlot.frame.origin.y, self.audioPlot.frame.size.width,self.audioPlot.frame.size.height);
//    
//    self.audioPlot.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame)/8);
//    
//    NSLog(@"audioPlot frame: %f %f %f %f", self.audioPlot.frame.origin.x, self.audioPlot.frame.origin.y, self.audioPlot.frame.size.width,self.audioPlot.frame.size.height);
//    
//    self.audioPlot.center = center;
//    
//    NSLog(@"audioPlot frame: %f %f %f %f", self.audioPlot.frame.origin.x, self.audioPlot.frame.origin.y, self.audioPlot.frame.size.width,self.audioPlot.frame.size.height);
//
//}

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

-(void)play:(id)sender {
  if( ![[EZOutput sharedOutput] isPlaying] ){
    if( self.eof ){
      [self.audioFile seekToFrame:0];
    }
    [EZOutput sharedOutput].outputDataSource = self;
    [[EZOutput sharedOutput] startPlayback];
  }
  else {
    [EZOutput sharedOutput].outputDataSource = nil;
    [[EZOutput sharedOutput] stopPlayback];
  }
}

-(void)seekToFrame:(id)sender {
  [self.audioFile seekToFrame:(SInt64)[(UISlider*)sender value]];
}

#pragma mark - Action Extensions
/*
 Give the visualization of the current buffer (this is almost exactly the openFrameworks audio input example)
 */
-(void)drawBufferPlot {
  // Change the plot type to the buffer plot
  self.audioPlot.plotType = EZPlotTypeBuffer;
  // Don't fill
  self.audioPlot.shouldFill = NO;
  // Don't mirror over the x-axis
  self.audioPlot.shouldMirror = NO;
}

/*
 Give the classic mirrored, rolling waveform look
 */
-(void)drawRollingPlot {
  // Change the plot type to the rolling plot
  self.audioPlot.plotType = EZPlotTypeRolling;
  // Fill the waveform
  self.audioPlot.shouldFill = YES;
  // Mirror over the x-axis
  self.audioPlot.shouldMirror = YES;
}

-(void)openFileWithFilePathURL:(NSURL*)filePathURL {
  
  // Stop playback
  [[EZOutput sharedOutput] stopPlayback];
  
  self.audioFile                        = [EZAudioFile audioFileWithURL:filePathURL];
  self.audioFile.audioFileDelegate      = self;
  self.eof                              = NO;
  self.filePathLabel.text               = filePathURL.lastPathComponent;
  self.framePositionSlider.maximumValue = (float)self.audioFile.totalFrames;
  
  // Set the client format from the EZAudioFile on the output
  [[EZOutput sharedOutput] setAudioStreamBasicDescription:self.audioFile.clientFormat];

  // Plot the whole waveform
  self.audioPlot.plotType        = EZPlotTypeBuffer;
  self.audioPlot.shouldFill      = YES;
  self.audioPlot.shouldMirror    = YES;
  [self.audioFile getWaveformDataWithCompletionBlock:^(float *waveformData, UInt32 length) {
    [self.audioPlot updateBuffer:waveformData withBufferSize:length];
  }];
  
}

#pragma mark - EZAudioFileDelegate
-(void)audioFile:(EZAudioFile *)audioFile
       readAudio:(float **)buffer
  withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
  dispatch_async(dispatch_get_main_queue(), ^{
    if( [EZOutput sharedOutput].isPlaying ){
      if( self.audioPlot.plotType     == EZPlotTypeBuffer &&
         self.audioPlot.shouldFill    == YES              &&
         self.audioPlot.shouldMirror  == YES ){
        self.audioPlot.shouldFill   = NO;
        self.audioPlot.shouldMirror = NO;
      }
      [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
    }
  });
}

-(void)audioFile:(EZAudioFile *)audioFile
 updatedPosition:(SInt64)framePosition {
  dispatch_async(dispatch_get_main_queue(), ^{
    if( !self.framePositionSlider.touchInside ){
      self.framePositionSlider.value = (float)framePosition;
    }
  });
}

#pragma mark - EZOutputDataSource
-(void)output:(EZOutput *)output shouldFillAudioBufferList:(AudioBufferList *)audioBufferList withNumberOfFrames:(UInt32)frames
{
  if( self.audioFile )
  {
    UInt32 bufferSize;
    [self.audioFile readFrames:frames
               audioBufferList:audioBufferList
                    bufferSize:&bufferSize
                           eof:&_eof];
    if( _eof )
    {
      [self seekToFrame:0];
    }
  }
}

-(AudioStreamBasicDescription)outputHasAudioStreamBasicDescription:(EZOutput *)output {
  return self.audioFile.clientFormat;
}

@end
