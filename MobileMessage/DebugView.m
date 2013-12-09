//
//  DebugViewController.m
//  TestVoice
//
//  Created by  on 12-7-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DebugView.h"

#ifdef __i386__

#define GSEVENT_TYPE 2
#define GSEVENT_FLAGS 12
#define GSEVENTKEY_KEYCODE 15
#define GSEVENT_TYPE_KEYUP 10

#define GS_EVENT_TYPE_OFFSET 2
// fields length (1 : 4 bytes)
#define GS_EVENT_TYPE_LEN 1
#define GS_EVENT_SUBTYPE_LEN 1
#define GS_EVENT_LOCATION_LEN 2
#define GS_EVENT_WINLOCATION_LEN 2
#define GS_EVENT_WINCONTEXTID_LEN 1
#define GS_EVENT_TIMESTAMP_LEN 4
#define GS_EVENT_WINREF_LEN 1
//#define GS_EVENT_FLAGS_LEN 1
//#define GS_EVENT_SENDERPID_LEN 1
//#define GS_EVENT_INFOSIZE_LEN 1


#define KEY_A           4
#define KEY_B           5
#define KEY_C           6
#define KEY_D           7
#define KEY_E           8
#define KEY_F           9
#define KEY_G           10
#define KEY_H           11
#define KEY_I           12
#define KEY_J           13
#define KEY_K           14
#define KEY_L           15
#define KEY_M           16
#define KEY_N           17
#define KEY_O           18
#define KEY_P           19
#define KEY_Q           20
#define KEY_R           21
#define KEY_S           22
#define KEY_T           23
#define KEY_U           24
#define KEY_V           25
#define KEY_W           26
#define KEY_X           27
#define KEY_Y           28
#define KEY_Z           29

#define KEY_SEMI        51
#define KEY_SLASH       56

#define KEY_LEFT        80
#define KEY_RIGHT       79
#define KEY_UP          82
#define KEY_DOWN        81
#define KEY_ESC         41

#define KEY_DEC			45 // 减少
#define KEY_INC			46 // 增加


@interface DebugView() {
    
}
- (CGPoint)calcOffset:(UIView*)view;
- (void)intoView:(UIView*)view;
- (void)outofView:(UIView*)view;
- (void)setCurrentView:(UIView*)view isNextOrder:(BOOL)isNextOrder;
@end


@implementation DebugViewApp

- (void)enumView:(UIView*)pView level:(int)level {
    for (UIView *view in pView.subviews) {
        NSLog(@"level:%d, %@", level + 1, NSStringFromClass([view class]));
        [self enumView:view level:level+1];
    }
}

- (void)getView {
    UIWindow *topWindow = [[[UIApplication sharedApplication].windows sortedArrayUsingComparator:^NSComparisonResult(UIWindow *win1, UIWindow *win2) {
        return win1.windowLevel - win2.windowLevel;
    }] lastObject];
    UIView *topView = [[topWindow subviews] lastObject];    
   // NSLog(@"%@", NSStringFromClass([topView class]));
    [self enumView:topView level:1];
}

- (UIView*)getTopView {
    /*
    UIWindow *topWindow = [[[UIApplication sharedApplication].windows sortedArrayUsingComparator:^NSComparisonResult(UIWindow *win1, UIWindow *win2) {
        return win1.windowLevel - win2.windowLevel;
    }] lastObject];
    UIView *topView = [[topWindow subviews] lastObject];    
    return topView;
     */
    return [[[UIApplication sharedApplication].keyWindow subviews] lastObject];
}


- (void)sendEvent:(UIEvent *)event
{
    [super sendEvent: event];
    if ([event respondsToSelector:@selector(_gsEvent)]) {
        
        // Key events come in form of UIInternalEvents.
        // They contain a GSEvent object which contains 
        // a GSEventRecord among other things
        int *eventMem;
        eventMem = (int *)[event performSelector:@selector(_gsEvent)];
        if (eventMem) {
            
            // So far we got a GSEvent :)
            int eventType = eventMem[GSEVENT_TYPE];
            if (eventType == GSEVENT_TYPE_KEYUP) {
                // Read flags from GSEvent
                int eventFlags = eventMem[GSEVENT_FLAGS];
                int tmp = eventMem[GSEVENTKEY_KEYCODE];
                UniChar *keycode = (UniChar *)&tmp;
                //[self getView]; return;
                UIView *view = [self getTopView];;                
                DebugView *debugView = [DebugView sharedInstance];
                if (*keycode == KEY_M && eventFlags) {
                    if ([debugView isStarted])
                        [debugView stop];
                    else
                        [debugView start:view];
                } else {
                    if ([debugView isStarted])
                        [debugView inputChar:*keycode flag:eventFlags];
                }
            }
        }
    }    
}

