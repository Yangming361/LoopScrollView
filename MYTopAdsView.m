//
//  MYTopAdsView.m
//  00_02_苏明阳
//
//  Created by qianfeng on 15/9/30.
//  Copyright (c) 2015年 ahnu. All rights reserved.
//

#import "MYTopAdsView.h"
#import "MYLocalTopScroll.h"
#import "UIImageView+AFNetworking.h"
@interface MYTopAdsView ()<UIScrollViewDelegate>

@property(nonatomic,weak) UIScrollView *scrollView;
@property(nonatomic,weak) UIPageControl *pageControl;
@property(nonatomic,strong) NSTimer *timer;
@end

@implementation MYTopAdsView
-(UIScrollView *)scrollView
{
    if (_scrollView == nil) {
        
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        
        [self addSubview:scrollView];
        
        scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        scrollView.delegate = self;
        scrollView.pagingEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        
        _scrollView = scrollView;
       
    }
    return _scrollView;
}
-(UIPageControl *)pageControl
{
    if (_pageControl == nil) {
        
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        pageControl.frame = CGRectMake(self.frame.size.width-230, 130, 100, 20);
        pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
        [self addSubview:pageControl];
        _pageControl = pageControl;
    }
    return _pageControl;
}

- (void)setBannerArray:(NSArray *)bannerArray
{
    _bannerArray = bannerArray;
    NSInteger index = 0;
    
    CGFloat imageViewX = 0;
    CGFloat imageViewY = 0;
    CGFloat imageViewW = self.scrollView.frame.size.width;
    CGFloat imageViewH = self.scrollView.frame.size.height;
    for (int i = 0; i < bannerArray.count; i++) {
        
    
        if (i == 0) {
            //在第一张图片之前添加最后一张图片
            MYLocalTopScroll *topScroll = [bannerArray lastObject];
            
            CGRect frame  = CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
            [self addImageViewWithTopScroll:topScroll frame:frame tag:index];
            
            index++;
            imageViewX +=imageViewW;
        }
        
        MYLocalTopScroll *topScroll = bannerArray[i];
        
        CGRect frame = CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
        
        [self addImageViewWithTopScroll:topScroll frame:frame tag:index];
        
        index++;
        
        imageViewX +=imageViewW;
        
        //判断是不是到最后一张图片
        if (i == bannerArray.count-1) {
            MYLocalTopScroll *topScroll = [bannerArray firstObject];
            
            CGRect frame  = CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
            [self addImageViewWithTopScroll:topScroll frame:frame tag:index];
            index++;
            imageViewX +=imageViewW;
        }
    }
    
    //再添加两个视图
    
    
    self.scrollView.contentSize = CGSizeMake((bannerArray.count+2) * self.scrollView.frame.size.width, 0);
    
    
    self.pageControl.numberOfPages = bannerArray.count;
    
     [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width, 0) animated:NO];
    
   [self startTimer];
    
}

- (void )addImageViewWithTopScroll:(MYLocalTopScroll *)topScroll frame:(CGRect )frame tag:(NSInteger )tag
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = frame;
    [self.scrollView addSubview:imageView];
    imageView.tag = tag;
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTouch:)];
    [imageView addGestureRecognizer:tap];
    [imageView setImageWithURL:[NSURL URLWithString:topScroll.Pic]];
    
}

- (void)imageViewTouch:(UITapGestureRecognizer *)tap
{

}

- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
    
    //加入主线程
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)autoScroll
{
    /*
    NSInteger index = self.pageControl.currentPage;
    
    index = index>=self.bannerArray.count-1?0:index+1;
    self.pageControl.currentPage = index;
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width*index, 0)];
    
    */
    
    //自动滚动
    NSInteger index = self.pageControl.currentPage;
    
    index = index>=self.bannerArray.count?1:index+1;
    self.pageControl.currentPage = index-1;
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width*(index+1), 0)];
    
    
}

#pragma mark -UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //+scrollView.frame.size.width*0.5
    NSInteger index = (scrollView.contentOffset.x +scrollView.frame.size.width*0.5)/scrollView.frame.size.width;
    if(index == 0)
    {//当前图片为最后一张图片
        //判断第一张图片滚动快结束时
        if (scrollView.contentOffset.x <= 10) {
            
             [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width*self.bannerArray.count-1, 0) animated:NO];
        }
       
        
        
    }else if (index >= 0 && index<=self.bannerArray.count)
    {
        // self.pageControl.currentPage = index-1; return;
    }else if (index == self.bannerArray.count+1)
    {
        //判断最后一张图片快滚动结束时
        if (scrollView.contentOffset.x >= self.scrollView.frame.size.width*(self.bannerArray.count+1)-10) {
            
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width, 0) animated:NO];
        }
       
        
        
    }
   index = (scrollView.contentOffset.x+scrollView.frame.size.width*0.5)/scrollView.frame.size.width;
    self.pageControl.currentPage = index-1;
   
   
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
   [self startTimer];
}


+ (id)topAdsView
{
    return [[self alloc] init];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    
    CGFloat selfY = 0;
    CGFloat selfX = 0;
    CGFloat selfW = newSuperview.frame.size.width;
    CGFloat selfH =  150;
    
    self.frame = CGRectMake(selfX, selfY, selfW, selfH);
    self.scrollView.frame = self.bounds;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
