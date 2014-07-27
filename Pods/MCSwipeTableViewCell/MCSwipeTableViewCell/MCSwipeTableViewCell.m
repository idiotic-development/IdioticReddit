//
//  MCSwipeTableViewCell.m
//  MCSwipeTableViewCell
//
//  Created by Ali Karagoz on 24/02/13.
//  Copyright (c) 2014 Ali Karagoz. All rights reserved.
//

#import "MCSwipeTableViewCell.h"

static CGFloat const kMCStop1                       = 0.98; // Percentage limit to trigger the first action
static CGFloat const kMCStop2                       = 0.99; // Percentage limit to trigger the second action
static CGFloat const kMCDamping                     = 0.6;  // Damping of the spring animation
static CGFloat const kMCVelocity                    = 0.9;  // Velocity of the spring animation
static CGFloat const kMCAnimationDuration           = 0.4;  // Duration of the animation
static NSTimeInterval const kMCDurationLowLimit     = 0.25; // Lowest duration when swiping the cell because we try to simulate velocity
static NSTimeInterval const kMCDurationHighLimit    = 0.1;  // Highest duration when swiping the cell because we try to simulate velocity

typedef NS_ENUM(NSUInteger, MCSwipeTableViewCellDirection) {
    MCSwipeTableViewCellDirectionLeft = 0,
    MCSwipeTableViewCellDirectionCenter,
    MCSwipeTableViewCellDirectionRight
};


@interface MCSwipeTableViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, assign) MCSwipeTableViewCellDirection direction;
@property (nonatomic, assign) CGFloat currentPercentage;
@property (nonatomic, assign, getter=isExited) BOOL exited;
@property (nonatomic, assign, readwrite, getter=isDragging) BOOL dragging;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UIView *contentScreenshotView;
@property (nonatomic, strong) UIView *colorIndicatorView;
@property (nonatomic, strong) UIView *slidingView;
@property (nonatomic, strong) MCSwipeSection *activeSection;

// Initialization
- (void)initializer;
- (void)initDefaults;

// View Manipulation.
- (void)setupSwipingView;
- (void)uninstallSwipingView;
- (void)setViewOfSlidingView:(UIView *)slidingView;

// Percentage
- (CGFloat)offsetWithPercentage:(CGFloat)percentage;
- (CGFloat)offsetWithPercentage:(CGFloat)percentage relativeToWidth:(CGFloat)width;
- (CGFloat)percentageWithOffset:(CGFloat)offset;
- (CGFloat)percentageWithOffset:(CGFloat)offset relativeToWidth:(CGFloat)width;
- (NSTimeInterval)animationDurationWithVelocity:(CGPoint)velocity;
- (MCSwipeTableViewCellDirection)directionWithPercentage:(CGFloat)percentage;
- (UIView *)viewWithPercentage:(CGFloat)percentage;
- (CGFloat)alphaWithPercentage:(CGFloat)percentage;
- (UIColor *)colorWithPercentage:(CGFloat)percentage;

// Movement
- (void)animateWithOffset:(CGFloat)offset;
- (void)slideViewWithPercentage:(CGFloat)percentage view:(UIView *)view isDragging:(BOOL)isDragging;
- (void)moveWithDuration:(NSTimeInterval)duration andDirection:(MCSwipeTableViewCellDirection)direction;

// Completion block.
- (void)executeCompletionBlock;

@end

@implementation MCSwipeTableViewCell

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializer];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializer];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initializer];
    }
    return self;
}

- (void)initializer {
    
    [self initDefaults];
    
    // Setup Gesture Recognizer.
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    [self addGestureRecognizer:_panGestureRecognizer];
    _panGestureRecognizer.delegate = self;
}

- (void)initDefaults {
    
    _exited = NO;
    _dragging = NO;
    _shouldDrag = YES;
    _shouldAnimateIcons = YES;
    
    _damping = kMCDamping;
    _velocity = kMCVelocity;
    _animationDuration = kMCAnimationDuration;
    
    _defaultColor = [UIColor whiteColor];
    
    _activeSection = nil;

    _farLeftSection = [[MCSwipeSection alloc] initWithTrigger:kMCStop1];
    _midLeftSection = [[MCSwipeSection alloc] initWithTrigger:kMCStop2];
    _farRightSection = [[MCSwipeSection alloc] initWithTrigger:-kMCStop1];
    _midRightSection = [[MCSwipeSection alloc] initWithTrigger:-kMCStop2];
}

