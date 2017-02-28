//
//  MainVC.m
//  DashBoard
//
//  Created by totyu3 on 17/1/17.
//  Copyright © 2017年 NIT. All rights reserved.
//

#import "MainVC.h"
#import "AlertBar.h"
#import "UserListCVCell.h"
#import "UIImageView+WebCache.h"

@interface CollectionCellWhite : UICollectionViewCell
@end
@implementation CollectionCellWhite
@end

@interface MainVC ()
{
    NSInteger pageCount;
}
@property (weak, nonatomic) IBOutlet UIPageControl *UserPC;
@property (weak, nonatomic) IBOutlet AlertBar *AlertBarView;
@property (weak, nonatomic) IBOutlet UILabel *NowTime;
@property (weak, nonatomic) IBOutlet UILabel *BuildName;
@property (weak, nonatomic) IBOutlet UICollectionView *UserListCV;
@property (weak, nonatomic) IBOutlet UILabel *NoticeNewDataTap;
@property (nonatomic, strong) NSArray *UserLisrArray;
@property (nonatomic, strong) NSArray *BuildingArray;
@end

@implementation MainVC

static NSString * const reuseIdentifier = @"MainVCell";

-(NSArray *)UserLisrArray{
    if (!_UserLisrArray) {
        _UserLisrArray = [NSArray array];
    }
    return _UserLisrArray;
}

-(NSArray *)BuildingArray{
    if (!_BuildingArray) {
        _BuildingArray = [NSArray array];
    }
    return _BuildingArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadNewData];
    
    NSMutableDictionary *SystemUserDict = [NSMutableDictionary dictionaryWithContentsOfFile:SYSTEM_USER_DICT];
    [SystemUserDict setValue:@"1" forKey:@"logintype"];
    [SystemUserDict writeToFile:SYSTEM_USER_DICT atomically:NO];

    [self CellHorizontalAlignment];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 发送请求获取新数据
 */
- (void)loadNewData{
    
    [MBProgressHUD showMessage:@"後ほど..." toView:self.view];
    [[SealAFNetworking NIT] PostWithUrl:ZwgetbuildinginfoType parameters:nil mjheader:nil superview:nil success:^(id success){
        NSDictionary *tmpDic = success;
        if ([tmpDic[@"code"] isEqualToString:@"200"]) {
            
            self.BuildingArray = tmpDic[@"buildingInfo"];
            NSDictionary *buildingdict = self.BuildingArray[2];
            
            NSMutableDictionary *SystemUserDict = [NSMutableDictionary dictionaryWithContentsOfFile:SYSTEM_USER_DICT];
            [SystemUserDict setValue:buildingdict[@"buildingid"] forKey:@"buildingid"];
            [SystemUserDict setValue:buildingdict[@"floorno"] forKey:@"floorno"];
            [SystemUserDict setValue:buildingdict[@"displayname"] forKey:@"displayname"];
            [SystemUserDict writeToFile:SYSTEM_USER_DICT atomically:NO];
            
            _BuildName.text = buildingdict[@"displayname"];
            _NowTime.text = [NSDate needDateStatus:JapanHMSType date:[NSDate date]];
            [self performSelector:@selector(AutoTime) withObject:nil afterDelay:1];
            [self performSelector:@selector(AlertMonitor) withObject:nil afterDelay:2];
            [self LoadCustListData];
            [self LoadAlertData];
        }else{
            
            NSLog(@"errors: %@",tmpDic[@"errors"]);
        }
    }defeats:^(NSError *defeats){
    }];
}
/**
 获取user数据
 */
- (void)LoadCustListData{
    
    NSMutableDictionary *SystemUserDict = [NSMutableDictionary dictionaryWithContentsOfFile:SYSTEM_USER_DICT];
    NSDictionary *parameter = @{@"buildingid":SystemUserDict[@"buildingid"],@"floorno":SystemUserDict[@"floorno"]};
    [[SealAFNetworking NIT] PostWithUrl:ZwgetcustlistType parameters:parameter mjheader:nil superview:self.view success:^(id success){
        NSDictionary *tmpDic = success;
        if ([tmpDic[@"code"] isEqualToString:@"200"]) {
            
            self.UserLisrArray = tmpDic[@"custlist"];
            [[NoDataLabel alloc] Show:@"データがない" SuperView:self.view DataBool:self.UserLisrArray.count];
            [self CellHorizontalAlignment];
        }else{
            NSLog(@"errors: %@",tmpDic[@"errors"]);
            [[NoDataLabel alloc] Show:[tmpDic[@"errors"] firstObject] SuperView:self.view DataBool:0];
        }
    }defeats:^(NSError *defeats){
    }];
}
/**
 获取alert数据
 */
