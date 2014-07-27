//
//  MCSwipeTableViewCell.h
//  MCSwipeTableViewCell
//
//  Created by Ali Karagoz on 24/02/13.
//  Copyright (c) 2014 Ali Karagoz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCSwipeTableViewCell;
@class MCSwipeSection;

/** Describes the mode used during a swipe */
typedef NS_ENUM(NSUInteger, MCSwipeTableViewCellMode) {
    /** Disabled swipe.  */
    MCSwipeTableViewCellModeNone = 0,
    
    /** Upon swipe the cell if exited from the view. Useful for destructive actions. */
    MCSwipeTableViewCellModeExit,
    
    /** Upon swipe the cell if automatically swiped back to it's initial position. */
    MCSwipeTableViewCellModeSwitch
};

/**
 *  `MCSwipeCompletionBlock`
 *
 *  @param cell  Currently swiped `MCSwipeTableViewCell`.
 *  @param state `MCSwipeTableViewCellState` which has been triggered.
 *  @param mode  `MCSwipeTableViewCellMode` used for for swiping.
 *
 *  @return No return value.
 */
typedef void (^MCSwipeCompletionBlock)(MCSwipeTableViewCell *cell, MCSwipeSection *section);

@protocol MCSwipeTableViewCellDelegate;

@interface MCSwipeTableViewCell : UITableViewCell

/** Delegate of `MCSwipeTableViewCell` */
@property (nonatomic, assign) id <MCSwipeTableViewCellDelegate> delegate;

/** Damping of the physical spring animation. Expressed in percent. */
@property (nonatomic, assign, readwrite) CGFloat damping;

/** Velocity of the spring animation. Expressed in points per second (pts/s). */
@property (nonatomic, assign, readwrite) CGFloat velocity;

/** Duration of the animations. */
@property (nonatomic, assign, readwrite) NSTimeInterval animationDuration;

/** Color for background, when no state has been triggered. */
@property (nonatomic, strong, readwrite) UIColor *defaultColor;

/** Boolean indicator to know if the cell is currently dragged. */
@property (nonatomic, assign, readonly, getter=isDragging) BOOL dragging;

/** Boolean to enable/disable the dragging ability of a cell. */
@property (nonatomic, assign, readwrite) BOOL shouldDrag;

/** Boolean to enable/disable the animation of the view during the swipe.  */
@property (nonatomic, assign, readwrite) BOOL shouldAnimateIcons;

/** Section to the far left. */
@property (nonatomic, strong, readwrite) MCSwipeSection *farLeftSection;

/** Section to the middle left. */
@property (nonatomic, strong, readwrite) MCSwipeSection *midLeftSection;

/** Section to the middle right. */
@property (nonatomic, strong, readwrite) MCSwipeSection *midRightSection;

/** Section to the far right. */
@property (nonatomic, strong, readwrite) MCSwipeSection *farRightSection;

/**
 *  Swiped back the cell to it's original position
 *
 *  @param completion Callback block executed at the end of the animation.
 */
- (void)swipeToOriginWithCompletion:(void(^)(void))completion;

@end


@protocol MCSwipeTableViewCellDelegate <NSObject>

@optional

/**
 *  Called when the user starts swiping the cell.
 *
 *  @param cell `MCSwipeTableViewCell` currently swiped.
 */
- (void)swipeTableViewCellDidStartSwiping:(MCSwipeTableViewCell *)cell;

/**
 *  Called when the user ends swiping the cell.
 *
 *  @param cell `MCSwipeTableViewCell` currently swiped.
 */
- (void)swipeTableViewCellDidEndSwiping:(MCSwipeTableViewCell *)cell;

/**
 *  Called during a swipe.
 *
 *  @param cell         Cell that is currently swiped.
 *  @param percentage   Current percentage of the swipe movement. Percentage is calculated from the
 *                      left of the table view.
 */
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didSwipeWithPercentage:(CGFloat)percentage;

@end



@interface MCSwipeSection : NSObject

/**
 * Initializes the bare minimum for an 'MCSwipeSection'
 * @param trigger The percentage value that triggers the section to action.
 */
- (instancetype)initWithTrigger:(CGFloat)trigger;

/**
 * Initializes a'MCSwipeSection' object fully.
 * @param view The view displayed in the section.
 * @param color The background color of the section.
 * @param mode The swipe mode used to determine if the cell is a switch that stay, a switch that removes itself, or nothing.
 * @param trigger The percentage value that triggers the section to action.
 * @param completionBlock A block object to be executed after the section's animation has finished.
 */
- (instancetype)initWithView:(UIView *)view
                       color:(UIColor *)color
                        mode:(MCSwipeTableViewCellMode)mode
                     trigger:(CGFloat)trigger
             completionBlock:(MCSwipeCompletionBlock)completionBlock;

/** View triggered during a swipe */
@property (nonatomic, strong, readwrite) UIView *view;

/** The color triggered during a swipe. */
@property (nonatomic, strong, readwrite) UIColor *color;

/** The state triggered during a swipe. */
@property (nonatomic, assign) MCSwipeTableViewCellMode mode;

/** Block triggered during a swipe. */
@property (nonatomic, copy) MCSwipeCompletionBlock completionBlock;

/**
 * Percentage value to trigger section.
 * @warning 'trigger' must be from -1..1 and fit with the section next to it.
 */
@property (nonatomic, assign, readwrite) CGFloat trigger;

@end