@end



@implementation DebugView


- (void)singleTap:(id)sender {
    [self removeFromSuperview];
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        //[self addGestureRecognizer: singleTap];
        [singleTap release];            
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)init {
	self = [super init];
	if (self) {
		_velocity = 1.f;
	}
	return self;
}

- (void)dealloc {
	[_label release];
    [super dealloc];
}

+ (DebugView*)sharedInstance {
    static DebugView* debugView = nil;
    if (!debugView) {
        debugView = [[DebugView alloc] init];
    }
    return debugView;
}


- (void)start:(UIView*)view {
    if (!_topView) {
        self.frame = view.bounds;
        [view addSubview:self];
        [view bringSubviewToFront:self];
        
        _topView = view;
        [self intoView:view];
		if (!_label) {
			_label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
			_label.backgroundColor = [UIColor clearColor];
			_label.font = [UIFont systemFontOfSize:50];
			_label.textColor = [UIColor redColor];
			_label.textAlignment = UITextAlignmentCenter;
			_label.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
			[self addSubview:_label];
		}
        memset(&_switches, 0, sizeof(_switches));
    }    
    
}

- (void)stop {
    [self removeFromSuperview];
    _switches.help = 0;
    _topView = _container = _view = nil;
}

- (BOOL)isStarted {
    return _topView != nil;
}

- (CGPoint)calcOffset:(UIView*)view {
    if (view == _topView)
        return CGPointMake(0, 0);
    else {
        CGPoint point = [self calcOffset:[view superview]];
		if ([view isKindOfClass:[UIScrollView class]] || [view isMemberOfClass:[UIScrollView class]]) {
//			NSLog(@"scrollViewOffset:%@",NSStringFromCGPoint(((UIScrollView *)view).contentOffset));
			CGPoint contentOffset = ((UIScrollView *)view).contentOffset;
			return CGPointMake(point.x + view.frame.origin.x - contentOffset.x, point.y + view.frame.origin.y - contentOffset.y);
		}else {
			return CGPointMake(point.x + view.frame.origin.x, point.y + view.frame.origin.y);
		}
    }
    
}

- (void)intoView:(UIView*)view {
    if (!view)
        return;
    _container = view;
    _offset = [self calcOffset:_container];
    if ([_container.subviews count] == 0)
        _view = nil;
    else
        [self setCurrentView:[_container.subviews objectAtIndex:0] isNextOrder:YES];
	
//	NSLog(@"%@",NSStringFromCGPoint(_offset));

}

- (void)outofView:(UIView*)view {
    if (view == _topView)
        return;
    _container = [view superview];
    [self setCurrentView:view isNextOrder:YES];
    _offset = [self calcOffset:_container];
	
//	NSLog(@"%@",NSStringFromCGPoint(_offset));
}

- (void)nextView {
    if (_view == nil)
        return;
    if ([_container.subviews count] == 0)
        return;
    int index = [_container.subviews indexOfObject:_view];
    index++;
    if (index >= [_container.subviews count])
        index = 0;
    [self setCurrentView:[_container.subviews objectAtIndex:index] isNextOrder:YES];
}

- (void)prevView {
    if (_view == nil)
        return;
    if ([_container.subviews count] == 0)
        return;
    int index = [_container.subviews indexOfObject:_view];
    index--;
    if (index < 0)
        index = [_container.subviews count] - 1;
    [self setCurrentView:[_container.subviews objectAtIndex:index] isNextOrder:NO];
}

- (void)moveLeft {
    if (_view == nil || _view == _topView)
        return;
    CGRect rect = _view.frame;
    rect.origin.x -= _velocity;//
    _view.frame = rect;
}

- (void)moveRight {
    if (_view == nil || _view == _topView)
        return;
    CGRect rect = _view.frame;
    rect.origin.x += _velocity;
    _view.frame = rect;
    
}

- (void)moveUp {
    if (_view == nil || _view == _topView)
        return;
    CGRect rect = _view.frame;
    rect.origin.y -= _velocity;
    _view.frame = rect;
    
}

- (void)moveDown {
    if (_view == nil || _view == _topView)
        return;
    CGRect rect = _view.frame;
    rect.origin.y += _velocity;
    _view.frame = rect;
    
}

- (void)makeBigger:(BOOL)isWidth {
    if (_view == nil || _view == _topView)
        return;
    CGRect rect = _view.frame;
    if (isWidth)
        rect.size.width += _velocity;
    else
        rect.size.height += _velocity;
    _view.frame = rect;
    
}

