#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

#include <SFML/Window.hpp>

int main() {
    
    sf::Window window(sf::VideoMode(800, 600), "My window");

    // run the program as long as the window is open
    while (window.isOpen())
    {
        // check all the window's events that were triggered since the last iteration of the loop
        sf::Event event;
        while (window.pollEvent(event))
        {
            // "close requested" event: we close the window
            if (event.type == sf::Event::Closed)
                window.close();
        }
    }

    return 0;
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