//
//  RRSettingPresenter.m
//  rework-reader
//
//  Created by 张超 on 2019/1/28.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRSettingPresenter.h"
#import "RRModelItem.h"
#import "RPSettingInputer.h"
@import SafariServices;
#import "RRFeedLoader.h"
@import ui_base;
#import "MVPViewLoadProtocol.h"
#import "RRGetWebIconOperation.h"
@import UserNotifications;
#import "OPMLDocument.h"
@import Classy;

@interface RRSettingPresenter () <UIDocumentPickerDelegate,MVPPresenterProtocol_private>
{
    
}
@property (nonatomic, strong) RRModelItem* item;
@property (nonatomic, strong) RPSettingInputer* inputer;
@property (nonatomic, assign) BOOL feeding;
@property (nonatomic, weak) RRSetting* notiSetting;
@property (nonatomic, weak) RRSetting* badgeSetting;
@property (nonatomic, weak) FMFeedParserOperation* currentOperation;
@property (nonatomic, strong) NSString* settingFileName;
@end

@implementation RRSettingPresenter

- (RPSettingInputer *)inputer
{
    if (!_inputer) {
        _inputer = [[RPSettingInputer alloc] init];
    }
    return _inputer;
}

- (RRModelItem *)item
{
    if (!_item) {
        NSError *error;
        NSError *error2;
        NSURL* url = [[NSBundle mainBundle] URLForResource:self.settingFileName withExtension:@"json"];
        NSString* json = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            DDLogError(@"%@",error);
        }
        _item = [RRModelItem fromJSON:json encoding:NSUTF8StringEncoding error:&error2];
        if (error2) {
            DDLogError(@"%@",error2);
        }
    }
    return _item;
}

- (void)mvp_initFromModel:(MVPInitModel *)model
{
    NSString* setting = [model.queryProperties valueForKey:@"setting"];
    if (setting) {
        self.settingFileName = setting;
    }
    else {
        self.settingFileName = @"ModelTypeSetting";
    }
    NSString* title = [model.queryProperties valueForKey:@"title"];
    if (title) {
        self.title = title;
    }
    else {
        self.title = @"更多内容";
    }
    __weak typeof(self) weakSelf = self;
    [[self.item setting] enumerateObjectsUsingBlock:^(RRSetting * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj switchkey] isEqualToString:@"kBackgroundFetchNoti"]) {
            weakSelf.notiSetting = obj;
        }
        else if([[obj switchkey] isEqualToString:@"kBackgroundFetchNotiBadge"])
        {
            weakSelf.badgeSetting = obj;
        }
        if ([obj switchkey]) {
            obj.switchValue = [[NSUserDefaults standardUserDefaults] valueForKey:obj.switchkey];
        }
        if ([[obj title] isEqualToString:@"版本"]) {
            [obj setValue:[NSString stringWithFormat:@"%@ (build %@)",[UIApplication sharedApplication].version(),[UIApplication sharedApplication].buildVersion()]];
        }
        [weakSelf.inputer mvp_addModel:obj];
    }];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
       
    }
    return self;
}


- (id)mvp_inputerWithOutput:(id<MVPOutputProtocol>)output
{
    return self.inputer;
}

- (void)mvp_action_selectItemAtIndexPath:(NSIndexPath *)path
{
    RRSetting* s = [self.inputer mvp_modelAtIndexPath:path];
    if (s.select) {
        [self showSelect:s];
    }
    else if (s.action) {
        if ([s.type integerValue] != RRSettingTypeSubSetting) {
            [self mvp_runAction:s.action];
        }
        else {
            [self mvp_runAction:s.action value:s];
        }
    }
}

- (void)showSelect:(RRSetting*)setting
{
    __weak typeof(self) weakSelf = self;
    UIAlertController* alert = UI_Alert();
    [setting.select enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        alert.action(obj, ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
            [weakSelf mvp_runAction:setting.action value:[obj description]];
        });
    }];
    alert.cancel(@"取消", ^(UIAlertAction * _Nonnull action) {
        
    });
    alert.show((id)self.view);
}