- (void)makeSmaller:(BOOL)isWidth {
    if (_view == nil || _view == _topView)
        return;
    CGRect rect = _view.frame;
    if (isWidth)
        rect.size.width -= 1;
    else
        rect.size.height -= 1;
    _view.frame = rect;
    
}

- (void)setCurrentView:(UIView *)view isNextOrder:(BOOL)isNextOrder {
    if (view == self) {
        if ([_container.subviews count] == 1)
            _view = nil;
        else {
            _view = view;
            isNextOrder ? [self nextView] : [self prevView];
        }
    } else
        _view = view;
}

- (void)setVelocity:(UniChar)keyCode {
    if (keyCode == _lastCode && (keyCode == KEY_LEFT || keyCode == KEY_RIGHT || keyCode == KEY_UP || keyCode == KEY_DOWN)) {
		_velocity += 1;
		_velocity = MIN(20, _velocity);
	}else {
		_velocity = 1;
	}
//	NSLog(@"int setVelocity:%d",_velocity);

}

- (void)decreseVelocity {
	_velocity -= 1;
	_velocity = MAX(1, _velocity);
	[self showVelocityLabel];
}

- (void)increaseVelocity {
	_velocity += 1;
	[self showVelocityLabel];
}

- (void)showVelocityLabel {
	_label.text = [NSString stringWithFormat:@"%d",_velocity];
	if (_label.hidden == NO) {
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenVelocityLabel) object:nil];
		[self performSelector:@selector(hiddenVelocityLabel) withObject:nil afterDelay:1];
	}else {
		_label.hidden = NO;
		[self performSelector:@selector(hiddenVelocityLabel) withObject:nil afterDelay:1];
	}
}

- (void)hiddenVelocityLabel {
	_label.hidden = YES;
}

- (void)inputChar:(UniChar)keyCode flag:(int)flag {
    if (keyCode == KEY_ESC) {
        [self stop];
    } else if (keyCode == KEY_SLASH) {
        if (flag) {
            _switches.help = !_switches.help;
            [self setNeedsDisplay];
        }
    }
    if (_switches.help)
        return;
	
//	[self setVelocity:keyCode];
	
    if (keyCode == KEY_I) {
        [self intoView:_view];
    } else if (keyCode == KEY_O) {
        [self outofView:_container];
    } else if (keyCode == KEY_N) {
        [self nextView];
    } else if (keyCode == KEY_P) {
        [self prevView];
    } else if (keyCode == KEY_H) {
        _view.hidden = !_view.hidden;
    } else if (keyCode == KEY_LEFT) {
        flag ? [self makeSmaller:YES] : [self moveLeft];
    } else if (keyCode == KEY_RIGHT) {
        flag ? [self makeBigger:YES] : [self moveRight];
    } else if (keyCode == KEY_UP) {
        flag ? [self makeSmaller:NO] : [self moveUp];
    } else if (keyCode == KEY_DOWN) {
        flag ? [self makeBigger:NO] : [self moveDown];
    } else if (keyCode == KEY_DEC) {
		[self decreseVelocity];
	} else if (keyCode == KEY_INC) {
		[self increaseVelocity];
	}
//	_lastCode = keyCode;
	
    [self setNeedsDisplay];
}

- (void)drawOutline:(CGContextRef)context rect:(CGRect)rect {
    
    CGContextBeginPath(context);    
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y); //start point
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height); // end path
    CGContextClosePath(context); // close path
    CGContextStrokePath(context); // do actual stroking
    
}

- (void)showHelp:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 0.7, 0.7, 0.0, 0.8);
    CGContextFillRect(context, _topView.bounds);
    
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    NSString *help = @"使用方式:\n";
    help = [help stringByAppendingFormat:@"?: 切换帮助模式\n"];
    help = [help stringByAppendingFormat:@"ESC: 退出Debug模式\n"];
    help = [help stringByAppendingFormat:@"i: 进入当前View的下一级\n"];
    help = [help stringByAppendingFormat:@"o: 进入当前View的上一级\n"];    
    help = [help stringByAppendingFormat:@"n: 选中同级的下一个视图\n"];    
    help = [help stringByAppendingFormat:@"p: 选中同级的上一个视图\n"];    
    help = [help stringByAppendingFormat:@"h: 隐藏当前视图\n"];    
    help = [help stringByAppendingFormat:@"up: 向上移动当前的视图\n"];    
    help = [help stringByAppendingFormat:@"down: 向下移动当前的视图\n"];    
    help = [help stringByAppendingFormat:@"left: 向左移动当前的视图\n"];    
    help = [help stringByAppendingFormat:@"right: 向右移动当前的视图\n"];    
    help = [help stringByAppendingFormat:@"shift left: 减少当前的视图的宽度\n"];    
    help = [help stringByAppendingFormat:@"shift right: 增加当前的视图的宽度\n"];    
    help = [help stringByAppendingFormat:@"shift up: 减少当前的视图的高度\n"];    
    help = [help stringByAppendingFormat:@"shift down: 增加当前的视图的高度\n"];
	help = [help stringByAppendingFormat:@"- : 减少当前移动的速度，最小为1\n"];
	help = [help stringByAppendingFormat:@"+ : 增加当前移动的速度\n"];
    help = [help stringByAppendingFormat:@"\n颜色的含义：\n"];    
    help = [help stringByAppendingFormat:@"蓝色线框: 当前的容器视图\n"];    
    help = [help stringByAppendingFormat:@"绿色矩形: 当前容器视图的各个子视图\n"];    
    help = [help stringByAppendingFormat:@"红色矩形: 当前操作的视图，隶属于当前容器\n"];    
    [help drawInRect:CGRectOffset(rect, 5, 5) withFont:[UIFont fontWithName:@"Arial" size:12]];
}

