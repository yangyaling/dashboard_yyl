//
//  LifeRhythmDetailVC.m
//  DashBoard
//
//  Created by totyu3 on 17/1/20.
//  Copyright © 2017年 NIT. All rights reserved.
//

#import "LifeRhythmDetailVC.h"
#import "LifeRhythmDetailChartVC.h"

@interface LifeRhythmDetailVC ()<LGFClandarDelegate,LifeRhythmDetailChartVCDelegate>
{
    int ScrollPage;
    NSDate *ColorSelectDate;
}
@property (weak, nonatomic) IBOutlet UILabel *FloorTitle;
@property (weak, nonatomic) IBOutlet UILabel *RoomTitle;
@property (weak, nonatomic) IBOutlet UILabel *UserNameTitle;
@property (weak, nonatomic) IBOutlet UILabel *TimeFrameTitle;
@property (weak, nonatomic) IBOutlet NITCollectionView *PageCV;
@property (weak, nonatomic) IBOutlet ColorSelectionCV *ColorSelectionCV;
@property (weak, nonatomic) IBOutlet UIView *DarkColorView;
@property (weak, nonatomic) IBOutlet UIView *LightColorView;
@property (strong, nonatomic) NSMutableArray *controlarr;
@property (nonatomic, strong) NSDate *SelectDate;
@end

@implementation LifeRhythmDetailVC

static NSString * const reuseIdentifier = @"PageDetailCVCell";

-(NSMutableArray *)controlarr{
    
    if (!_controlarr) {
        _controlarr = [NSMutableArray array];
        for (int i = 0; i< TotalDay; i++) {
            LifeRhythmDetailChartVC *lrdcvc = [MainSB instantiateViewControllerWithIdentifier:@"LifeRhythmDetailChartVCSB"];
            lrdcvc.DayStr = [NSDate SotherDay:_SelectDate symbols:LGFMinus dayNum:(TotalDay-1) - i];
            lrdcvc.delegate = self;
            [self addChildViewController:lrdcvc];
            [_controlarr addObject:lrdcvc];
        }
    }
    return _controlarr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_PageCV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    [_ColorSelectionCV layoutIfNeeded];
    
    NSMutableDictionary *SystemUserDict = [NSMutableDictionary dictionaryWithContentsOfFile:SYSTEM_USER_DICT];
    [SystemUserDict removeObjectForKey:@"actionremove"];
    [SystemUserDict writeToFile:SYSTEM_USER_DICT atomically:NO];
    
    _DarkColorView.backgroundColor = [UIColor colorWithHex:SystemUserDict[@"darkcolor"]];
    _LightColorView.backgroundColor = [UIColor colorWithHex:SystemUserDict[@"lightcolor"]];
    _FloorTitle.text = SystemUserDict[@"displayname"];
    _RoomTitle.text = SystemUserDict[@"roomname"];
    _UserNameTitle.text = SystemUserDict[@"username0"];
    
    [NITNotificationCenter addObserver:self selector:@selector(ReloadColor:) name:@"SystemReloadColor" object:nil];
    ScrollPage = TotalDay-1;
    [self ReloadNewData:[NSDate needDateStrStatus:NotHaveType datestr:_SelectDay] ColorType:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
/**
 日期检索
 */
- (IBAction)DateRetrieval:(id)sender {

    [[LGFClandar Clandar] ShowInView:self Date:_TimeFrameTitle.text];
}

-(void)ReloadColor:(id)sender{
    
    if (ColorSelectDate) {
        [self ReloadNewData:ColorSelectDate ColorType:YES];
    }else{
        [self ReloadNewData:[NSDate needDateStrStatus:NotHaveType datestr:_SelectDay] ColorType:YES];
    }
}
-(void)MJGetNewData{
    
    [self ReloadNewData:[NSDate date] ColorType:NO];
}

-(void)SelectDate:(NSDate *)date{
    
    ColorSelectDate = date;
    [self ReloadNewData:date ColorType:NO];
}

-(void)ReloadNewData:(NSDate*)date ColorType:(BOOL)ColorType{
    
    self.controlarr = nil;
    _SelectDate = date;
    if (ColorType) {
//        NSString *str = [NSString stringWithFormat:@"%@(%@)",[NSDate needDateStatus:JapanHMDType date:[NSDate SotherDayDate:_SelectDate symbols:LGFMinus dayNum:(TotalDay-1)-ScrollPage]], self.Weekdate];
        _TimeFrameTitle.text = [NSDate needDateStatus:JapanHMDType date:[NSDate SotherDayDate:_SelectDate symbols:LGFMinus dayNum:(TotalDay-1)-ScrollPage]];
    } else {
//        NSString *str = [NSString stringWithFormat:@"%@(%@)",[NSDate needDateStatus:JapanHMDType date:_SelectDate],_Weekdate];
        _TimeFrameTitle.text = [NSDate needDateStatus:JapanHMDType date:_SelectDate];
    }
    
    [_PageCV reloadData];
    [_PageCV scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:ColorType ? ScrollPage : TotalDay-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

#pragma mark - UICollectionViewDataSource And Delegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return self.controlarr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIView *view = [self.controlarr[indexPath.item]view];
    view.size = cell.size;
    [cell.contentView addSubview:view];
    return cell;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    ScrollPage = (int)(scrollView.contentOffset.x/scrollView.frame.size.width+0.5)%(TotalDay);
    _TimeFrameTitle.text = [NSDate needDateStatus:JapanHMDType date:[NSDate SotherDayDate:_SelectDate symbols:LGFMinus dayNum:(TotalDay-1)-ScrollPage]];
}

- (void)dealloc{
    
    [NITNotificationCenter removeObserver:self];
}
@end