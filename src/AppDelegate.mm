#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (id) init {
    if (self = [super init]) {
        NSRect graphicsRect = NSMakeRect(0.0, 0.0, 800.0, 600.0);
       
        window = [ [NSWindow alloc]
                initWithContentRect: graphicsRect
                            styleMask: NSWindowStyleMaskTitled 
                                        |NSWindowStyleMaskClosable 
                                        |NSWindowStyleMaskMiniaturizable
                                        |NSWindowStyleMaskResizable
                                        |NSWindowStyleMaskBorderless
                            backing:NSBackingStoreBuffered
                                defer:NO ];
        window.titlebarAppearsTransparent = true;
        window.backgroundColor = NSColor.whiteColor;
        [window setTitle:@""];
        [window setAcceptsMouseMovedEvents:YES];
        [window center];

        ViewController *rootViewController = [[ViewController alloc] init];
        window.contentViewController = rootViewController;
        [window makeFirstResponder: rootViewController];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [window center];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *) theApplication hasVisibleWindows:(BOOL)flag {
        NSRect graphicsRect = NSMakeRect(0.0, 0.0, 800.0, 600.0);
       
        window = [ [NSWindow alloc]
                initWithContentRect: graphicsRect
                            styleMask: NSWindowStyleMaskTitled 
                                        |NSWindowStyleMaskClosable 
                                        |NSWindowStyleMaskMiniaturizable
                                        |NSWindowStyleMaskResizable
                                        |NSWindowStyleMaskBorderless
                            backing:NSBackingStoreBuffered
                                defer:NO ];
        window.titlebarAppearsTransparent = true;
        window.backgroundColor = NSColor.whiteColor;
        [window setTitle:@""];
        [window setAcceptsMouseMovedEvents:YES];
        [window center];

        ViewController *rootViewController = [[ViewController alloc] init];
        window.contentViewController = rootViewController;
        [window makeFirstResponder: rootViewController];
       [window makeKeyAndOrderFront:self];// Window that you want open while click on dock app icon
        return YES;
    
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [window makeKeyAndOrderFront:self];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}

@end
