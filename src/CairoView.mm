#import "CairoView.h"

#include <hb.h>
#include <hb-ft.h>
#include <cairo.h>
#include <cairo-quartz.h>
#include <cairo-ft.h>

#include <vector>
#include <iostream>
#include <string>
#include <fstream>
#include <streambuf>

#define FONT_SIZE 16
#define LINE_HEIGHT 1.25
#define PADDING_TOP 25
#define PADDING_LEFT 50

@implementation CairoView {
    int cursor_index_;
    int cursor_start_index_;

    std::string data_;

    FT_Library ft_library_;
    FT_Face ft_face_;

    float scroll_x_;
    float scroll_y_;

    hb_font_t *hb_font_;
    hb_buffer_t *hb_buffer_;
}

- (id)initWithFrame:(NSRect) frameRect {
	if ((self = [super initWithFrame:frameRect]) != nil)
	{
        self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
        self->cursor_index_ = 0;
        self->cursor_start_index_ = 0;
        ///////////////////////////////////////////////////////////////////////

        const char *fontfile = "/System/Library/Fonts/Courier.dfont";

        /* Initialize FreeType and create FreeType font face. */
        FT_Library ft_library;
        FT_Face ft_face;
        FT_Error ft_error;

        if ((ft_error = FT_Init_FreeType (&ft_library))) abort();
        if ((ft_error = FT_New_Face (ft_library, fontfile, 0, &ft_face))) abort();
        if ((ft_error = FT_Set_Char_Size (ft_face, FONT_SIZE*64, FONT_SIZE*64, 0, 0))) abort();

        self->ft_library_ = ft_library;
        self->ft_face_ = ft_face;

        ///////////////////////////////////////////////////////////////////////

        /* Create hb-ft font. */
        hb_font_t *hb_font;
        hb_font = hb_ft_font_create (ft_face, NULL);

        /* Create hb-buffer and populate. */
        hb_buffer_t *hb_buffer;
        hb_buffer = hb_buffer_create ();

        self->hb_font_ = hb_font;
        self->hb_buffer_ = hb_buffer;

        ///////////////////////////////////////////////////////////////////////

        const char *file_name = "/Users/thomasbarrett/Desktop/example.txt";
        // get file size
        self->data_ = "";
        self->scroll_x_ = 0;
        self->scroll_y_ = 0;

		CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
        CVDisplayLinkSetOutputCallback(displayLink, &CairoViewDisplayLinkCallback, self);
        CVDisplayLinkStart(displayLink);
	}
	return self;
}

- (void)dealloc {

    hb_buffer_destroy (self->hb_buffer_);
    hb_font_destroy (self->hb_font_);

    FT_Done_Face (self->ft_face_);
    FT_Done_FreeType (self->ft_library_);

    [super dealloc];
}

- (BOOL) isOpaque {
	return NO;
}

- (BOOL) isFlipped {
	return YES;
}

- (BOOL) acceptsFirstResponder {
	return YES;
}

- (void)scrollWheel:(NSEvent *)event {
    self->scroll_y_ += event.scrollingDeltaY;
    if (self->scroll_y_ > 0) self->scroll_y_ = 0;
    if (self->scroll_x_ > 0) self->scroll_x_ = 0;

    self.needsDisplay = true;
}

