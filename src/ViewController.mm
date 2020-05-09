#include "ViewController.h"
#include "CairoView.h"

@implementation ViewController 

- (void) mouseMoved:(NSEvent *)event {
    [super mouseMoved:event];
}

- (void) mouseDown:(NSEvent *)event {
    [super mouseDown:event];
}

- (void) keyDown:(NSEvent *)theEvent {
    [super keyDown:theEvent];
}

- (void) keyUp:(NSEvent *)theEvent {
    [super keyUp:theEvent];
}

- (void) viewDidLoad {
    //
}

- (void) loadView {
    NSRect rect = NSMakeRect(0.0, 0.0, 800.0, 600.0);
    NSView *view;
    view = [[CairoView alloc] init];
    view.frame = rect;
    self.view = view;
}

@end

