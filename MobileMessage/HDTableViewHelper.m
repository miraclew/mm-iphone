//
//  HDTableViewHelper.m
//  TestVoice
//
//  Created by  on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HDTableViewHelper.h"

#define LoadMoreCellId @"LoadMoreCell"

@interface HDTableViewHelper()
- (void)updatePullViewFrame;
- (int)needLoadMore:(int)section;
- (BOOL)isLoadCompleted;
@end

@implementation HDTableViewHelper
@synthesize delegate = _delegate, tableView = _tableView, dragType = _dragType;
@synthesize dragDownView, dragUpView;
@synthesize userLoad = _userLoad;
@synthesize tag;
@synthesize textColor = _textColor;
@synthesize firstInitLoad = _firstInitLoad;

- (void)dealloc {
    if (dragDownView) {
        [dragDownView removeFromSuperview];
        [dragDownView release];
    }
    if (dragUpView) {
        [dragUpView removeFromSuperview];
        [dragUpView release];
    }
    if (_sectionInfo)
        free(_sectionInfo);
    [_textColor release];
    [super dealloc];
    
}

-(id)init
{
    if (self = [super init]) {
        _isLoadForwardCompleted = YES;
        _isLoadBackCompleted = YES;
    }
    return self;
}

- (void)setDelegate:(id)delegate {
    BOOL isValid = delegate != nil;
    
    _flags.delegateRespondToViewDidScroll = isValid && [delegate respondsToSelector:@selector(scrollViewDidScroll:)];
    _flags.delegateRespondToViewDidEndGragging = isValid && [delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)];
    _flags.delegateRespondToAccessoryCellForSection = isValid && [delegate respondsToSelector:@selector(accessoryCellForSection:flag:reuseIdentifier:)];
    _flags.delegateRespondToNumberOfSectionsInTableView = isValid && [delegate respondsToSelector:@selector(numberOfSectionsInTableView:)];
    _delegate = delegate;
}

- (void)setTableView:(UITableView *)tableView {
    if (!tableView) {
        if (_tableView.delegate == self)
            _tableView.delegate = nil;
        if (_tableView.dataSource == self)
            _tableView.dataSource = nil;
    }
    _tableView = tableView;
    if (_tableView) {
        _tableView.delegate = self;
        _tableView.dataSource = self;
	}
}

- (void)setDragType:(NSInteger)dragType {
    _dragType = dragType;
    if ((dragType & HDTableViewDragDown) == HDTableViewDragDown) {
        EGORefreshTableHeaderView* view = nil;
        if (_textColor) {
            view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -65.0f, _tableView.frame.size.width, 65.0f)
                                                     arrowImageName:@"refresh.png" 
                                                          textColor:_textColor 
                                                              ddown:YES];
        }
        else {
            view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -65.0f, _tableView.frame.size.width, 65.0f)];
        }
        view.delegate = self;
        [_tableView addSubview:view];
        self.dragDownView = view;
        [view release];
    }
    else
    {
        if(dragDownView)
        {
            [dragDownView  removeFromSuperview];
            [dragDownView release];
            dragDownView = nil;
        }
    }
    self.dragUpView = nil;
    /*
     if ((dragType & HDTableViewDragUp) == HDTableViewDragUp) {
     CGFloat width = _tableView.frame.size.width;
     CGFloat originY = _tableView.contentSize.height;
     CGFloat originX = _tableView.contentOffset.x;    
     if (originY < _tableView.frame.size.height)
     originY = _tableView.frame.size.height;  
     EGORefreshTableHeaderView* view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(originX, originY, width, 65.0f) arrowImageName:@"refresh.png" textColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0] ddown:NO];
     ;
     view.delegate = self;
     [_tableView addSubview:view];
     self.dragUpView = view;
     [view release];
     }
     */
}

- (BOOL)hasForwardLoadMoreinSection:(int)section
{
    int count = [self needLoadMore:section];
    if((count == 1 && (_dragType & HDTableViewLoadForword) && _isLoadBackCompleted) || count == 2){
        return YES;
    }
    return NO;
}

