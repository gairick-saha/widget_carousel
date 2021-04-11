#import "WidgetCarouselPlugin.h"
#if __has_include(<widget_carousel/widget_carousel-Swift.h>)
#import <widget_carousel/widget_carousel-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "widget_carousel-Swift.h"
#endif

@implementation WidgetCarouselPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftWidgetCarouselPlugin registerWithRegistrar:registrar];
}
@end
