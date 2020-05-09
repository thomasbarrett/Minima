#import <Cocoa/Cocoa.h>
#import <CoreVideo/CoreVideo.h>

CVReturn CairoViewDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext);

@interface CairoView : NSView {
    CVDisplayLinkRef displayLink;
}

@end
