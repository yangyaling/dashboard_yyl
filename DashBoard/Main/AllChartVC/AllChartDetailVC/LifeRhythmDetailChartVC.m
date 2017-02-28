//
//  LifeRhythmDetailChartVC.m
//  DashBoard
//
//  Created by totyu3 on 17/2/13.
//  Copyright © 2017年 NIT. All rights reserved.
//

#import "LifeRhythmDetailChartVC.h"
#import "NITLabel.h"

@interface LifeRhythmChartDetailCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *DeciceName;
@property (weak, nonatomic) IBOutlet UIView *DeviceDataView;
@end
@implementation LifeRhythmChartDetailCell
@end

@interface LifeRhythmChartDetailReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet NITLabel *OneDayLabel;
@property (weak, nonatomic) IBOutlet UIView *OneDayAllDataChart;
@end
@implementation LifeRhythmChartDetailReusableView
@end

@interface LifeRhythmDetailChartVC ()
@property (weak, nonatomic) IBOutlet NITCollectionView *ChartCV;
@property (nonatomic, strong) NSArray *DataArray;
@property (nonatomic, strong) NSArray *OneDataArray;
@end

@implementation LifeRhythmDetailChartVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self LoadNewData];
    _ChartCV.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(MJHeaderLoadNewData)];
    [NITRefreshInit MJRefreshNormalHeaderInit:(MJRefreshNormalHeader*)_ChartCV.mj_header];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)MJHeaderLoadNewData{
    
    [self.delegate MJGetNewData];
}

-(void)LoadNewData{
    
    NSLog(@"%@",_DayStr);
    NSMutableDictionary *SystemUserDict = [NSMutableDictionary dictionaryWithContentsOfFile:SYSTEM_USER_DICT];
    NSDictionary *parameter = @{@"userid0":SystemUserDict[@"userid0"],@"basedate":_DayStr};
    [MBProgressHUD showMessage:@"後ほど..." toView:self.view];
    [[SealAFNetworking NIT] PostWithUrl:LrinfoType parameters:parameter mjheader:_ChartCV.mj_header superview:self.view success:^(id success){
        NSDictionary *tmpDic = success;
        if ([tmpDic[@"code"] isEqualToString:@"200"]) {
            NSDictionary *Dict = [NSDictionary dictionaryWithDictionary:[tmpDic valueForKey:@"lrlist"]];
            _DataArray = [NSArray arrayWithArray:Dict[[[Dict allKeys] firstObject]][0]];
            _OneDataArray = [NSArray arrayWithArray:Dict[[[Dict allKeys] firstObject]][1]];
            [[NoDataLabel alloc] Show:@"データがない" SuperView:_ChartCV DataBool:_DataArray.count==0&&_OneDataArray.count==0 ? 0 : 1];
            [_ChartCV reloadData];
        }else{
            NSLog(@"errors: %@",tmpDic[@"errors"]);
            [[NoDataLabel alloc] Show:[tmpDic[@"errors"] firstObject] SuperView:_ChartCV DataBool:0];
        }
    }defeats:^(NSError *defeats){
    }];
}

#pragma mark - UICollectionViewDataSource And Delegate

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    NSString *reuseIdentifier = @"LifeRhythmChartDetailReusableView";
    LifeRhythmChartDetailReusableView *view =  [collectionView dequeueReusableSupplementaryViewOfKind :kind withReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    view.OneDayAllDataChart.alpha = 1.0;
    view.OneDayLabel.alpha = 1.0;
    if (_OneDataArray.count>0) {
        [view.OneDayAllDataChart.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        UIView *ChartView = [[LGFBarChart alloc]initWithFrame:view.OneDayAllDataChart.bounds BarData:_OneDataArray BarType:1];
        [view.OneDayAllDataChart addSubview:ChartView];
    }else{
        if (_DataArray.count>0) {
            [[NoDataLabel alloc] Show:@"データがない" SuperView:view.OneDayAllDataChart  DataBool:0];
        }else{
            view.OneDayAllDataChart.alpha = 0.0;
            view.OneDayLabel.alpha = 0.0;
        }
    }
    return view;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _DataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LifeRhythmChartDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LifeRhythmChartDetailCell" forIndexPath:indexPath];
    NSDictionary *DataDict = [NSDictionary dictionaryWithDictionary:_DataArray[indexPath.item]];
    cell.DeciceName.text = DataDict[@"actionname"];
    UIView *ChartView;
    if ([DataDict[@"actionexplain"] isEqualToString:@"4"]) {
        ChartView = [[LGFBarChart alloc]initWithFrame:cell.DeviceDataView.bounds BarData:DataDict BarType:2];
    }else{
        ChartView = [[LGFLineChart alloc]initWithFrame:cell.DeviceDataView.bounds LineDict:DataDict LineType:0];
    }
    [cell.DeviceDataView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [cell.DeviceDataView addSubview:ChartView];
    return cell;
}

@end