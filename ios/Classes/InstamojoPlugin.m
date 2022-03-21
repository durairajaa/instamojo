#import "InstamojoPlugin.h"
#if __has_include(<instamojo/instamojo-Swift.h>)
#import <instamojo/instamojo-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "instamojo-Swift.h"
#endif

@implementation InstamojoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftInstamojoPlugin registerWithRegistrar:registrar];
}
@end