#pragma mark - Prepare reuse

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self uninstallSwipingView];
    [self initDefaults];
}

#pragma mark - View Manipulation

- (void)setupSwipingView {
    if (self.contentScreenshotView) {
        return;
    }
    
    // If the content view background is transparent we get the background color.
    BOOL isContentViewBackgroundClear = !self.contentView.backgroundColor;
    if (isContentViewBackgroundClear) {
        BOOL isBackgroundClear = [self.backgroundColor isEqual:[UIColor clearColor]];
        self.contentView.backgroundColor = isBackgroundClear ? [UIColor whiteColor] : self.backgroundColor;
    }
    
    if (isContentViewBackgroundClear) {
        self.contentView.backgroundColor = nil;
    }
    
    self.colorIndicatorView = [[UIView alloc] initWithFrame:self.bounds];
    self.colorIndicatorView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.colorIndicatorView.backgroundColor = self.defaultColor ? self.defaultColor : [UIColor clearColor];
    [self addSubview:self.colorIndicatorView];
    
    self.slidingView = [[UIView alloc] init];
    self.slidingView.contentMode = UIViewContentModeCenter;
    [self.colorIndicatorView addSubview:self.slidingView];
    
    self.contentScreenshotView = [self snapshotViewAfterScreenUpdates:NO];
    [self addSubview:self.contentScreenshotView];
}

- (void)uninstallSwipingView {
    if (!self.contentScreenshotView) {
        return;
    }
    
    [self.slidingView removeFromSuperview];
    self.slidingView = nil;
    
    [self.colorIndicatorView removeFromSuperview];
    self.colorIndicatorView = nil;
    
    [self.contentScreenshotView removeFromSuperview];
    self.contentScreenshotView = nil;
}

- (void)setViewOfSlidingView:(UIView *)slidingView {
    if (!self.slidingView) {
        return;
    }
    
    NSArray *subviews = [self.slidingView subviews];
    [subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [view removeFromSuperview];
    }];
    
    [self.slidingView addSubview:slidingView];
}

