#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"
#import "AutoUpdate.h"

int main() {

    NSString *metadata_path = [[NSBundle mainBundle] pathForResource:@"metadata" ofType:@"json"];

    AutoUpdate update{metadata_path};
    std::cout << "latest version: " << update.latestVersion() << std::endl;
    std::cout << "current version: " << update.currentVersion() << std::endl;

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