- (void) keyDown:(NSEvent *)event {
    NSString *eventChars = [event charactersIgnoringModifiers];
    unichar keyChar = [eventChars characterAtIndex:0];

    int cursor_min_index = 0;
    int cursor_max_index = 0;

    if (self->cursor_start_index_  < self->cursor_index_) {
        cursor_min_index = self->cursor_start_index_;
        cursor_max_index = self->cursor_index_;
    } else {
        cursor_min_index = self->cursor_index_;
        cursor_max_index = self->cursor_start_index_;
    }

    if (( keyChar == NSEnterCharacter ) || ( keyChar == NSCarriageReturnCharacter )) {
        const char *c = "\n";
        self->data_.insert(self->cursor_index_, c);
       
        self->cursor_index_ = self->cursor_index_ + 1;
        self->cursor_start_index_ = self->cursor_index_;

    } else if (keyChar == NSDeleteCharacter || keyChar == NSBackspaceCharacter) {
        if (self->cursor_index_ == 0) {
            [super keyDown: event];
        } else if (cursor_min_index != cursor_max_index) {
            self->data_.erase(cursor_min_index, cursor_max_index - cursor_min_index);
            self->cursor_index_ = cursor_min_index;
            self->cursor_start_index_ = self->cursor_index_;
        } else if (self->cursor_index_ >= 4 && self->data_.substr(self->cursor_index_ - 4, 4) == "    ") {
            self->data_.erase(self->cursor_index_ - 4, 4);
            self->cursor_index_ = self->cursor_index_ - 4;
            self->cursor_start_index_ = self->cursor_index_;
        } else {
            self->data_.erase(self->cursor_index_ - 1, 1);
            self->cursor_index_ = self->cursor_index_ - 1;
            self->cursor_start_index_ = self->cursor_index_;
        }
    } else if (keyChar == NSTabCharacter) {
        if (cursor_min_index != cursor_max_index) {
            self->data_.erase(cursor_min_index, cursor_max_index - cursor_min_index);
            self->cursor_index_ = cursor_min_index;
            self->cursor_start_index_ = self->cursor_index_;
        } 
        
        const char *c = "    ";
        self->data_.insert(self->cursor_index_, c);
        self->cursor_index_ = self->cursor_index_ + 4;
        self->cursor_start_index_ = self->cursor_index_;
    } else if (keyChar == NSLeftArrowFunctionKey) {
        if (self->cursor_index_ > 0) {
            self->cursor_index_ -= 1;
            self->cursor_start_index_ = self->cursor_index_;
        } else {
            [super keyDown: event];
        }
    } else if (keyChar == NSRightArrowFunctionKey) {
        if (self->cursor_index_ < self->data_.size()) {
            self->cursor_index_ += 1;
            self->cursor_start_index_ = self->cursor_index_;
        } else {
            [super keyDown: event];
        }
    } else if (keyChar == NSTabCharacter) {
        if (cursor_min_index != cursor_max_index) {
            self->data_.erase(cursor_min_index, cursor_max_index - cursor_min_index);
            self->cursor_index_ = cursor_min_index;
        } 
        const char *c = "    ";
        self->data_.insert(self->cursor_index_, c);
        self->cursor_index_ = self->cursor_index_ + 4;
    } else if (([event modifierFlags] & NSCommandKeyMask) && keyChar == 's') {
       
         // Set the default name for the file and show the panel.
        NSSavePanel*    panel = [NSSavePanel savePanel];
        [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
            if (result == NSFileHandlingPanelOKButton) {
                NSURL* theFile = [panel URL];
                std::string path = std::string(theFile.fileSystemRepresentation);
                std::cout << path << std::endl;
                std::fstream file;
                file.open(path, std::ios::out);
                file << self->data_;
                file.flush();
                file.close();
            }
        }];

    }  else if (([event modifierFlags] & NSCommandKeyMask) && keyChar == 'o') {
       
        NSOpenPanel* panel = [NSOpenPanel openPanel];
 
        // This method displays the panel and returns immediately.
        // The completion handler is called when the user selects an
        // item or cancels the panel.
        [panel beginWithCompletionHandler:^(NSInteger result){
            if (result == NSFileHandlingPanelOKButton) {
                NSURL*  theDoc = [[panel URLs] objectAtIndex:0];
                std::string path_ = std::string(theDoc.fileSystemRepresentation);
                std::cout << path_ << std::endl;
                std::ifstream t(path_);
                std::string str((std::istreambuf_iterator<char>(t)), std::istreambuf_iterator<char>());
                self->data_ = str;
                std::cout << str << std::endl;
                self->cursor_index_ = 0;
                self->cursor_start_index_ = self->cursor_index_;
                self.needsDisplay = true;
            }
        
        }];

    } else if (([event modifierFlags] & NSCommandKeyMask) && keyChar == 'a') {
        self->cursor_start_index_ = 0;
        self->cursor_index_ = data_.size();
    } else if (([event modifierFlags] & NSCommandKeyMask) && keyChar == 'c') {
        if (cursor_max_index - cursor_min_index > 0) {
            NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
            [pasteboard clearContents];
            std::string str = self->data_.substr(cursor_min_index, cursor_max_index - cursor_min_index);
            [pasteboard writeObjects:@[[NSString stringWithUTF8String:str.c_str()]]];
        }
       
    } else if (([event modifierFlags] & NSCommandKeyMask) && keyChar == 'x') {
        if (cursor_max_index - cursor_min_index > 0) {
            std::cout << cursor_max_index - cursor_min_index << std::endl;
            NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
            [pasteboard clearContents];
            std::string str = self->data_.substr(cursor_min_index, cursor_max_index - cursor_min_index);
            [pasteboard writeObjects:@[[NSString stringWithUTF8String:str.c_str()]]];

            self->data_.erase(cursor_min_index, cursor_max_index - cursor_min_index);
            self->cursor_index_ = cursor_min_index;
            self->cursor_start_index_ = self->cursor_index_;
        }
       
    } else if (([event modifierFlags] & NSCommandKeyMask) && keyChar == 'v') {
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        NSString* myString = [pasteboard stringForType:NSPasteboardTypeString];
        std::string str = std::string([myString UTF8String]);
        self->data_.insert(self->cursor_index_,  str);
        self->cursor_index_ += str.size();
        self->cursor_start_index_ = self->cursor_index_;

    } else if (0x0020 <= keyChar && keyChar <= 0x007F) {

        if (cursor_min_index != cursor_max_index) {
            self->data_.erase(cursor_min_index, cursor_max_index - cursor_min_index);
            self->cursor_index_ = cursor_min_index;
        } 

        const char *c = [event.characters UTF8String];
        self->data_.insert(self->cursor_index_, c);
        self->cursor_index_ = self->cursor_index_ + 1;
        self->cursor_start_index_ = self->cursor_index_;
    }
    self.needsDisplay = true;
    return;
}