- (void)selectFont:(NSString*)select
{
    NSDictionary* fontDict = @{
                                @"苹方细体":@"PingFangSC-Light",
                                @"苹方标准体":@"PingFangSC-Regular",
                                @"思源宋体细体":@"SourceHanSerifCN-Light",
                                };
    NSString* font = fontDict[select];
    if (font) {
        [[NSUserDefaults standardUserDefaults] setObject:font forKey:@"mainFont"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RRCasNeedReload" object:nil userInfo:nil];
    }
}

- (void)selectMainColor:(NSString*)select
{
    NSDictionary* colorDict = @{
                                @"系统":@"#007AFF",
                                @"紫色":@"#BD10E0",
                                @"黑色":@"#303E58",
                                @"橙色":@"#F5A623",
                                @"青色":@"#50E3C2"
                                };
    NSString* color = colorDict[select];
    if (color) {
        [[NSUserDefaults standardUserDefaults] setObject:color forKey:@"mainTintColor"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RRCasNeedReload" object:nil userInfo:nil];
    }
}


- (void)openAbout
{
    id vc = [MVPRouter viewForURL:@"rr://web" withUserInfo:@{@"name":@"什么是RSS.md"}];
    [[self view] mvp_pushViewController:vc];
}

- (void)openWiki
{
    id vc = [MVPRouter viewForURL:@"rr://web" withUserInfo:@{@"name":@"Reader SP说明书.md"}];
    [[self view] mvp_pushViewController:vc];
}

- (void)openVersion
{
    id vc = [MVPRouter viewForURL:@"rr://web" withUserInfo:@{@"name":@"Reader 版本.md"}];
    [[self view] mvp_pushViewController:vc];
}




- (void)feedOffical
{
    if (self.feeding) {
        return;
    }
    self.feeding = YES;
    
    UIViewController* vc = (UIViewController*)[self view];
    dispatch_async(dispatch_get_main_queue(), ^{
        [vc hudWait:@"订阅中"];
    });
    
    id v = [MVPRouter viewForURL:@"rr://feed" withUserInfo:nil];
    id<MVPViewLoadProtocol> tv = nil;
    if ([v conformsToProtocol:@protocol(MVPViewLoadProtocol)]) {
        tv = v;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self view] mvp_pushViewController:v];
    });
    
    __weak typeof(self) weakself = self;
    FMFeedParserOperation* operation = [[RRFeedLoader sharedLoader] loadOfficalWithInfoBlock:^(MWFeedInfo * _Nonnull info) {
        [tv loadData:info];
        
        RRGetWebIconOperation* o = [[RRGetWebIconOperation alloc] init];
        [o setHost:info.url];
        [o setGetIconBlock:^(NSString * _Nonnull icon) {
            [tv loadIcon:icon];
        }];
        [o start];
        
    } itemBlock:^(MWFeedItem * _Nonnull item) {
        //        //NSLog(@"%@",item);
        [tv loadData:item];
        
    } errorBlock:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [vc hudFail:@"订阅失败"];
            if (v) {
                [weakself.view mvp_popViewController:nil];
            }
        });
        weakself.feeding = NO;
    } finishBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [vc hudDismiss];
        });
        [tv loadFinish];
        weakself.feeding = NO;
    }];
    
    self.currentOperation = operation;
}

- (void)cancelAllOperations
{
    if (self.currentOperation) {
        [self.currentOperation cancel];
        self.feeding = NO;
    }
    
    UIViewController* vc = (UIViewController*)[self view];
    dispatch_async(dispatch_get_main_queue(), ^{
        [vc hudDismiss];
    });
}

- (void)changeNoti:(UISwitch*)sender
{
    //    //NSLog(@"%@",sender);
    if (sender.on == NO) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:self.notiSetting.switchkey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    
    
    __weak typeof(self) weakSelf = self;
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
        
        if (!granted) {
            //            //NSLog(@"%@",weakSelf.badgeSetting);
            weakSelf.notiSetting.switchValue = @(NO);
            //            //NSLog(@"%@",self.badgeSetting.switchValue);
            UI_Alert().
            titled(@"请在系统「设置」中开启Reader的通知功能")
            .recommend(@"前往「设置」", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if([[UIApplication sharedApplication] canOpenURL:url]) {
                    NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                        
                    }];
                }
            })
            .cancel(@"取消", ^(UIAlertAction * _Nonnull action) {
                
            })
            .show((id)weakSelf.view);
            
        }
        else {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:weakSelf.notiSetting.switchkey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
    
}

- (void)changeNotiBadge:(UISwitch*)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:self.badgeSetting.switchkey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)openOPML
{
    UIDocumentPickerViewController* dvc = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.xml"] inMode:UIDocumentPickerModeImport];
    [[self view] mvp_presentViewController:dvc animated:YES completion:^{
        
    }];
    dvc.delegate = self;
}

- (void)openUISetting:(RRSetting*)set
{
    id vc = [MVPRouter viewForURL:[NSString stringWithFormat:@"rr://setting?setting=%@&title=%@",set.value,set.title] withUserInfo:nil];
    [[self view] mvp_pushViewController:vc];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls
{
    //    NSLog(@"%@",urls);
    OPMLDocument* d = [[RRFeedLoader sharedLoader] loadOPML:urls.firstObject];
    __weak typeof(self) weakSelf = self;
    [d openWithCompletionHandler:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                id view = [MVPRouter viewForURL:@"rr://import" withUserInfo:@{@"model":d}];
                [weakSelf.view mvp_pushViewController:view];
            }
            else {
                [self.view hudFail:@"导入文件失败"];
            }
        });
    }];
    
}
 

@end
