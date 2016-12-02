#import "MWMToast.h"
#import "Common.h"
#import "UIColor+MapsMeColor.h"

namespace
{
void * kContext = &kContext;
NSString * const kKeyPath = @"sublayers";
NSUInteger const kWordsPerSecond = 3;
}  // namespace

@interface MWMToast ()

@property(nonatomic) IBOutlet UIVisualEffectView * rootView;
@property(nonatomic) IBOutlet UILabel * label;

@property(nonatomic) NSLayoutConstraint * bottomOffset;

@end

@implementation MWMToast

+ (void)showWithText:(NSString *)text
{
  MWMToast * toast = [MWMToast toast];
  toast.label.text = text;
  toast.label.textColor = [UIColor blackPrimaryText];
  [toast show];
}

+ (BOOL)affectsStatusBar { return [MWMToast toast].rootView.superview != nil; }
+ (UIStatusBarStyle)preferredStatusBarStyle
{
  return [UIColor isNightMode] ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

+ (MWMToast *)toast
{
  static MWMToast * toast;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    toast = [[super alloc] initToast];
  });
  return toast;
}

- (instancetype)initToast
{
  self = [super init];
  if (self)
  {
    [[NSBundle mainBundle] loadNibNamed:[MWMToast className] owner:self options:nil];
    self.rootView.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return self;
}

- (void)configLayout
{
  UIView * sv = self.rootView;
  [sv removeFromSuperview];

  UIView * ov = topViewController().view;
  [ov addSubview:sv];

  NSLayoutConstraint * topOffset = [NSLayoutConstraint constraintWithItem:sv
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:ov
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1
                                                                 constant:0];
  topOffset.priority = UILayoutPriorityDefaultLow;
  self.bottomOffset = [NSLayoutConstraint constraintWithItem:sv
                                                   attribute:NSLayoutAttributeBottom
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:ov
                                                   attribute:NSLayoutAttributeTop
                                                  multiplier:1
                                                    constant:0];
  self.bottomOffset.priority = UILayoutPriorityDefaultHigh;
  NSLayoutConstraint * leadingOffset =
      [NSLayoutConstraint constraintWithItem:sv
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:ov
                                   attribute:NSLayoutAttributeLeading
                                  multiplier:1
                                    constant:0];
  NSLayoutConstraint * trailingOffset =
      [NSLayoutConstraint constraintWithItem:sv
                                   attribute:NSLayoutAttributeTrailing
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:ov
                                   attribute:NSLayoutAttributeTrailing
                                  multiplier:1
                                    constant:0];
  [ov addConstraints:@[ topOffset, self.bottomOffset, leadingOffset, trailingOffset ]];
  [ov setNeedsLayout];
}

- (void)scheduleHide
{
  [NSObject cancelPreviousPerformRequestsWithTarget:self];
  NSString * text = self.label.text;
  NSArray<NSString *> * words = [text componentsSeparatedByString:@" "];
  NSTimeInterval const delay = MAX(2, 1 + words.count / kWordsPerSecond);
  [self performSelector:@selector(hide) withObject:nil afterDelay:delay];
}

- (void)show
{
  [self configLayout];

  UIView * ov = topViewController().view;
  runAsyncOnMainQueue(^{
    [ov layoutIfNeeded];
    self.bottomOffset.priority = UILayoutPriorityFittingSizeLevel;
    [UIView animateWithDuration:kDefaultAnimationDuration
        animations:^{
          [ov layoutIfNeeded];
        }
        completion:^(BOOL finished) {
          [self subscribe];
          [topViewController() setNeedsStatusBarAppearanceUpdate];
          [self scheduleHide];
        }];
  });
}

- (void)hide
{
  [self unsubscribe];

  UIView * ov = topViewController().view;
  [ov layoutIfNeeded];
  self.bottomOffset.priority = UILayoutPriorityDefaultHigh;
  [UIView animateWithDuration:kDefaultAnimationDuration
      animations:^{
        [ov layoutIfNeeded];
      }
      completion:^(BOOL finished) {
        [self.rootView removeFromSuperview];
        [topViewController() setNeedsStatusBarAppearanceUpdate];
      }];
}

- (void)subscribe
{
  UIView * sv = self.rootView;
  UIView * ov = sv.superview;
  CALayer * ol = ov.layer;
  [ol addObserver:self forKeyPath:kKeyPath options:NSKeyValueObservingOptionNew context:kContext];
}

- (void)unsubscribe
{
  UIView * sv = self.rootView;
  UIView * ov = sv.superview;
  CALayer * ol = ov.layer;
  [ol removeObserver:self forKeyPath:kKeyPath context:kContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  if (context == kContext)
  {
    UIView * sv = self.rootView;
    UIView * ov = sv.superview;
    [ov bringSubviewToFront:sv];
    return;
  }
  [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}
@end