- (void)initCellFlags:(NSInteger)sectionCount {
    if (_sectionInfo)
        free(_sectionInfo);
    _sectionInfo = malloc(sizeof(HDTableViewSectionInfo) * sectionCount);
    _sectionCount = sectionCount;
    for (NSInteger i = 0; i < sectionCount; ++i) {
        NSInteger flags = [_delegate accessoryCellFlagForSection:i];
        _sectionInfo[i].cellFlags.needNoData = (flags & HDTableViewCellFlagNeedNoData) ? 1 : 0;
        _sectionInfo[i].cellFlags.needLoadingMore = (flags & HDTableViewCellFlagNeedLoadingMore) ? 1 : 0;
        _sectionInfo[i].cellFlags.needLoadingError = (flags & HDTableViewCellFlagNeedLoadingError) ? 1 : 0;
        _sectionInfo[i].rowCount = 0;
    }
}

- (BOOL)needNoDataCell:(NSInteger)section {
    if (_sectionInfo && section < _sectionCount && _sectionInfo[section].cellFlags.needNoData)
        return YES;
    return NO;
}

- (BOOL)needLoadingMoreCell:(NSInteger)section {
    if (_sectionInfo && section < _sectionCount && _sectionInfo[section].cellFlags.needLoadingMore)
        return YES;
    return NO;    
}

- (BOOL)needLoadingErrorCell:(NSInteger)section {
    if (_sectionInfo && section < _sectionCount && _sectionInfo[section].cellFlags.needLoadingError)
        return YES;
    return NO;        
}

- (UITableViewCell*)loadingMoreCell:(NSInteger)section {
	static NSString *loadingCellIdentifier = LoadMoreCellId;
    float cellHeight = 0.0;
    if(_delegate && [_delegate respondsToSelector:@selector(heighForLoadMoreCell)])
    {
        cellHeight = [_delegate heighForLoadMoreCell];
    }
    else
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        CGRect frame = [self.tableView rectForRowAtIndexPath:indexPath];
        cellHeight = frame.size.height;
    }

	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:loadingCellIdentifier];
    if (!cell && _flags.delegateRespondToAccessoryCellForSection) {
        cell = [_delegate accessoryCellForSection:section flag:HDTableViewCellFlagNeedLoadingMore reuseIdentifier:loadingCellIdentifier];
    }
	 
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadingCellIdentifier] autorelease];
        UILabel *loadingLabel  = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width / 2 - 30, (cellHeight) / 2 - 8, 100,15 )];
        loadingLabel.backgroundColor = [UIColor clearColor];
        loadingLabel.font = [UIFont fontWithName:@"Arial" size:12.0];
        loadingLabel.textColor =  [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:153.0/255.0];
        loadingLabel.textAlignment = UITextAlignmentLeft;
        loadingLabel.text = @"数据加载中...";
        [cell.contentView addSubview:loadingLabel];
        [loadingLabel release];
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.tag  = 623672;
		spinner.center = CGPointMake(self.tableView.frame.size.width / 2  - 60, cellHeight / 2);
        [cell.contentView addSubview:spinner];
		[spinner release];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    
    //每次都需要调用 [spinnerww startAnimating]  否则ios6.0以上版本无法显示UIActivityIndicatorView
    UIActivityIndicatorView *spinnerww = (UIActivityIndicatorView *)[cell.contentView viewWithTag:623672];
    if(spinnerww && [spinnerww isKindOfClass:[UIActivityIndicatorView class]] && [spinnerww respondsToSelector:@selector(startAnimating)])
    {
        [spinnerww startAnimating];
    }
	return cell;
}

-(UITableViewCell *) loadingErrorCell:(NSInteger)section
{
    static NSString *loadFailedCellIdentifier = @"loadFailedCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:loadFailedCellIdentifier];
    if (!cell && _flags.delegateRespondToAccessoryCellForSection) {
        cell = [_delegate accessoryCellForSection:section flag:HDTableViewCellFlagNeedLoadingError reuseIdentifier:loadFailedCellIdentifier];
    }    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadFailedCellIdentifier] autorelease];
    }
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    cell.textLabel.text = @"";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(UITableViewCell *) noDataCell:(NSInteger)section
{
    static NSString *noDataCellIdentifier = @"NoDataCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:noDataCellIdentifier];
    if (!cell && _flags.delegateRespondToAccessoryCellForSection) {
        cell = [_delegate accessoryCellForSection:section flag:HDTableViewCellFlagNeedNoData reuseIdentifier:noDataCellIdentifier];
    }     
   if(cell == nil)
   {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noDataCellIdentifier] autorelease];
        cell.contentView.backgroundColor =  [UIColor colorWithPatternImage:[UIImage imageNamed:@"sys_bg2.png"]]; //[UIColor blueColor ];
        
        // float cellHeight  = [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        float  headHeight = [self.tableView tableHeaderView].frame.size.height;
        UIImage  *noDataImage = [UIImage imageNamed:@"nodate.png"];
        UIImageView *noDataImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.tableView.frame.size.width - noDataImage.size.width) / 2, (self.tableView.frame.size.height - noDataImage.size.height - headHeight) / 2, noDataImage.size.width, noDataImage.size.height)];
        noDataImageView.image = noDataImage;
        [cell.contentView addSubview:noDataImageView];
        [noDataImageView release];
   
       cell.selectionStyle = UITableViewCellSelectionStyleNone;
   }
    return cell;
}

