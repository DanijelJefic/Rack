/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+WebCache.h"
#define UIActivityIndicatorViewTAG 15071988
@implementation UIImageView (WebCache)

- (void)setImageWithURL:(NSURL *)url placeholderImage:(NSURL *)placeholderUrl withIndicator:(BOOL)showIndicator{
    //[[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] cleanDisk];
    self.image = nil;
    [self setImageWithURL:placeholderUrl placeholderImage:nil];
    if (self.image) {
        [self setImageWithURL:url placeholderImage:self.image];
    }
    if (showIndicator) {
        if (self.image==nil) {
            UIActivityIndicatorView *indicator = [self viewWithTag:UIActivityIndicatorViewTAG];
            if (indicator == nil) {
                indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                indicator.tag = UIActivityIndicatorViewTAG;
                [self addSubview:indicator];
            }
            indicator.frame = CGRectMake((self.frame.size.width-20)/2, (self.frame.size.height-20)/2, 20, 20);
            indicator.hidden = NO;
            [indicator startAnimating];
        }
        else{
            UIActivityIndicatorView *indicator = [self viewWithTag:UIActivityIndicatorViewTAG];
            if (indicator != nil) {
                indicator.hidden = YES;
                [indicator stopAnimating];
                [indicator removeFromSuperview];
                [indicator release];
                indicator  = nil;
            }
        }
    }
}
- (UIImage*)setImageWithURL:(NSURL*)url {
    [self setImageWithURL:url placeholderImage:nil];
    return self.image;
}
- (void)setImageWithURL:(NSURL *)url withIndicator:(BOOL)showIndicator{
    
     self.image = nil;
    [self setImageWithURL:url placeholderImage:nil];
    if (showIndicator) {
        UIActivityIndicatorView *indicator = [self viewWithTag:UIActivityIndicatorViewTAG];
        if (indicator == nil) {
            indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            if(![self.backgroundColor isEqual:[UIColor whiteColor]] && ![self.backgroundColor isEqual:[UIColor clearColor]] && [self backgroundColor] != nil)
                indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
            indicator.tag = UIActivityIndicatorViewTAG;
            [self addSubview:indicator];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            indicator.center =  CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
            if (self.image == nil) {
                indicator.hidden = NO;
                [indicator startAnimating];
            }
            else{
                indicator.hidden = YES;
                [indicator stopAnimating];
            }
        }];
    }
}
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder{
    [self setImageWithURL:url placeholderImage:placeholder options:0];
}
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    self.image = placeholder;
    if (url){
        [manager downloadWithURL:url delegate:self options:options];
    }
}
- (void)cancelCurrentImageLoad{
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
}
- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image{
    self.image = image;
    UIActivityIndicatorView *indicator = [self viewWithTag:UIActivityIndicatorViewTAG];
    if (indicator != nil) {
        indicator.hidden = YES;
        [indicator stopAnimating];
        [indicator removeFromSuperview];
        [indicator release];
        indicator  = nil;
    }
}

- (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
            break;
        case 0x42:
            return @"image/bmp";
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

@end

