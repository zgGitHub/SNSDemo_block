//
//  MyTableViewController.m
//  SNSDemo
//
//  Created by LZXuan on 15-7-13.
//  Copyright (c) 2015年 轩哥. All rights reserved.
//

#import "MyTableViewController.h"
//专门下载数据的类
#import "LZXHttpRequest.h"
#import "UserCell.h"
#import "UserModel.h"


#define kPath @"http://10.0.8.8/sns/my/user_list.php?page=%ld&number=%ld"

@interface MyTableViewController ()
{
    //下载类
    LZXHttpRequest *_httpRequest;
    //数据源数组
    NSMutableArray *_dataArr;
}
@property (nonatomic,strong) NSMutableArray *dataArr;
@end

@implementation MyTableViewController
- (void)dealloc {
    self.dataArr = nil;
    [super dealloc];
}
/*
 1.MVC设计
 2.先设计 model 和 view 对应的cell
 3.设计 controller 
 4.下载数据 解析数据 展示数据
 */


- (void)viewDidLoad {
    [super viewDidLoad];
    //导航条编程 不透明 这时滚动视图的内容 不会再向下自动偏移 64
    self.navigationController.navigationBar.translucent = NO;
    
    [self createHttpRequest];
    //下载第一页数据
    [self downloadDataPage:1 count:20];
}
#pragma mark - 下载类
- (void)createHttpRequest{
    self.dataArr = [[[NSMutableArray alloc] init] autorelease];
    //下载对象
    _httpRequest = [[LZXHttpRequest alloc] init];
}
#pragma mark - 按页下载
- (void)downloadDataPage:(NSInteger)page count:(NSInteger)count {
    //拼接url
    NSString *url = [NSString stringWithFormat:kPath,page,count];
    
    //避免 循环引用两个强引用 导致死锁，最终会内存泄露
    //MRC 用__block ARC用__weak
    
    __block MyTableViewController * mySelf = self;
    //发送 get 请求 下载数据
    [_httpRequest downloadDataWithUrl:url success:^(NSMutableData *download) {
        //下载成功的block
        //解析数据
        [mySelf downloadSuccessWithData:download];
        
    } failed:^(NSError *error) {
        [mySelf downloadFailWithError:error];
    }];
}

- (void)downloadSuccessWithData:(NSMutableData *)downloadData {
    //
    NSLog(@"下载完成");
    //解析数据 json 格式
    //json 解析 最外层是字典
    if (downloadData) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:downloadData options:NSJSONReadingMutableContainers error:nil];
        NSArray *usersArr = dict[@"users"];
        //遍历数组
        for (NSDictionary *userDict in usersArr) {
            //把数据存在model
            UserModel *model = [[UserModel alloc] init];
            model.uid = userDict[@"uid"];
            model.username = userDict[@"username"];
            //图片路径只有一半 要拼接完整
            model.headimage = [@"http://10.0.8.8/sns" stringByAppendingString:userDict[@"headimage"]];
            //放入数据源数组
            [self.dataArr addObject:model];
            [model release];
        }
        //数据源变了 那么我们需要刷新下 表格
        [self.tableView reloadData];
        //刷新表格 TableView协议的方法 会再走一遍
    }
}
- (void)downloadFailWithError:(NSError *)error {
    NSLog(@"下载失败");
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
//分区 / 组 / 段
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.dataArr.count;
}
//获取cell 填充cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"UserCell";//要和xib 中的复用标识符一样
    //从复用队列获取cell
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        //没有可以复用的那么创建
        cell = [[[NSBundle mainBundle] loadNibNamed:@"UserCell" owner:self options:nil] lastObject];
    }
    //填充cell
    //获取model
    UserModel *model = self.dataArr[indexPath.row];
    [cell showDataWithModel:model];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}


/*
 {
 "totalcount": "127408",
 "count": 10,
 "users": [
 {
 "uid": "82781",
 "username": "Erfangdong",
 "groupid": "7",
 "credit": "1634",
 "experience": "1624",
 "viewnum": "44",
 "friendnum": "27",
 "lastactivity": 0,
 "headimage": "/my/headimage.php?uid=82781",
 "realname": ""
 },
 {
 "uid": "110698",
 "username": "14180000",
 "groupid": "7",
 "credit": "1119",
 "experience": "1159",
 "viewnum": "36",
 "friendnum": "7",
 "lastactivity": 0,
 "headimage": "/my/headimage.php?uid=110698",
 "realname": "我是大飞哥"
 },
 */

@end