- (BOOL)isLoading {
    return _loading;
}

- (void)startLoadingData {
    
    if(!_userLoad) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        self.tableView.contentInset = UIEdgeInsetsMake(65, 0, 0, 0);
        [dragDownView setState:EGOOPullRefreshLoading];
        if(_delegate && [_delegate respondsToSelector:@selector(reloadTableViewDataSource:)])
        {
            [_delegate reloadTableViewDataSource:YES];
            _userLoad = YES;
        }
        [UIView commitAnimations];
    }
    
}

- (void)resetLoadingDataStatus {
	_userLoad = NO;
}


- (void)beginLoadData {
    _loading = YES;
    if (_dragType & HDTableViewLoadForword) {
        _isLoadForwardCompleted = NO;
    }
    _isLoadBackCompleted = NO;
    _firstInitLoad = YES;
}

-(void) appendTableViewRowsWithDataCount : (NSInteger) dataCount  InSection : (NSInteger) section
{
    NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:dataCount + 1]; 
    NSInteger row = [self.tableView numberOfRowsInSection:section] - 2;
    for (int ind = 0; ind < dataCount; ind++) { 
        row ++ ;
        NSIndexPath    *newPath =  [NSIndexPath indexPathForRow:row inSection:section];
        [insertIndexPaths addObject:newPath];
    } 
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [_tableView endUpdates];
}