- (void)drawRect:(CGRect)rect {
    if (_switches.help) {
        [self showHelp:rect];
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //画同级的视图
    for (int i = 0; i < [_container.subviews count]; i++) {
        UIView *subView = [_container.subviews objectAtIndex:i];
        if (subView == self || subView == _view)
            continue;
        CGContextSetRGBFillColor(context, 0.0, 1.0, 0.0, 0.5);            
        CGContextFillRect(context, CGRectOffset(subView.frame, _offset.x, _offset.y));
    }
    
    //画当前激活的视图
    if (_view) {
        CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 0.5);            
        CGContextFillRect(context, CGRectOffset(_view.frame, _offset.x, _offset.y));
    }
    
    //画容器的轮廓
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 1.0);
    CGContextSetLineWidth(context, 4.0);
    [self drawOutline:context rect:CGRectOffset(_container.bounds, _offset.x, _offset.y)];
    
    //显示当前视图的坐标
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);                
    NSString *viewName = [NSString stringWithFormat:@"%@, views:%d velocity:%d", NSStringFromClass([_view class]), [_container.subviews count] - 1,_velocity];
    [viewName drawAtPoint:CGPointMake(5, 15+20) withFont:[UIFont fontWithName:@"Arial" size:12.0]];
    NSString *text = [NSString stringWithFormat:@"\nx:%.1f, y:%.1f, width:%.1f, height:%.1f", _view.frame.origin.x, _view.frame.origin.y, _view.frame.size.width, _view.frame.size.height];    
    [text drawAtPoint:CGPointMake(5, 30+20) withFont:[UIFont fontWithName:@"Arial" size:12.0]];
}

- (void)setCurrentViewWithTouchPoint:(CGPoint)point {
	for (int ii=0; ii<[_container.subviews count]; ii++) {
		UIView *subView = [_container.subviews objectAtIndex:ii];
		if (subView == self)
			continue;
		if (CGRectContainsPoint(subView.frame, point)) {
			if (subView == _view) {
				if (subView.subviews.count >= 1) {
					[self intoView:_view];
				}else
					continue;
			}else {
				[self setCurrentView:subView isNextOrder:YES];
			}
			[self setNeedsDisplay];
//			break;
		}
	}
	
}

- (void)lookContainerView:(CGPoint)point { // 逐一退出 或是 退出到当前point点击区域包含的容器
	
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch * touch = [touches anyObject];
	_isMoved = NO;
	if (_container && _view) {
		CGPoint point = [touch locationInView:_container];
		if (CGRectContainsPoint(_view.frame, point)) {
			_location = [touch locationInView:_container];
		}
	}
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch * touch = [touches anyObject];
	if (_container && _view) {
		CGPoint point = [touch locationInView:_container];
		if (CGRectContainsPoint(_container.bounds, point) && CGRectContainsPoint(_view.frame, point)) {
//			NSLog(@"%f -- %f",point.x - _location.x,point.y - _location.y);
			CGRect frame = _view.frame;
			frame.origin.x += point.x - _location.x;
			frame.origin.y += point.y - _location.y;
			_view.frame = frame;
			_location = point;
			[self setNeedsDisplay];
			_isMoved = YES;
		}
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch * touch = [touches anyObject];
	if (_isMoved) {
		return;
	}
	if (_container) {
		CGPoint point = [touch locationInView:_container];
		if (!CGRectContainsPoint(_container.bounds, point)) {
			[self outofView:_container];
			point = [touch locationInView:_container];
		}
		if (!CGRectContainsPoint(_container.bounds, point)) {
			[self setNeedsDisplay];
		}
		else {
			[self setCurrentViewWithTouchPoint:point];
		}
		
	}
	
}

@end

#endif