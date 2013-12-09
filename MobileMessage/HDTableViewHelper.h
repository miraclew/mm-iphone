//
//  HDTableViewHelper.h
//  TestVoice
//
//  Created by  on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGORefreshTableHeaderView.h"

typedef enum{
    HDTableViewDragNone = 0,
	HDTableViewDragDown = 1,
	HDTableViewDragUp = 2,
    HDTableViewDragBoth = 3,
    
    HDTableViewRefresh = 1,
    HDTableViewLoadBack = 2,
    HDTableViewLoadForword = 4
} HDTableViewDragType;

typedef enum{
    HDTableViewCellFlagNeedNoData = 1,
    HDTableViewCellFlagNeedLoadingMore = 2,
    HDTableViewCellFlagNeedLoadingError = 4
} HDTableViewCellFlag;

typedef struct {
    NSInteger       rowCount;
    struct {
        unsigned int needNoData:1;
        unsigned int needLoadingMore:1;
        unsigned int needLoadingError:1;
    }cellFlags;
}HDTableViewSectionInfo;

typedef enum  {
    HDTableViewScrollDirectionDown,//向后刷新
    HDTableViewScrollDirectionUp //向前刷新
} HDTableViewScrollDirection;

@interface HDTableViewHelper : NSObject<UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate> {
    UITableView         *_tableView;
    NSInteger           _dragType;
    struct {
        unsigned int delegateRespondToViewDidScroll:1;
        unsigned int delegateRespondToViewDidEndGragging:1;
        unsigned int delegateRespondToAccessoryCellForSection:1;
        unsigned int delegateRespondToNumberOfSectionsInTableView:1;
    } _flags;
    BOOL                _loading;
    BOOL                _isLoadBackCompleted;
    BOOL                _isLoadForwardCompleted;
    BOOL                _userLoad;
    BOOL                _firstInitLoad;
    NSInteger           _sectionCount;
    HDTableViewSectionInfo *_sectionInfo;
    
    HDTableViewScrollDirection _direction;
    float                      _lastContentOffset;
}
@property (assign,nonatomic) BOOL userLoad;
@property (assign, nonatomic) id delegate;
@property (assign, nonatomic) UITableView *tableView;
@property (assign, nonatomic) NSInteger dragType;
@property(retain, nonatomic) EGORefreshTableHeaderView *dragDownView;
@property(retain, nonatomic) EGORefreshTableHeaderView *dragUpView;
@property (assign, nonatomic) NSInteger tag;
@property (retain, nonatomic) UIColor *textColor;
//@property (assign, nonatomic) BOOL enableDrag;
@property (nonatomic,assign)BOOL firstInitLoad;

- (BOOL)isLoading;
- (HDTableViewScrollDirection)loadingDirection;
- (void)beginLoadData;
- (void)endLoadData : (BOOL) dataLoadCompleted;
- (void)endLoadDataWithNewDataCount : (NSInteger) newDataCount InSection : (NSInteger)section  Completed : (BOOL ) dataLoadCompleted ;
- (void)startLoadingData ;
- (void)resetLoadingDataStatus;
- (BOOL)loadFinishForDirection:(HDTableViewScrollDirection)directionValue;
- (void)setLoadFinishForDirection:(HDTableViewScrollDirection)directionValue Finishd:(BOOL)finished;
- (void)setCurLoadDirection:(HDTableViewScrollDirection)directionValue;
- (BOOL)hasForwardLoadMoreinSection:(int)section;
@end


@protocol HDTableViewHelperDelegate
@required
- (NSInteger)accessoryCellFlagForSection:(NSInteger)section;
@optional
- (UITableViewCell*)accessoryCellForSection:(NSInteger)section flag:(HDTableViewCellFlag)flag reuseIdentifier:reuseIdentifier;
- (void)didTriggerTableRefresh:(HDTableViewHelper*)helper dragType:(HDTableViewDragType)dragType;
- (void)reloadTableViewDataSource : (BOOL)dragDown;
- (float)  heighForLoadMoreCell;
@end
