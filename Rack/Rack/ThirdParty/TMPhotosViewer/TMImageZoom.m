//
//  TMImageZoom.h
//
//  Created by Thomas Maw on 23/11/16.
//  Copyright © 2016 Thomas Maw. All rights reserved.
//

#import "TMImageZoom.h"

static  TMImageZoom* tmImageZoom;
@implementation TMImageZoom {
    UIImageView *currentImageView;
    UIImageView *hostImageView;
    BOOL isAnimatingReset;
    CGPoint panCoord;
    CGPoint firstCenterPoint;
    CGRect startingRect;
    UIPanGestureRecognizer * panGest;
    BOOL isHandlingGesture;
    CGFloat lastScale;
    BOOL isFirst;
}

//#pragma mark - Methods
//-(void) gestureStateChanged:(id)gesture withZoomImageView:(UIImageView*)imageView {
//
//    // Insure user is passing correct UIPinchGestureRecognizer class.
//    if (![gesture isKindOfClass:[UIPinchGestureRecognizer class]]) {
//        NSLog(@"(TMImageZoom): Must be using a UIPinchGestureRecognizer, currently you're using a: %@",[gesture class]);
//        return;
//    }
//
//    UIPinchGestureRecognizer *theGesture = gesture;
//
//
//
//    // Prevent animation issues if currently animating reset.
//    if (isAnimatingReset) {
//        return;
//    }
//
//    // Reset zoom if state = UIGestureRecognizerStateEnded
//    if (theGesture.state == UIGestureRecognizerStateEnded || theGesture.state == UIGestureRecognizerStateCancelled || theGesture.state == UIGestureRecognizerStateFailed) {
//        [self resetImageZoom];
//        return;
//    }
//
//    // Ignore other views trying to start zoom if already zooming with another view
//    if (isHandlingGesture && hostImageView != imageView) {
//        NSLog(@"(TMImageZoom): 'gestureStateChanged:' ignored since this imageView isnt being tracked");
//        return;
//    }
//
//    // Start handling gestures if state = UIGestureRecognizerStateBegan and not already handling gestures.
//    if (!isHandlingGesture && theGesture.state == UIGestureRecognizerStateBegan) {
//        lastScale = theGesture.scale;
//        isHandlingGesture = YES;
//
//        // Set Host ImageView
//        hostImageView = imageView;
//        imageView.hidden = YES;
//
//        // Convert local point to window coordinates
//        CGPoint point = [imageView.superview convertPoint:imageView.frame.origin toView:nil];
//
//
//        startingRect = CGRectMake(point.x, point.y, imageView.frame.size.width, imageView.frame.size.height);
//
//        // Post Notification
//            [[NSNotificationCenter defaultCenter] postNotificationName:TMImageZoom_Started_Zoom_Notification object:nil];
//
//            // Get current window and set starting vars
//            UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
//            firstCenterPoint = [theGesture locationInView:currentWindow];
//
//
//            // Init zoom ImageView
//            currentImageView = [[UIImageView alloc] initWithImage:imageView.image];
//            currentImageView.contentMode = imageView.contentMode;
//            [currentImageView setFrame:startingRect];
//
//
//        CGFloat currentScale = currentImageView.frame.size.width / startingRect.size.width;
////        NSLog(@"Last scale %f", lastScale);
////        NSLog(@"Current scale %f", currentScale);
//        CGFloat newScale = currentScale * theGesture.scale;
////        NSLog(@"gesture. new scale = %f current Scale = %f", newScale , currentScale);
//
//        if (newScale < 1)
//        {
//
//            imageView.hidden = NO;
//            return;
//        }
//
//            [currentWindow addSubview:currentImageView];
//
//
//    }
//
//    CGFloat currentScale = currentImageView.frame.size.width / startingRect.size.width;
//
//    //|| ((currentScale - lastScale) < 0.3)
//
////    if (((lastScale - theGesture.scale) < 0.3) && (theGesture.numberOfTouches < 2)) {
////        return;
////    }
//
//    // Reset if user removes a finger (Since center calculation would cause image to jump to finger as center. Maybe this could be improved later)
////    if (theGesture.numberOfTouches < 2) {
////
//////        panGest = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveImage:)];
//////        panGest.minimumNumberOfTouches = 1;
//////        [panGest requireGestureRecognizerToFail:theGesture];
//////        [currentImageView addGestureRecognizer:panGest];
////
//////        [self resetImageZoom];
////        return;
////    }
//
//
//    // Update scale & center
//    if ((theGesture.state == UIGestureRecognizerStateChanged) && (theGesture.numberOfTouches == 2)) {
////        NSLog(@"gesture.scale = %f", theGesture.scale);
//
//        // Calculate new image scale.
////        CGFloat currentScale = currentImageView.frame.size.width / startingRect.size.width;
////        CGFloat newScale = currentScale * theGesture.scale;
//////        NSLog(@"gesture.scale = %f", newScale);
////
////        if (newScale < 1)
////        {
////            return;
////        }
////
////
////            [currentImageView setFrame:CGRectMake(currentImageView.frame.origin.x, currentImageView.frame.origin.y, startingRect.size.width * newScale, startingRect.size.height*newScale)];
////            //start
////            // Calculate new center
////            UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
////            int centerXDif = firstCenterPoint.x-[theGesture locationInView:currentWindow].x;
////            int centerYDif = firstCenterPoint.y-[theGesture locationInView:currentWindow].y;
////
////            currentImageView.center = CGPointMake((startingRect.origin.x+(startingRect.size.width/2))-centerXDif, (startingRect.origin.y+(startingRect.size.height/2))-centerYDif);
////
////
////       //end
////
////        // Reset gesture scale
////        theGesture.scale = 1;
//
//        if (lastScale == theGesture.scale) {
//            return;
//        }
//        UIView *pinchView = currentImageView;
//        CGRect bounds = pinchView.bounds;
//        CGPoint pinchCenter = [theGesture locationInView:pinchView];
//        pinchCenter.x -= CGRectGetMidX(bounds);
//        pinchCenter.y -= CGRectGetMidY(bounds);
//        CGAffineTransform transform = pinchView.transform;
//        transform = CGAffineTransformTranslate(transform, pinchCenter.x, pinchCenter.y);
//
//        CGFloat currentScale = [[currentImageView.layer valueForKeyPath:@"transform.scale"] floatValue];
//
//        // Constants to adjust the max/min values of zoom
//        const CGFloat kMaxScale = 2.0;
//        const CGFloat kMinScale = 1.0;
//
//        CGFloat newScale = 1 -  (lastScale - [theGesture scale]);
//
//        newScale = MIN(newScale, kMaxScale / currentScale);
//        newScale = MAX(newScale, kMinScale / currentScale);
//
//
//        CGFloat scale = theGesture.scale;
//        transform = CGAffineTransformScale(transform, newScale, newScale);
//        transform = CGAffineTransformTranslate(transform, -pinchCenter.x, -pinchCenter.y);
//        pinchView.transform = transform;
//        lastScale = theGesture.scale;
//
//    }
//}
#pragma mark - Methods
-(void) gestureStateChanged:(id)gesture withZoomImageView:(UIImageView*)imageView {
    
    // Insure user is passing correct UIPinchGestureRecognizer class.
    if (![gesture isKindOfClass:[UIPinchGestureRecognizer class]]) {
        NSLog(@"(TMImageZoom): Must be using a UIPinchGestureRecognizer, currently you're using a: %@",[gesture class]);
        return;
    }
    
    UIPinchGestureRecognizer *theGesture = gesture;
    

    // Reset zoom if state = UIGestureRecognizerStateEnded
    if (theGesture.state == UIGestureRecognizerStateEnded || theGesture.state == UIGestureRecognizerStateCancelled || theGesture.state == UIGestureRecognizerStateFailed) {
        [self resetImageZoom];
        return;
    }
    // Prevent animation issues if currently animating reset.
    if (isAnimatingReset) {
        return;
    }
    // Ignore other views trying to start zoom if already zooming with another view
    if (isHandlingGesture && hostImageView != imageView) {
        NSLog(@"(TMImageZoom): 'gestureStateChanged:' ignored since this imageView isnt being tracked");
        return;
    }
    
    // Start handling gestures if state = UIGestureRecognizerStateBegan and not already handling gestures.
    if (!isHandlingGesture && theGesture.state == UIGestureRecognizerStateBegan) {
        lastScale = theGesture.scale;
        isHandlingGesture = YES;
        
        // Set Host ImageView
        hostImageView = imageView;
        imageView.hidden = YES;
        
        // Convert local point to window coordinates
        CGPoint point = [imageView.superview convertPoint:imageView.frame.origin toView:nil];
        
        
        startingRect = CGRectMake(point.x, point.y, imageView.frame.size.width, imageView.frame.size.height);
        
        // Post Notification
       // [[NSNotificationCenter defaultCenter] postNotificationName:TMImageZoom_Started_Zoom_Notification object:nil];
        
        // Get current window and set starting vars
        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        firstCenterPoint = [theGesture locationInView:currentWindow];
        
        
        // Init zoom ImageView
        currentImageView = [[UIImageView alloc] initWithImage:imageView.image];
        currentImageView.contentMode = imageView.contentMode;
        currentImageView.clipsToBounds = true;
        [currentImageView setFrame:startingRect];
        
        
        CGFloat currentScale = currentImageView.frame.size.width / startingRect.size.width;
        //        NSLog(@"Last scale %f", lastScale);
        //        NSLog(@"Current scale %f", currentScale);
        CGFloat newScale = currentScale * theGesture.scale;
        //        NSLog(@"gesture. new scale = %f current Scale = %f", newScale , currentScale);
        
        if (newScale < 1)
        {
            
            imageView.hidden = NO;
            return;
        }
        
        [currentWindow addSubview:currentImageView];
        
        
    }
    
    
    // Update scale & center
    if ((theGesture.state == UIGestureRecognizerStateChanged) && (theGesture.numberOfTouches == 2)) {
        
//        if ((((lastScale - theGesture.scale) > 0.0) && ((lastScale - theGesture.scale) < 0.5)) || ((theGesture.scale - lastScale) > 0.0) && ((theGesture.scale - lastScale) < 0.5)) {
//            return;
//        }
        UIView *pinchView = currentImageView;
        CGRect bounds = pinchView.bounds;
        CGPoint pinchCenter = [theGesture locationInView:pinchView];
        pinchCenter.x -= CGRectGetMidX(bounds);
        pinchCenter.y -= CGRectGetMidY(bounds);
       
        CGAffineTransform transform = pinchView.transform;
        transform = CGAffineTransformTranslate(transform, pinchCenter.x, pinchCenter.y);

        CGFloat currentScale = [[currentImageView.layer valueForKeyPath:@"transform.scale"] floatValue];
        
        // Constants to adjust the max/min values of zoom
        const CGFloat kMaxScale = 3.0;
        const CGFloat kMinScale = 1.0;
        // Constants to adjust the max/min values of zoom
        
        CGFloat newScale = 1 -  (lastScale - [theGesture scale]);
        
        newScale = MIN(newScale, kMaxScale / currentScale);
        newScale = MAX(newScale, kMinScale / currentScale);
        
        
//        CGFloat scale = theGesture.scale;
        transform = CGAffineTransformScale(transform, newScale, newScale);
        transform = CGAffineTransformTranslate(transform, -pinchCenter.x, -pinchCenter.y);
        pinchView.transform = transform;
        lastScale = theGesture.scale;
        
    }
}
-(void) resetImageZoom {
    // If not already animating
    if (isAnimatingReset || !isHandlingGesture) {
        return;
    }
    
    // Prevent further scale/center updates
    isAnimatingReset = YES;
    
    // Animate image zoom reset and post zoom ended notification
    [UIView animateWithDuration:0.2 animations:^{
        currentImageView.frame = startingRect;
    } completion:^(BOOL finished) {
        [currentImageView removeFromSuperview];
        currentImageView = nil;
        hostImageView.hidden = NO;
        hostImageView = nil;
        startingRect = CGRectZero;
        firstCenterPoint = CGPointZero;
        isHandlingGesture = NO;
        isAnimatingReset = NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TMImageZoom_Ended_Zoom_Notification object:nil];
    }];
}