-(void)endLoadScrollWithNewDataCount:(int)count
{
    if (_dragType&HDTableViewLoadForword && count > 0) {
        
        if (_firstInitLoad && _direction == HDTableViewScrollDirectionDown && !_isLoadForwardCompleted) {
            //第一次刷新并且是向后刷新
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        else if(!_firstInitLoad && _direction == HDTableViewScrollDirectionUp){
            //非第一次刷新，并且是向前刷新
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:count inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }
}

- (void)endLoadDataWithNewDataCount : (NSInteger) newDataCount InSection : (NSInteger)section  Completed : (BOOL ) dataLoadCompleted {
    _loading = NO;
    if (_direction == HDTableViewScrollDirectionUp) {
        _isLoadForwardCompleted = dataLoadCompleted;
    }
    else
    {
        _isLoadBackCompleted = dataLoadCompleted;
    }
    
    [_tableView reloadData];

    if (self.dragDownView)
        [self.dragDownView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
    
    if (self.dragUpView) {
        [self.dragUpView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
        [self updatePullViewFrame];
    }   
    
    [self endLoadScrollWithNewDataCount:newDataCount];
    
    _firstInitLoad = NO;
}
- (void)endLoadData : (BOOL) dataLoadCompleted
{
    if (_direction == HDTableViewScrollDirectionUp) {
        _isLoadForwardCompleted = dataLoadCompleted;
    }
    else
    {
        _isLoadBackCompleted = dataLoadCompleted;
    }
    _loading = NO;
    [_tableView reloadData];
    if (self.dragDownView)
        [self.dragDownView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
    
    if (self.dragUpView) {
        [self.dragUpView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
        [self updatePullViewFrame];
    }
    [self endLoadScrollWithNewDataCount:1];
    _firstInitLoad = NO;
}

- (void)updatePullViewFrame {
    if (dragUpView != nil) {        
        CGFloat width = _tableView.frame.size.width;        
        CGFloat originY = _tableView.contentSize.height;        
        CGFloat originX = _tableView.contentOffset.x;        
        if (originY < _tableView.frame.size.height) {            
            originY = _tableView.frame.size.height;            
        }
        if (!CGRectEqualToRect(dragUpView.frame, CGRectMake(originX, originY, width, dragUpView.frame.size.height))) {
            dragUpView.frame = CGRectMake(originX, originY, width,  dragUpView.frame.size.height);  
        }
    }
    
}

/**
 *  判断需要显示几个LoadMore
 */
- (int)needLoadMore:(int)section
{
    int count = 0;
    if ((_dragType & HDTableViewLoadBack) && _sectionInfo[section].cellFlags.needLoadingMore && !_isLoadBackCompleted) {
        count ++;
    }
    if ((_dragType & HDTableViewLoadForword) && _sectionInfo[section].cellFlags.needLoadingMore && !_isLoadForwardCompleted) {
        count ++;
    }
    return count;
}

/**
 *  是否已Load完成，根据前次刷新方向来判断
 */
- (BOOL)isLoadCompleted
{
    if (_direction == HDTableViewScrollDirectionUp) {
        return _isLoadForwardCompleted;
    }
    else if (_direction == HDTableViewScrollDirectionDown){
        return _isLoadBackCompleted;
    }
    return YES;
}

- (HDTableViewScrollDirection)loadingDirection
{
    return _direction;
}

- (BOOL)loadFinishForDirection:(HDTableViewScrollDirection)directionValue
{
    if (directionValue == HDTableViewScrollDirectionUp) {
        return _isLoadForwardCompleted;
    }
    else if (directionValue == HDTableViewScrollDirectionDown){
        return _isLoadBackCompleted;
    }
    return YES;
}

- (void)setLoadFinishForDirection:(HDTableViewScrollDirection)directionValue Finishd:(BOOL)finished
{
    if (directionValue == HDTableViewScrollDirectionUp) {
        _isLoadForwardCompleted = finished;
    }
    else if (directionValue == HDTableViewScrollDirectionDown){
        _isLoadBackCompleted = finished;
    }
}

- (void)setCurLoadDirection:(HDTableViewScrollDirection)directionValue
{
    _direction = directionValue;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(scrollViewDidScroll:)
        || aSelector == @selector(scrollViewDidEndDragging:willDecelerate:)
        || aSelector == @selector(egoRefreshTableHeaderDidTriggerRefresh:)
        || aSelector == @selector(egoRefreshTableHeaderDataSourceIsLoading:)
        || aSelector == @selector(egoRefreshTableHeaderDataSourceLastUpdated:)
        || aSelector == @selector(numberOfSectionsInTableView:)
        )
        return YES;
    return [_delegate respondsToSelector:aSelector];
    
    //    if (aSelector == @selector(tableView:willDisplayCell:forRowAtIndexPath:)
    //        || aSelector == @selector(tableView:heightForRowAtIndexPath:)
    //        || aSelector == @selector(tableView:heightForHeaderInSection:)
    //        || aSelector == @selector(tableView:heightForFooterInSection:)
    //        || aSelector == @selector(tableView:viewForHeaderInSection:)
    //        || aSelector == @selector(tableView:viewForFooterInSection:)
    //        || aSelector == @selector(tableView:accessoryTypeForRowWithIndexPath:)
    //        || aSelector == @selector(tableView:accessoryButtonTappedForRowWithIndexPath:)
    //        || aSelector == @selector(tableView:willSelectRowAtIndexPath:)
    //        || aSelector == @selector(tableView:willDeselectRowAtIndexPath:)
    //        || aSelector == @selector(tableView:editingStyleForRowAtIndexPath:)
    //        || aSelector == @selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)
    //        || aSelector == @selector(tableView:shouldIndentWhileEditingRowAtIndexPath:)
    //        || aSelector == @selector(tableView:willBeginEditingRowAtIndexPath:)
    //        || aSelector == @selector(tableView:didEndEditingRowAtIndexPath:)
    //        || aSelector == @selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)
    //        || aSelector == @selector(tableView:indentationLevelForRowAtIndexPath:)
    //        || aSelector == @selector(tableView:shouldShowMenuForRowAtIndexPath:)
    //        || aSelector == @selector(tableView:canPerformAction:forRowAtIndexPath:withSender:)
    //        || aSelector == @selector(tableView:performAction:forRowAtIndexPath:withSender:)
    //        || aSelector == @selector(tableView:numberOfRowsInSection:)
    //        || aSelector == @selector(tableView:cellForRowAtIndexPath:)
    //        || aSelector == @selector(numberOfSectionsInTableView:)
    //        || aSelector == @selector(tableView:titleForHeaderInSection:)
    //        || aSelector == @selector(tableView:titleForFooterInSection:)
    //        || aSelector == @selector(tableView:canEditRowAtIndexPath:)
    //        || aSelector == @selector(tableView:canMoveRowAtIndexPath:)
    //        || aSelector == @selector(sectionIndexTitlesForTableView:)
    //        || aSelector == @selector(tableView:sectionForSectionIndexTitle:atIndex:)
    //        || aSelector == @selector(tableView:commitEditingStyle:forRowAtIndexPath:)
    //        || aSelector == @selector(tableView:moveRowAtIndexPath:toIndexPath:)
    //        ) {
    //        return [delegate respondsToSelector:aSelector];
    //    }
    //    return NO;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [_delegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_delegate tableView:tableView heightForRowAtIndexPath:indexPath];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [_delegate tableView:tableView heightForHeaderInSection:section];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return [_delegate tableView:tableView heightForFooterInSection:section];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {  
    return [_delegate tableView:tableView viewForHeaderInSection:section];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section { 
    return [_delegate tableView:tableView viewForFooterInSection:section];
}
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
    return [_delegate tableView:tableView accessoryTypeForRowWithIndexPath:indexPath];
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [_delegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}
- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_delegate tableView:tableView willDeselectRowAtIndexPath:indexPath];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_delegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_delegate tableView:tableView editingStyleForRowAtIndexPath:indexPath];
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_delegate tableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_delegate tableView:tableView shouldIndentWhileEditingRowAtIndexPath:indexPath];
}
- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [_delegate tableView:tableView willBeginEditingRowAtIndexPath:indexPath];
}
- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [_delegate tableView:tableView didEndEditingRowAtIndexPath:indexPath];
}
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    return [_delegate tableView:tableView targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
}
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_delegate tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
}
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_delegate tableView:tableView shouldShowMenuForRowAtIndexPath:indexPath];
}
- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return [_delegate tableView:tableView canPerformAction:action forRowAtIndexPath:indexPath withSender:sender];
}
- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    [_delegate tableView:tableView performAction:action forRowAtIndexPath:indexPath withSender:sender];
}


