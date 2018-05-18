//
//  CCPageControl.h
//
//  Created by GP on 06/01/16.
//  Copyright © 2016. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef enum
{
	CCPageControlTypeOnFullOffFull,
	CCPageControlTypeOnFullOffEmpty,
	CCPageControlTypeOnEmptyOffFull,
	CCPageControlTypeOnEmptyOffEmpty,
}
CCPageControlType ;


@interface CCPageControl : UIControl 
{
	NSInteger numberOfPages ;
	NSInteger currentPage ;
}

@property (nonatomic) NSInteger numberOfPages ;
@property (nonatomic) NSInteger currentPage ;
@property (nonatomic) BOOL hidesForSinglePage ;
@property (nonatomic) BOOL defersCurrentPageDisplay ;
@property (nonatomic) CCPageControlType type ;
@property (nonatomic,retain) UIColor *onColor ;
@property (nonatomic,retain) UIColor *offColor ;
@property (nonatomic) CGFloat indicatorDiameter ;
@property (nonatomic) CGFloat indicatorSpace ;

- (void)updateCurrentPageDisplay ;
- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount ;
- (id)initWithType:(CCPageControlType)theType ;

@end