- (void)LoadAlertData{
    
    NSMutableDictionary *SystemUserDict = [NSMutableDictionary dictionaryWithContentsOfFile:SYSTEM_USER_DICT];
    NSDictionary *parameter = @{@"buildingid":SystemUserDict[@"buildingid"],@"floorno":SystemUserDict[@"floorno"]};
    [[SealAFNetworking NIT] PostWithUrl:ZwgetalertinfoType parameters:parameter mjheader:nil superview:nil success:^(id success){
        NSDictionary *tmpDic = success;
        if ([tmpDic[@"code"] isEqualToString:@"200"]) {
            
            NSArray *alertarray = [NSArray arrayWithArray:tmpDic[@"alertinfo"]];
            _AlertBarView.AlertArray = alertarray;
            NSDictionary *alertdict = alertarray[alertarray.count-1];
            UIAlertController *testalert = [UIAlertController alertControllerWithTitle:alertdict[@"registdate"] message:[NSString stringWithFormat:@"%@ %@\nアラート通知",alertdict[@"roomname"],alertdict[@"username0"]] preferredStyle:UIAlertControllerStyleAlert];
            [testalert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            }]];
            [MasterKeyWindow.rootViewController presentViewController:testalert animated:YES completion:nil];
            
        }else{
            NSLog(@"errors: %@",tmpDic[@"errors"]);
        }
    }defeats:^(NSError *defeats){
    }];
}
- (void)LoadNoticeCount{
    
    NSMutableDictionary *SystemUserDict = [NSMutableDictionary dictionaryWithContentsOfFile:SYSTEM_USER_DICT];
    NSLog(@"%@",SystemUserDict);
    NSDictionary *parameter = @{@"registdate":SystemUserDict[@"newnoticetime"]};
    [[SealAFNetworking NIT] PostWithUrl:ZwgetvznoticecountType parameters:parameter mjheader:nil superview:self.view success:^(id success){
        NSDictionary *tmpDic = success;
        if ([tmpDic[@"code"] isEqualToString:@"200"]) {
            if ([tmpDic[@"vznoticecount"] intValue]==0) {
                _NoticeNewDataTap.alpha = 0.0;
            }else{
                _NoticeNewDataTap.alpha = 1.0;
                if ([tmpDic[@"vznoticecount"] intValue]>99) {
                    _NoticeNewDataTap.text = @"99+";
                }else{
                    _NoticeNewDataTap.text = [NSString stringWithFormat:@"%@",tmpDic[@"vznoticecount"]];
                }
            }
        }else{
            NSLog(@"errors: %@",tmpDic[@"errors"]);
        }
    }defeats:^(NSError *defeats){
    }];
}
/**
 登出
 */
- (IBAction)Logout:(id)sender {
    
    NSMutableDictionary *SystemUserDict = [NSMutableDictionary dictionaryWithContentsOfFile:SYSTEM_USER_DICT];
    [SystemUserDict setValue:@"0" forKey:@"logintype"];
    [SystemUserDict writeToFile:SYSTEM_USER_DICT atomically:NO];

    MasterKeyWindow.rootViewController = [MainSB instantiateViewControllerWithIdentifier:@"LoginView"];
}
/**
 获取新数据
 */
- (IBAction)LoadNewData:(id)sender {
    [self loadNewData];
}
/**
 警报一览
 */
- (IBAction)AllAlert:(id)sender {

//    UIAlertController *testalert = [UIAlertController alertControllerWithTitle:@"TestAlert" message:@"AlertBarView被点击了" preferredStyle:UIAlertControllerStyleAlert];
//    [testalert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
//        
//    }]];
//    [MasterKeyWindow.rootViewController presentViewController:testalert animated:YES completion:nil];
    
}
/**
 可视化设定
 */