#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount = [_delegate tableView:tableView numberOfRowsInSection:section];
    _sectionInfo[section].rowCount = rowCount;
    int returnCount = 0;
    if (rowCount == 0 && [self needNoDataCell:section] && [self isLoadCompleted])
        returnCount =  1;
    if(rowCount > 0)
    {
         returnCount =  rowCount + [self needLoadMore:section];
    }
    return returnCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (_sectionInfo[section].rowCount == 0 && _sectionInfo[section].cellFlags.needNoData)
        return [self noDataCell:section];
    int count = [self needLoadMore:section];
    if (count == 0 ||( count == 1 && !(_dragType&HDTableViewLoadForword)) ||
        (count == 1 && (_dragType&HDTableViewLoadForword) && _isLoadForwardCompleted) ) {
        //不需要显示LoadMore
        //需要显示1个： 只有下翻模式
        //需要显示1个： 双向模式，但是上翻已经刷新完毕
        if ((row > 1 && count  > 0 && row == _sectionInfo[section].rowCount))
        {
            //需要显示1个，并且cell是最后一行
            return [self loadingMoreCell:section];
        }
    }
    else if(count == 1 && (_dragType & HDTableViewLoadForword) && _isLoadBackCompleted){
        //需要显示1个： 双向模式，下翻已经完毕
        if (row == 0) {
            return [self loadingMoreCell:section];
        }
    }
    else if(count == 2)
    {
        if (row == _sectionInfo[section].rowCount+1 ||row == 0)
        {
            return [self loadingMoreCell:section];
        }
    }
    return [_delegate tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:LoadMoreCellId]) {
        return nil;
    }