- (void) mouseDragged:(NSEvent *) event {
    NSPoint event_location = event.locationInWindow;
    NSPoint local_point = [self convertPoint:event_location fromView:nil];
    self->cursor_index_ = [self getCursorIndexFromLocation: local_point];
    self.needsDisplay = true;
}

- (void) mouseDown:(NSEvent *) event {
    NSPoint event_location = event.locationInWindow;
    NSPoint local_point = [self convertPoint:event_location fromView:nil];
    self->cursor_index_ = [self getCursorIndexFromLocation: local_point];
    self->cursor_start_index_ = self->cursor_index_;
    self.needsDisplay = true;
}

- (int) getCursorIndexFromLocation: (NSPoint) theCursor {
   
    hb_font_t *hb_font = self->hb_font_;
    hb_buffer_t *hb_buffer = self->hb_buffer_;

    hb_buffer_clear_contents (hb_buffer);
    hb_buffer_add_utf8 (hb_buffer, self->data_.data(), self->data_.size(), 0, -1);
    hb_buffer_guess_segment_properties (hb_buffer);

    /* Shape it! */
    hb_shape (hb_font, hb_buffer, NULL, 0);

    /* Get glyph information and positions out of the buffer. */
    unsigned int len = hb_buffer_get_length (hb_buffer);
    hb_glyph_info_t *info = hb_buffer_get_glyph_infos (hb_buffer, NULL);
    hb_glyph_position_t *pos = hb_buffer_get_glyph_positions (hb_buffer, NULL);

    double text_width = 0.0;
    double text_height = 0.0;
    for (unsigned int i = 0; i < len; i++) {
        text_width  += pos[i].x_advance / 64.;
        text_height -= pos[i].y_advance / 64.;
    }
    if (HB_DIRECTION_IS_HORIZONTAL (hb_buffer_get_direction(hb_buffer))) {
        text_height += FONT_SIZE;
    } else {
        text_width  += FONT_SIZE;
    }

    NSPoint cursor;
    cursor.y = theCursor.y - PADDING_TOP - scroll_y_;
    if (cursor.y < 0) cursor.y = 0;
    cursor.x = theCursor.x - PADDING_LEFT - scroll_x_;
    if (cursor.x < 0) cursor.x = 0;

    double current_x = 0;
    double current_y = 0;

    for (unsigned int i = 0; i < len; i++) {
      unsigned int cluster = info[i].cluster;
      double x_position = current_x + pos[i].x_offset / 64.;
      double y_position = current_y + pos[i].y_offset / 64.;

        if (y_position >= cursor.y - LINE_HEIGHT * FONT_SIZE && x_position >= cursor.x) {
            return cluster;
        }

        if (self->data_[info[i].cluster] == '\n') {
            current_x = 0;
            current_y += LINE_HEIGHT * FONT_SIZE;  
            if (y_position >= cursor.y - LINE_HEIGHT * FONT_SIZE) {
                return cluster;
            }
        } else {
            current_x += pos[i].x_advance / 64.;
            current_y += pos[i].y_advance / 64.;
        }
    }

    return self->data_.size();
}

