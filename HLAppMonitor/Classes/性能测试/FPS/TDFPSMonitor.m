//
//  TDFPSMonitor.m
//  TuanDaiV4
//
//  Created by guoxiaoliang on 2018/6/25.
//  Copyright © 2018 Dee. All rights reserved.
//FPS监测

#import "TDFPSMonitor.h"
#import "TDWeakProxy.h"
#import "TDFPSDisplayer.h"
#import "TDTopWindow.h"
@interface TDFPSMonitor ()
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) BOOL isMonitoring;
@property (nonatomic, assign) NSTimeInterval lastTime;
//@property (nonatomic, assign) TDFPSDisplayer * displayer;
@property (nonatomic, strong) CADisplayLink * displayLink;
@end
@implementation TDFPSMonitor
{
    //帧率
    double _fps;
}

#pragma mark - Singleton override
+ (instancetype)sharedMonitor {
    static TDFPSMonitor * sharedMonitor;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedMonitor = [[super allocWithZone: NSDefaultMallocZone()] init];
    });
    return sharedMonitor;
}

+ (instancetype)allocWithZone: (struct _NSZone *)zone {
    return [self sharedMonitor];
}

- (void)dealloc {
    [self stopMonitoring];
}


#pragma mark - Public
- (void)startMonitoring {
    
    if (_isMonitoring) { return; }
    _isMonitoring = YES;
//    [self.displayer removeFromSuperview];
//    TDFPSDisplayer * displayer = [[TDFPSDisplayer alloc] init];
//    self.displayer = displayer;
//    [[TDTopWindow topWindow] addSubview: self.displayer];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget: [[TDWeakProxy alloc]initWithTarget:self] selector: @selector(monitor:)];
    [self.displayLink addToRunLoop: [NSRunLoop mainRunLoop] forMode: NSRunLoopCommonModes];
    self.lastTime = self.displayLink.timestamp;
    if ([self.displayLink respondsToSelector: @selector(setPreferredFramesPerSecond:)]) {
        if (@available(iOS 10.0, *)) {
            self.displayLink.preferredFramesPerSecond = 60;
        } else {
            // Fallback on earlier versions
        }
    } else {
        self.displayLink.frameInterval = 1;
    }
}

- (void)stopMonitoring {
    if (!_isMonitoring) { return; }
    _isMonitoring = NO;
//    [self.displayer removeFromSuperview];
    [self.displayLink invalidate];
    self.displayLink = nil;
//    self.displayer = nil;
}
#pragma mark - DisplayLink
- (void)monitor: (CADisplayLink *)link {
    _count++;
    NSTimeInterval delta = link.timestamp - _lastTime;
    if (delta < 1) { return; }
    _lastTime = link.timestamp;
    
    double fps = _count / delta;
    _fps = fps;
    _count = 0;
//    [self.displayer updateFPS: (int)round(fps)];
}
//获取帧率
- (double)getFPS {
    return _fps;
}
@end