#pragma mark - Handle Gestures

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture {
    
    if (!self.shouldDrag || self.isExited) {
        return;
    }
    
    UIGestureRecognizerState state      = [gesture state];
    CGPoint translation                 = [gesture translationInView:self];
    CGPoint velocity                    = [gesture velocityInView:self];
    CGFloat percentage                  = [self percentageWithOffset:CGRectGetMinX(self.contentScreenshotView.frame)];
    NSTimeInterval animationDuration    = [self animationDurationWithVelocity:velocity];
    self.direction                      = [self directionWithPercentage:percentage];

    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
        self.dragging = YES;
        
        [self setupSwipingView];
        
        CGPoint center = {self.contentScreenshotView.center.x + translation.x, self.contentScreenshotView.center.y};
        self.contentScreenshotView.center = center;
        [self animateWithOffset:CGRectGetMinX(self.contentScreenshotView.frame)];
        [gesture setTranslation:CGPointZero inView:self];
        
        // Notifying the delegate that we are dragging with an offset percentage.
        if ([self.delegate respondsToSelector:@selector(swipeTableViewCell:didSwipeWithPercentage:)]) {
            [self.delegate swipeTableViewCell:self didSwipeWithPercentage:percentage];
        }
    } else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
        MCSwipeSection *section = [self sectionWithPercentage:percentage];
        
        self.dragging = NO;
        self.currentPercentage = percentage;
        self.activeSection = section;
        
        if (section.mode == MCSwipeTableViewCellModeExit && self.direction != MCSwipeTableViewCellDirectionCenter) {
            [self moveWithDuration:animationDuration andDirection:self.direction];
        } else {
            [self swipeToOriginWithCompletion:^{
                [self executeCompletionBlock];
            }];
        }
        
        // We notify the delegate that we just ended swiping.
        if ([self.delegate respondsToSelector:@selector(swipeTableViewCellDidEndSwiping:)]) {
            [self.delegate swipeTableViewCellDidEndSwiping:self];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if ([gestureRecognizer class] == [UIPanGestureRecognizer class]) {
        
        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point = [panGestureRecognizer velocityInView:self];
        
        if (fabsf(point.x) > fabsf(point.y) ) { // horizontal gesture
            if (point.x < 0 && !self.farRightSection.mode && !self.midRightSection.mode) {
                return NO;
            }
            
            if (point.x > 0 && !self.farLeftSection.mode && !self.midLeftSection.mode) {
                return NO;
            }
            
            // We notify the delegate that we just started dragging
            if ([self.delegate respondsToSelector:@selector(swipeTableViewCellDidStartSwiping:)]) {
                [self.delegate swipeTableViewCellDidStartSwiping:self];
            }
            
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Percentage
- (CGFloat)offsetWithPercentage:(CGFloat)percentage {
    return [self offsetWithPercentage:percentage relativeToWidth:CGRectGetWidth(self.bounds)];
}

- (CGFloat)offsetWithPercentage:(CGFloat)percentage relativeToWidth:(CGFloat)width {
    CGFloat offset = percentage * width;
    
    if (offset < -width)
        offset = -width;
    else if (offset > width)
        offset = width;
    
    return offset;
}

- (CGFloat)percentageWithOffset:(CGFloat)offset {
    return [self percentageWithOffset:offset relativeToWidth:CGRectGetWidth(self.bounds)];
}

- (CGFloat)percentageWithOffset:(CGFloat)offset relativeToWidth:(CGFloat)width {
    CGFloat percentage = offset / width;
    
    if (percentage < -1.0f)
        percentage = -1.0f;
    else if (percentage > 1.0f)
        percentage = 1.0f;
    
    return percentage;
}

- (NSTimeInterval)animationDurationWithVelocity:(CGPoint)velocity {
    CGFloat width                           = CGRectGetWidth(self.bounds);
    NSTimeInterval animationDurationDiff    = kMCDurationHighLimit - kMCDurationLowLimit;
    CGFloat horizontalVelocity              = velocity.x;
    
    if (horizontalVelocity < -width)
        horizontalVelocity = -width;
    else if (horizontalVelocity > width)
        horizontalVelocity = width;
    
    return (kMCDurationHighLimit + kMCDurationLowLimit) - fabs(((horizontalVelocity / width) * animationDurationDiff));
}

- (MCSwipeTableViewCellDirection)directionWithPercentage:(CGFloat)percentage {
    if (percentage < 0) {
        return MCSwipeTableViewCellDirectionLeft;
    } else if (percentage > 0) {
        return MCSwipeTableViewCellDirectionRight;
    } else {
        return MCSwipeTableViewCellDirectionCenter;
    }
}

- (UIView *)viewWithPercentage:(CGFloat)percentage {
    MCSwipeSection *section = [self sectionWithPercentage:percentage];
    
    if (!section) {
        section = (percentage > 0) ? self.farLeftSection : self.farRightSection;
    }
    
    return section.view;
}

- (MCSwipeSection *)sectionWithPercentage:(CGFloat)percentage {
    MCSwipeSection *section = nil;
    
    if (percentage >= self.farLeftSection.trigger && self.farLeftSection.mode) {
        section = self.farLeftSection;
    }
    if (percentage >= self.midLeftSection.trigger && self.midLeftSection.mode) {
        section = self.midLeftSection;
    }
    if (percentage <= self.farRightSection.trigger && self.farRightSection.mode) {
        section = self.farRightSection;
    }
    if (percentage <= self.midRightSection.trigger && self.midRightSection.mode) {
        section = self.midRightSection;
    }
    
    return section;
}

- (CGFloat)alphaWithPercentage:(CGFloat)percentage {
    CGFloat alpha;
    
    if (percentage >= 0 && percentage < self.farLeftSection.trigger) {
        alpha = percentage / self.farLeftSection.trigger;
    } else if (percentage < 0 && percentage > self.farRightSection.trigger) {
        alpha = fabsf(percentage / self.farRightSection.trigger);
    } else {
        alpha = 1.0f;
    }
    
    return alpha;
}

- (UIColor *)colorWithPercentage:(CGFloat)percentage {
    UIColor *color =  self.defaultColor ? self.defaultColor : [UIColor clearColor];
    
    UIColor *sectionColor = [self sectionWithPercentage:percentage].color;
    
    color = (sectionColor) ? sectionColor : color;
    
    return color;
}


#pragma mark - Movement

- (void)animateWithOffset:(CGFloat)offset {
    CGFloat percentage = [self percentageWithOffset:offset];
    
    UIView *view = [self viewWithPercentage:percentage];
    
    // View Position.
    if (view) {
        [self setViewOfSlidingView:view];
        self.slidingView.alpha = [self alphaWithPercentage:percentage];
        [self slideViewWithPercentage:percentage view:view isDragging:self.shouldAnimateIcons];
    }
    
    // Color
    UIColor *color = [self colorWithPercentage:percentage];
    
    if (color != nil) {
        self.colorIndicatorView.backgroundColor = color;
    }
}

- (void)slideViewWithPercentage:(CGFloat)percentage view:(UIView *)view isDragging:(BOOL)isDragging {
    if (!view) {
        return;
    }
    
    CGPoint position = CGPointZero;
    position.y = CGRectGetHeight(self.bounds) / 2.0;
    
    CGFloat halfFirstTriggerPercentage = (self.farLeftSection.trigger / 2);
    CGFloat halfThirdTriggerPercentage = fabsf((self.farRightSection.trigger/ 2));
    CGFloat boundsWidth = CGRectGetWidth(self.bounds);
    
    if (isDragging) {
        if (percentage >= 0 && percentage < self.farLeftSection.trigger) {// Section 01
            position.x = [self offsetWithPercentage:halfFirstTriggerPercentage];
        } else if (percentage >= self.farLeftSection.trigger) {// Section 02
            position.x = [self offsetWithPercentage:percentage - halfFirstTriggerPercentage];
        } else if (percentage < 0 && percentage >= self.farRightSection.trigger) { // Section 03
            position.x = boundsWidth - [self offsetWithPercentage:halfThirdTriggerPercentage];
        } else if (percentage < self.farRightSection.trigger) {// Section 04
            position.x = boundsWidth + [self offsetWithPercentage:percentage + halfThirdTriggerPercentage];
        }
    } else {
        if (self.direction == MCSwipeTableViewCellDirectionRight) {
            position.x = [self offsetWithPercentage:halfFirstTriggerPercentage];
        } else if (self.direction == MCSwipeTableViewCellDirectionLeft) {
            position.x = boundsWidth - [self offsetWithPercentage:halfThirdTriggerPercentage];
        } else {
            return;
        }
    }
    
    CGSize activeViewSize = view.bounds.size;
    CGRect activeViewFrame = CGRectMake(position.x - activeViewSize.width / 2.0,
                                        position.y - activeViewSize.height / 2.0,
                                        activeViewSize.width,
                                        activeViewSize.height);
    
    activeViewFrame = CGRectIntegral(activeViewFrame);
    self.slidingView.frame = activeViewFrame;
}

- (void)moveWithDuration:(NSTimeInterval)duration andDirection:(MCSwipeTableViewCellDirection)direction {
    
    self.exited = YES;
    CGFloat origin;
    
    if (direction == MCSwipeTableViewCellDirectionLeft) {
        origin = -CGRectGetWidth(self.bounds);
    } else if (direction == MCSwipeTableViewCellDirectionRight) {
        origin = CGRectGetWidth(self.bounds);
    } else {
        origin = 0;
    }
    
    CGFloat percentage = [self percentageWithOffset:origin];
    CGRect frame = self.contentScreenshotView.frame;
    frame.origin.x = origin;
    
    // Color
    UIColor *color = [self colorWithPercentage:self.currentPercentage];
    if (color) {
        [self.colorIndicatorView setBackgroundColor:color];
    }
    
    [UIView animateWithDuration:duration delay:0 options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
        self.contentScreenshotView.frame = frame;
        self.slidingView.alpha = 0;
        [self slideViewWithPercentage:percentage view:self.activeSection.view isDragging:self.shouldAnimateIcons];
    } completion:^(BOOL finished) {
        [self executeCompletionBlock];
    }];
}

- (void)swipeToOriginWithCompletion:(void(^)(void))completion {
    [UIView animateWithDuration:self.animationDuration delay:0.0 usingSpringWithDamping:self.damping initialSpringVelocity:self.velocity options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        CGRect frame = self.contentScreenshotView.frame;
        frame.origin.x = 0;
        self.contentScreenshotView.frame = frame;
        
        // Clearing the indicator view
        self.colorIndicatorView.backgroundColor = self.defaultColor;
        
        self.slidingView.alpha = 0;
        [self slideViewWithPercentage:0 view:self.activeSection.view isDragging:NO];
        
    } completion:^(BOOL finished) {
        
        self.exited = NO;
        [self uninstallSwipingView];
        
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - Completion block

- (void)executeCompletionBlock {
    MCSwipeSection *section = [self sectionWithPercentage:self.currentPercentage];
    
    if (section.completionBlock) {
        section.completionBlock(self, section);
    }
}


#pragma mark - Sections

- (NSArray *)swipeSections {
    return  @[self.farLeftSection, self.midLeftSection, self.farRightSection, self.midRightSection];
}

- (void)setFarLeftSection:(MCSwipeSection *)farLeftSection {
    NSParameterAssert(farLeftSection);
    NSAssert(farLeftSection.trigger > 0.0f && farLeftSection.trigger < self.midLeftSection.trigger, @"Impropper trigger for farLeft with a midLeft of %f", farLeftSection.trigger, self.midLeftSection.trigger);
    _farLeftSection = farLeftSection;
}

- (void)setMidLeftSection:(MCSwipeSection *)midLeftSection {
    NSParameterAssert(midLeftSection);
    NSAssert(self.farLeftSection.trigger < midLeftSection.trigger && midLeftSection.trigger < 1.0f, @"Impropper trigger for midLeft %f with a farLeft of %f", midLeftSection.trigger, self.farLeftSection.trigger);
    _midLeftSection = midLeftSection;
}

- (void)setFarRightSection:(MCSwipeSection *)farRightSection {
    NSParameterAssert(farRightSection);
    NSAssert(self.midRightSection.trigger < farRightSection.trigger && farRightSection.trigger < 0.0f, @"Impropper trigger for farRight %f with a midRight of %f", farRightSection.trigger, self.midRightSection.trigger);
    _farRightSection = farRightSection;
}

- (void)setMidRightSection:(MCSwipeSection *)midRightSection {
    NSParameterAssert(midRightSection);
    NSAssert(midRightSection.trigger > -1.0f && midRightSection.trigger < self.farRightSection.trigger,@"Impropper trigger for midRight %f with farRight of %f", midRightSection.trigger, self.farRightSection.trigger);
    _midRightSection = midRightSection;
}

@end


@implementation MCSwipeSection

- (instancetype)init {
    return nil;
}

- (instancetype)initWithTrigger:(CGFloat)trigger {
    return [self initWithView:nil
                        color:nil
                         mode:MCSwipeTableViewCellModeNone
                      trigger:trigger
              completionBlock:nil];
}

- (instancetype)initWithView:(UIView *)view
                       color:(UIColor *)color
                        mode:(MCSwipeTableViewCellMode)mode
                     trigger:(CGFloat)trigger
             completionBlock:(MCSwipeCompletionBlock)completionBlock {
    self = [super init];
    if (self) {
        _view = view;
        _color = color;
        _mode = mode;
        _completionBlock = completionBlock;
        NSAssert(trigger > -1.0f && trigger < 1.0f, @"Trigger is outside range.");
        _trigger = trigger;
    }
    
    return self;
}

- (void)setView:(UIView *)view {
    NSParameterAssert(view);
    _view = view;
}

- (void)setColor:(UIColor *)color {
    NSParameterAssert(color);
    _color = color;
}

- (void)setTrigger:(CGFloat)trigger {
    NSAssert(trigger > -1.0f && trigger < 1.0f, @"Trigger is outside range.");
    _trigger = trigger;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p; view = %@; color = %@; mode = %@; trigger = %@; completionBlock = %@>",self.class, self, self.view, self.color, @(self.mode), @(self.trigger),self.completionBlock];
}

- (NSUInteger)hash {
    return self.view.hash ^ self.color.hash ^ self.mode;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]])
        return NO;
    
    MCSwipeSection *otherSection = object;
    
    BOOL sameView = [self.view isEqual:otherSection.view];
    BOOL sameColor = [self.color isEqual:otherSection.color];
    BOOL sameMode = self.mode == otherSection.mode;
    
    return sameView && sameColor && sameMode; // Same blocks?
}

@end