//    int count = [self needLoadMore:indexPath.section];
//    if (count == 2 || (count == 1 && (_dragType & HDTableViewLoadForword) && _isLoadBackCompleted)) {
//        return [_delegate tableView:tableView willSelectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]];
//    }
    return [_delegate tableView:tableView willSelectRowAtIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sectionCount = 1;
    if (_flags.delegateRespondToNumberOfSectionsInTableView)
        sectionCount = [_delegate numberOfSectionsInTableView:tableView];
    if (sectionCount > 0)
        [self initCellFlags:sectionCount];
    return sectionCount;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [_delegate tableView:tableView titleForHeaderInSection:section];
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [_delegate tableView:tableView titleForFooterInSection:section];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_delegate tableView:tableView canEditRowAtIndexPath:indexPath];
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_delegate tableView:tableView canMoveRowAtIndexPath:indexPath];
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [_delegate sectionIndexTitlesForTableView:tableView];
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [_delegate tableView:tableView sectionForSectionIndexTitle:title atIndex:index];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [_delegate tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [_delegate tableView:tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}



#pragma UIScrollViewDelegate


- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [_delegate scrollViewDidZoom:scrollView];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [_delegate scrollViewDidEndScrollingAnimation:scrollView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return [_delegate viewForZoomingInScrollView:scrollView];
}   // return a view that will be scaled. if delegate returns nil, nothing happens
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view 
{
    [_delegate scrollViewWillBeginZooming:scrollView withView:view];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale{
    
    [_delegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
} // scale between minimum and maximum. called after any 'bounce' animations

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView;  
{
    return [_delegate scrollViewShouldScrollToTop:scrollView];
}
-(void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    [_delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}
// return a yes if you want to scroll to the top. if not defined, assumes YES
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [_delegate scrollViewDidScrollToTop:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [_delegate scrollViewWillBeginDragging:scrollView];
    
}
-(void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [_delegate scrollViewWillBeginDecelerating:scrollView];
}
-(void) scrollViewDidEndDecelerating : (UIScrollView *) scrollView
{
    [_delegate scrollViewDidEndDecelerating:scrollView];
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.dragDownView)
        [self.dragDownView egoRefreshScrollViewDidScroll:scrollView];
    
    if (self.dragUpView) 
        [self.dragUpView egoRefreshScrollViewDidScroll:scrollView];
    
    if (_flags.delegateRespondToViewDidScroll)
        [_delegate scrollViewDidScroll:scrollView];
    if(scrollView.dragging) {
        int sections = [self.tableView numberOfSections];
        int section =  sections -1;
        if(section > 0){
            for (int i = sections; i >=0 ; i--) {
                if([self needLoadingMoreCell:i])
                {
                    section = i;
                    break;
                }
            }
        }
        
        HDTableViewScrollDirection scrollDirection;
        if (_lastContentOffset > scrollView.contentOffset.y)
            scrollDirection = HDTableViewScrollDirectionUp;
        else if (_lastContentOffset < scrollView.contentOffset.y)
            scrollDirection = HDTableViewScrollDirectionDown;
        _lastContentOffset = scrollView.contentOffset.x;
        
        int rowCounts = [self.tableView numberOfRowsInSection:section ];//isLoadCompleted
        if (rowCounts >1 && scrollDirection == HDTableViewScrollDirectionDown && !_loading  && !_isLoadBackCompleted) { //没有数据，或者已经全部加载完毕，或者正在加载
            
            NSArray *indexPathes = [self.tableView indexPathsForVisibleRows];
            if (indexPathes.count > 0) {
                
                NSIndexPath *lastIndexPath = [indexPathes objectAtIndex:indexPathes.count - 1];
                if (rowCounts - lastIndexPath.row < 2) {
                    if(_delegate && [_delegate respondsToSelector:@selector(reloadTableViewDataSource:)])
                    {
                        _loading = YES;
                        _direction = HDTableViewScrollDirectionDown;
                        [_delegate reloadTableViewDataSource:NO];
                    }
                }
            }
            
        }
        if (rowCounts >1 && scrollDirection == HDTableViewScrollDirectionUp && !_loading  && !_isLoadForwardCompleted) { //没有数据，或者已经全部加载完毕，或者正在加载
            
            NSArray *indexPathes = [self.tableView indexPathsForVisibleRows];
            if (indexPathes.count > 0) {
                
                NSIndexPath *lastIndexPath = [indexPathes objectAtIndex:indexPathes.count - 1];
                if (lastIndexPath.row < 3) {
                    if(_delegate && [_delegate respondsToSelector:@selector(reloadTableViewDataSource:)])
                    {
                        _loading = YES;
                        _direction = HDTableViewScrollDirectionUp;
                        [_delegate reloadTableViewDataSource:YES];
                    }
                }
            }
            
        }
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerat
{
    if (self.dragDownView)
        [self.dragDownView egoRefreshScrollViewDidEndDragging:scrollView];
    if (self.dragUpView)
        [self.dragUpView egoRefreshScrollViewDidEndDragging:scrollView];
    
    if (_flags.delegateRespondToViewDidEndGragging)
        [_delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerat];
    
}


#pragma mark EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
    HDTableViewDragType dragType = HDTableViewDragNone;
    if (view == self.dragDownView)
        dragType = HDTableViewDragDown;
    else if (view == self.dragUpView)
        dragType = HDTableViewDragUp;
    if ([_delegate respondsToSelector:@selector(didTriggerTableRefresh:dragType:)]) {
        [_delegate didTriggerTableRefresh:self dragType:dragType];
    }
}


- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
    return _loading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
    return [NSDate date];
}

@end
