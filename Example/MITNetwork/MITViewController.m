//
//  MITViewController.m
//  MITNetwork
//
//  Created by mcmengchen on 03/07/2017.
//  Copyright (c) 2017 mcmengchen. All rights reserved.
//

#import "MITViewController.h"
#import "MITNetwork.h"
#import "WeiboSDK.h"
#import <UIKit/UIKit.h>
#define kRedirectURI    @"http://www.sina.com"

@interface MITViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
{
    CFAbsoluteTime _startTime;
}
/**  <#Description#>*/
@property(nonatomic, strong)MITNetworkRequest * reuqest;
@property(nonatomic,copy) NSString *weiboToken;
/**  <#Description#>*/
@property(nonatomic, strong)UITableView * tableView;

@end

@implementation MITViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _startTime = CFAbsoluteTimeGetCurrent();
    self.title = @"MITNetwork演示Demo";
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    if (![self isLogin]) {
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"重要提醒" message:@"需要登录微博" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登录", nil];
        [alter show];
    }else{
        
        _weiboToken  = [[NSUserDefaults standardUserDefaults] objectForKey:@"RBAccessToken"];
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    if (indexPath.row==0) {
        cell.textLabel.text = @"GET请求";
    }else if (indexPath.row ==1){
        cell.textLabel.text = @"POST请求";
    }else if (indexPath.row ==2){
        cell.textLabel.text = @"upload请求";
    }else if (indexPath.row ==3){
        cell.textLabel.text = @"队列请求";
    }else if (indexPath.row ==4){
        cell.textLabel.text = @"下载请求";
    }
    return cell;
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row == 0) {
        [self GETRequest];
    }if (indexPath.row == 1) {
        [self POSTRequest];
    }if (indexPath.row == 2) {
        [self UPLOADRequest];
    }else if (indexPath.row ==4){
        [self DOWNLOADRequest];
    }
}
-(void)GETRequest{
    [MITNetworkEngine sendRequest:^(MITNetworkRequest * _Nullable request) {
        request.api = @"/statuses/public_timeline.json";
        request.method = MITNET_REQUEST_METHOD_GET;
        request.parameters = @{@"access_token":[NSString stringWithFormat:@"%@",_weiboToken]};
        request.cachePolicy = MITNET_REQUEST_CACHE_REFRESH;

    } onSuccess:^(id  _Nullable responseObject) {
//        NSLog(@"%@",responseObject);
    } onFailure:^(NSError * _Nullable error) {
//         NSLog(@"%@",error);

    }];
    
    
}
-(void)POSTRequest{
    [MITNetworkEngine sendRequest:^(MITNetworkRequest * _Nullable request) {
        request.api = @"/statuses/public_timeline.json";
        request.method = MITNET_REQUEST_METHOD_GET;
        request.parameters = @{@"access_token":[NSString stringWithFormat:@"%@",_weiboToken]};
//        request.cachePolicy = MITNET_REQUEST_CACHE_ONLY;
    } onSuccess:^(id  _Nullable responseObject) {
//        NSLog(@"%@",responseObject);
    } onFailure:^(NSError * _Nullable error) {
//        NSLog(@"%@",error);
    }];
    
    
    
}
-(void)UPLOADRequest{
    [MITNetworkEngine sendRequest:^(MITNetworkRequest * _Nullable request) {
        request.api = @"/statuses/upload.json";
        request.parameters = @{@"access_token":[NSString stringWithFormat:@"%@",_weiboToken],@"status":@"测试图片微博"};
        NSString *photoPath  = [[NSBundle mainBundle] pathForResource:@"180" ofType:@"png"];
        [request addFormDataWithName:@"pic" fileURL:[NSURL fileURLWithPath:photoPath]];
        request.type = MITNET_TYPE_UPLOAD;
        request.method = MITNET_REQUEST_METHOD_POST;
    } onSuccess:^(id  _Nullable responseObject) {
//        NSLog(@"%@",responseObject);
    } onFailure:^(NSError * _Nullable error) {
//        NSLog(@"%@",error);
    }];
    
    
}
- (void)DOWNLOADRequest{
    NSString * url = @"http://media.roo.bo/voices/moment/1011000000200B87/2016-12-22/20161222_feb7883c4a9a0df157154ae89efd50e8.mp4";
    self.reuqest = [MITNetworkEngine sendRequest:^(MITNetworkRequest * _Nullable request) {
        request.type = MITNET_TYPE_DOWNLOAD;
        request.url = url;
    }onProgress:^(NSProgress * _Nullable progress) {
        NSLog(@"progress = %f",progress.fractionCompleted);
    }onSuccess:^(id  _Nullable responseObject) {
//        NSLog(@"---------%f",CFAbsoluteTimeGetCurrent() - _startTime);
    } onFailure:^(NSError * _Nullable error) {
//        NSLog(@"%@",error);
    }];
}




static int num = 0;

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (num%2 ==0) {
        [MITNetworkEngine cancelRequest:self.reuqest Block:^(BOOL isSucced,MITNET_REQUEST_STEP step) {
            NSLog(@"step = %ld",step);
            if (isSucced) {
                NSLog(@"取消成功");
            }else{
                NSLog(@"取消失败");
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.reuqest = nil;
            });

        }];
        [MITNetworkEngine suspend:self.reuqest];
        

        
        
    } else {

        
        
    
        
    }
    num++;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.cancelButtonIndex!= buttonIndex) {
        [self loginFromWeibo];
    }
}
- (void)loginFromWeibo
{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kRedirectURI;
    request.scope = @"all";
    [WeiboSDK sendRequest:request];
}
-(BOOL)isLogin{
    NSUserDefaults *user  = [NSUserDefaults standardUserDefaults];
    NSString *tokenStr  = [user stringForKey:@"RBAccessToken"];
    NSString *userStr  = [user stringForKey:@"RBuserID"];
    if (tokenStr&&userStr) {
        NSDate *expirationDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"RBExpirationDate"];
        if ([[NSDate date] compare:expirationDate]==NSOrderedAscending) {
            return YES;
        }
        return NO;
    }else{
        return NO;
    }
    
}

@end