-(void)moveImage:(UIPanGestureRecognizer *)sender{
    
//    NSLog(@"------------------------------------pan tapped-------------------------");
//    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
//    CGPoint translation = [sender translationInView:currentImageView];
//    NSLog(@"translate :- (x) %f      (y) %f",translation.x, translation.y);
    
    if (sender.state == UIGestureRecognizerStateBegan){
        panCoord = [sender locationInView:currentImageView];
        isFirst = YES;
       //currentImageView.frame = CGRectMake(currentImageView.frame.origin.x+panCoord.x, currentImageView.frame.origin.y+panCoord.y, currentImageView.frame.size.width, currentImageView.frame.size.height);
    }
    
    if (sender.state == UIGestureRecognizerStateChanged && isFirst && sender.numberOfTouches == 1){
        //NSLog(@"%@",NSStringFromCGPoint(currentImageView.center));
        //currentImageView.frame = currentImageView.frame;
        //NSLog(@"%@",NSStringFromCGPoint(currentImageView.center));
        panCoord = [sender locationInView:currentImageView];
        isFirst = NO;
        //return;
    }else if(sender.state == UIGestureRecognizerStateChanged && isFirst == NO /*&& sender.numberOfTouches == 2*/){
            CGPoint newCoord = [sender locationInView:currentImageView];
        
            float dX = newCoord.x-panCoord.x;
            float dY = newCoord.y-panCoord.y;
            currentImageView.frame = CGRectMake(currentImageView.frame.origin.x+dX, currentImageView.frame.origin.y+dY, currentImageView.frame.size.width, currentImageView.frame.size.height);
    }else if(sender.state == UIGestureRecognizerStateChanged && sender.numberOfTouches == 2){
        CGPoint newCoord = [sender locationInView:currentImageView];
        
        float dX = newCoord.x-panCoord.x;
        float dY = newCoord.y-panCoord.y;
        currentImageView.frame = CGRectMake(currentImageView.frame.origin.x+dX, currentImageView.frame.origin.y+dY, currentImageView.frame.size.width, currentImageView.frame.size.height);
    }
    /*if (sender.state == UIGestureRecognizerStateChanged && sender.numberOfTouches == 1*//*)
    {
        CGPoint newCoord = [sender locationInView:currentImageView];
        float dX = newCoord.x-panCoord.x;
        float dY = newCoord.y-panCoord.y;
        currentImageView.frame = CGRectMake(currentImageView.frame.origin.x+dX, currentImageView.frame.origin.y+dY, currentImageView.frame.size.width, currentImageView.frame.size.height);
        
        [sender setTranslation:CGPointZero inView:currentImageView];

    }*/
    else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateFailed){
        
        [self resetImageZoom];
    }
    
}

#pragma mark - Properties

-(BOOL) isHandlingGesture {
    return isHandlingGesture;
}

#pragma mark - Shared Instance
+(TMImageZoom *) shared
{
    if(!tmImageZoom)
    {
        tmImageZoom = [[TMImageZoom alloc]init];
    }
    return tmImageZoom;
    
}
@end