- (IBAction)VisualSetting:(id)sender {
    [self performSegueWithIdentifier:@"DBVisualSettingPush" sender:self];
}
/**
 通知一览
 */
- (IBAction)Notice:(id)sender {
    [self performSegueWithIdentifier:@"DBNoticePush" sender:self];
    _NoticeNewDataTap.alpha = 0.0;
}
/**
 帮助
 */
- (IBAction)Help:(id)sender {
    [self performSegueWithIdentifier:@"DBHelpPush" sender:self];
}
/**
 生活リズム
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"AllChartVCPush" sender:self];
}
/**
 **************** segue跳转 *****************
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"AllChartVCPush"]){
        NSIndexPath *indexPath = _UserListCV.indexPathsForSelectedItems.lastObject;
        NSDictionary *DataDict = self.UserLisrArray[indexPath.item];
        NSMutableDictionary *SystemUserDict = [NSMutableDictionary dictionaryWithContentsOfFile:SYSTEM_USER_DICT];
        [SystemUserDict setValue:DataDict[@"userid0"] forKey:@"userid0"];
        [SystemUserDict setValue:DataDict[@"roomid"] forKey:@"roomid"];
        [SystemUserDict setValue:DataDict[@"roomname"] forKey:@"roomname"];
        [SystemUserDict setValue:DataDict[@"username0"] forKey:@"username0"];
        [SystemUserDict writeToFile:SYSTEM_USER_DICT atomically:NO];
    }
}
/**
 自动时间
 */
- (void)AutoTime{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(AutoTime) object:nil];
    _NowTime.text = [NSDate needDateStatus:JapanHMSType date:[NSDate date]];
    [self performSelector:@selector(AutoTime) withObject:nil afterDelay:1];
}
/**
 Alert监听
 */
- (void)AlertMonitor{
   
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(AlertMonitor) object:nil];

    [self LoadCustListData];
    [self LoadAlertData];
    [self LoadNoticeCount];
    
    [self performSelector:@selector(AlertMonitor) withObject:nil afterDelay:60];
}
#pragma mark - UICollectionView Delegate and DataSource

/**
 Cell横向排列
 */
-(void)CellHorizontalAlignment{
    pageCount = self.UserLisrArray.count;
    while (pageCount % 6 != 0) {
        ++pageCount;
    }
    _UserPC.numberOfPages = pageCount/6;
    [_UserListCV registerClass:[CollectionCellWhite class]
    forCellWithReuseIdentifier:@"CellWhite"];
    [_UserListCV reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return pageCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.item >= self.UserLisrArray.count) {
        CollectionCellWhite *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellWhite"
                                                         forIndexPath:indexPath];
        cell.backgroundColor = [UIColor whiteColor];
        cell.userInteractionEnabled = NO;
        return cell;
    } else {
        UserListCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        NSDictionary *DataDict = self.UserLisrArray[indexPath.item];
        
        [cell.UserImage sd_setImageWithURL:[NSURL URLWithString:DataDict[@"picpath"]] placeholderImage:nil];
        cell.RoomName.text = DataDict[@"roomname"];
        cell.UserName.text = DataDict[@"username0"];
        cell.UserSex.text = DataDict[@"usersex"];
        cell.UserAge.text = [NSString stringWithFormat:@"%@",DataDict[@"userold"]];
        cell.temperature.text = [NSString stringWithFormat:@"%@%@",DataDict[@"tvalue"],DataDict[@"tunit"]];
        
        NSString *str = DataDict[@"bd"];
        
        if ([str isEqualToString:@"明"]) {
            cell.luminance.text = @"明るい";
        } else {
            cell.luminance.text = @"暗い";
        }
        
        if ([DataDict[@"resultname"]isEqualToString:@"異常検知あり"]) {
            cell.alerttype = @"1";
        }else{
            cell.alerttype = @"0";
        }
        return cell;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    int page = scrollView.contentOffset.x / scrollView.width;
    _UserPC.currentPage = page;
}

@end