#  Please consider below points in case of updating pods

File:  PDKClient.m
Path: /Users/hyperlink/Desktop/Rack Application/Rack/Pods/PinterestSDK/PDKClient.m

+ (void)openURL:(NSURL *)url
{
NSString *scheme = [[url scheme] lowercaseString];
if (NSClassFromString(@"SFSafariViewController") != nil && ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"])) {
UIViewController *viewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
# Add below lines of code - Start
while (viewController.presentedViewController)
{
viewController = viewController.presentedViewController;
}
# Add below lines of code - End
SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
[viewController presentViewController:safariViewController animated:YES completion:nil];
} else if ([[UIApplication sharedApplication] canOpenURL:url]) {
[[UIApplication sharedApplication] openURL:url];
}
}