- (void) drawRect: (NSRect) rect {

    NSRect bounds = [self bounds];

	int width = bounds.size.width;
	int height = bounds.size.height;
    
	CGContextRef ctx = (CGContextRef)[[NSGraphicsContext currentContext] CGContext];
    cairo_surface_t *cairo_surface = cairo_quartz_surface_create_for_cg_context(ctx, width, height);
    cairo_t *cr = cairo_create(cairo_surface);
    cairo_set_source_rgba (cr, 1., 1., 1., 1.);

    cairo_paint (cr);
    hb_font_t *hb_font = self->hb_font_;
    hb_buffer_t *hb_buffer = self->hb_buffer_;
    FT_Face ft_face = self->ft_face_;

    hb_buffer_clear_contents (hb_buffer);
    hb_buffer_add_utf8 (hb_buffer, self->data_.data(), self->data_.size(), 0, -1);
    hb_buffer_guess_segment_properties (hb_buffer);

    /* Shape it! */
    hb_shape (hb_font, hb_buffer, NULL, 0);

    /* Get glyph information and positions out of the buffer. */
    unsigned int len = hb_buffer_get_length (hb_buffer);
    hb_glyph_info_t *info = hb_buffer_get_glyph_infos (hb_buffer, NULL);
    hb_glyph_position_t *pos = hb_buffer_get_glyph_positions (hb_buffer, NULL);

    double text_width = 0.0;
    double text_height = 0.0;
    for (unsigned int i = 0; i < len; i++) {
        text_width  += pos[i].x_advance / 64.;
        text_height -= pos[i].y_advance / 64.;
    }
    if (HB_DIRECTION_IS_HORIZONTAL (hb_buffer_get_direction(hb_buffer))) {
        text_height += FONT_SIZE;
    } else {
        text_width  += FONT_SIZE;
    }


    /* Set up cairo font face. */
    cairo_font_face_t *cairo_face;
    cairo_face = cairo_ft_font_face_create_for_ft_face (ft_face, 0);
    cairo_set_font_face (cr, cairo_face);
    cairo_set_font_size (cr, FONT_SIZE);

    //cairo_set_source_rgba (cr, 213./255, 214./255, 216./255, 1.);
    cairo_set_source_rgba (cr, 0.925, 0.925, 0.925, 1.);

 

    cairo_glyph_t *cairo_glyphs = cairo_glyph_allocate (len);
 
    
    std::vector<int> lines;
    lines.push_back(0);

    double cursor_start_x = -1;
    double cursor_start_y = -1;
    
    double cursor_x = -1;
    double cursor_y = -1;
    
    int row_index = 0;
    double current_x = 0;
    double current_y = 0;
    for (unsigned int i = 0; i < len; i++) {
        
        cairo_glyphs[i].index = info[i].codepoint;
        cairo_glyphs[i].x = current_x + pos[i].x_offset / 64.;
        cairo_glyphs[i].y = -(current_y + pos[i].y_offset / 64.);
        
        if (info[i].cluster == self->cursor_index_) {
            cursor_x = cairo_glyphs[i].x + PADDING_LEFT;
            cursor_y = cairo_glyphs[i].y + PADDING_TOP;
        }
        if (info[i].cluster == self->cursor_start_index_) {
            cursor_start_x = cairo_glyphs[i].x + PADDING_LEFT;
            cursor_start_y = cairo_glyphs[i].y + PADDING_TOP;
        }

        if (self->data_[info[i].cluster] == '\n') {
            current_x = 0;
            current_y -= LINE_HEIGHT * FONT_SIZE;   
            lines.push_back(i + 1);
            row_index += 1;
        } else {
            current_x += pos[i].x_advance / 64.;
            current_y += pos[i].y_advance / 64.;
        }

    }

    if (cursor_x == -1 || cursor_y == -1) {
        cursor_x = current_x + PADDING_LEFT;
        cursor_y = -current_y + PADDING_TOP;
    }

    if (cursor_start_x == -1 || cursor_start_y == -1) {
        cursor_start_x = current_x + PADDING_LEFT;
        cursor_start_y = -current_y + PADDING_TOP;
    }

    cairo_translate(cr, self->scroll_x_, self->scroll_y_);

    if (cursor_x != cursor_start_x || cursor_y != cursor_start_y) {

        cairo_set_source_rgba (cr, 180./255, 216./255, 253./255, 1.);

        double cursor_min_x = 0;
        double cursor_min_y = 0;

        double cursor_max_x = 0;
        double cursor_max_y = 0;

        if (self->cursor_index_ < self->cursor_start_index_) {
            cursor_min_x = cursor_x;
            cursor_min_y = cursor_y;
            cursor_max_x = cursor_start_x;
            cursor_max_y = cursor_start_y;
        } else {
            cursor_min_x = cursor_start_x;
            cursor_min_y = cursor_start_y;
            cursor_max_x = cursor_x;
            cursor_max_y = cursor_y;
        }

        if (cursor_min_y == cursor_max_y) {
            cairo_rectangle(cr, cursor_min_x, cursor_min_y, cursor_max_x - cursor_min_x, LINE_HEIGHT * FONT_SIZE);
            cairo_fill(cr);
        } else {
            cairo_rectangle(cr, cursor_min_x, cursor_min_y, width - cursor_min_x, LINE_HEIGHT * FONT_SIZE);
            cairo_fill(cr);

            cairo_rectangle(cr, 0, cursor_min_y + LINE_HEIGHT * FONT_SIZE, width, cursor_max_y - cursor_min_y - LINE_HEIGHT * FONT_SIZE);
            cairo_fill(cr);

            cairo_rectangle(cr, 0, cursor_max_y, cursor_max_x, LINE_HEIGHT * FONT_SIZE);
            cairo_fill(cr);
        }

    } else {
        cairo_rectangle(cr, 0, cursor_y , width, LINE_HEIGHT * FONT_SIZE);
        cairo_fill(cr);
    }


    cairo_set_source_rgba (cr, 0, 0, 0, 1.);
    cairo_rectangle(cr, cursor_x, cursor_y, 1, LINE_HEIGHT * FONT_SIZE);
    cairo_fill(cr);

   /* Set up baseline. */
    if (HB_DIRECTION_IS_HORIZONTAL (hb_buffer_get_direction(hb_buffer))) {
        cairo_font_extents_t font_extents;
        cairo_font_extents (cr, &font_extents);
        double baseline = (FONT_SIZE - font_extents.height) * .5 + font_extents.ascent;
        cairo_translate (cr, PADDING_LEFT, PADDING_TOP + (LINE_HEIGHT - 1) * FONT_SIZE / 2.0 + baseline);
    } else {
        cairo_translate (cr, FONT_SIZE * .5, 0);
    }
    cairo_set_source_rgba (cr, 0., 0., 0., 1.);

    cairo_glyph_path (cr, cairo_glyphs, len);
    cairo_fill(cr);
    cairo_glyph_free (cairo_glyphs);

    cairo_set_source_rgb(cr, 0, 0, 0);
    cairo_set_line_width(cr, 1);

    cairo_font_face_destroy (cairo_face);
    cairo_destroy (cr);


}

@end

CVReturn CairoViewDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSView *view = ((NSView*) displayLinkContext);
        // [view setNeedsDisplay: YES];
    });
    return kCVReturnSuccess;
}
