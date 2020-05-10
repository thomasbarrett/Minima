#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main() {

    @autoreleasepool {
        NSApp = [NSApplication sharedApplication];
        AppDelegate *appDelegate = [[AppDelegate alloc] init];
        [NSApp setDelegate:appDelegate];
        id applicationMenuBar = [NSMenu new];
        id appMenuItem        = [NSMenuItem new];
        [applicationMenuBar addItem:appMenuItem];
        [NSApp setMainMenu: applicationMenuBar];
        [NSApp run];
    }

    return 0;

}