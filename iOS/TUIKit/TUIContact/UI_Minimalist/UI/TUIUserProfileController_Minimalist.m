//
//  TUIProfileController.m
//  TUIKit
//
//  Created by annidyfeng on 2019/3/11.
//  Copyright © 2019 kennethmiao. All rights reserved.
//

#import "TUIUserProfileController_Minimalist.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TUICore/TUIThemeManager.h>
#import "TUICommonContactProfileCardCell_Minimalist.h"
#import "TUICommonContactTextCell.h"
#import "TUICommonPendencyCellData.h"
#import "TUIContactAcceptRejectCell_Minimalist.h"
#import "TUIContactAvatarViewController_Minimalist.h"
#import "TUIContactButtonCell_Minimalist.h"
#import "TUIContactConversationCellData.h"
#import "TUIFriendRequestViewController_Minimalist.h"
#import "TUIContactConfig.h"

@interface TUIUserProfileController_Minimalist () <TUIContactProfileCardDelegate_Minimalist>
@property NSMutableArray<NSArray *> *dataList;
@property(nonatomic, strong) TUINaviBarIndicatorView *titleView;
@end

@implementation TUIUserProfileController_Minimalist

- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];

    return self;
}

- (void)willMoveToParentViewController:(nullable UIViewController *)parent {
    [super willMoveToParentViewController:parent];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:TIMCommonLocalizableString(ProfileDetails)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";
    self.clearsSelectionOnViewWillAppear = YES;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    [self.tableView registerClass:[TUICommonContactTextCell class] forCellReuseIdentifier:@"TextCell"];
    [self.tableView registerClass:[TUICommonContactProfileCardCell_Minimalist class] forCellReuseIdentifier:@"CardCell"];
    [self.tableView registerClass:[TUIContactButtonCell_Minimalist class] forCellReuseIdentifier:@"ButtonCell"];
    [self.tableView registerClass:[TUIContactAcceptRejectCell_Minimalist class] forCellReuseIdentifier:@"ButtonAcceptCell"];

    self.tableView.delaysContentTouches = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];

    [self loadData];
}

- (void)loadData {
    NSMutableArray *list = @[].mutableCopy;
    [list addObject:({
              NSMutableArray *inlist = @[].mutableCopy;
              [inlist addObject:({
                          TUICommonContactProfileCardCellData_Minimalist *personal = [[TUICommonContactProfileCardCellData_Minimalist alloc] init];
                          personal.identifier = self.userFullInfo.userID;
                          personal.avatarImage = DefaultAvatarImage;
                          personal.avatarUrl = [NSURL URLWithString:self.userFullInfo.faceURL];
                          personal.name = [self.userFullInfo showName];
                          personal.genderString = [self.userFullInfo showGender];
                          personal.signature = [self.userFullInfo showSignature];
                          personal.reuseId = @"CardCell";
                          personal;
                      })];
              inlist;
          })];

    if (self.pendency || self.groupPendency) {
        [list addObject:({
                  NSMutableArray *inlist = @[].mutableCopy;
                  [inlist addObject:({
                              TUICommonContactTextCellData *data = TUICommonContactTextCellData.new;
                              data.key = TIMCommonLocalizableString(FriendAddVerificationMessage);
                              data.keyColor = [UIColor colorWithRed:136 / 255.0 green:136 / 255.0 blue:136 / 255.0 alpha:1 / 1.0];
                              data.valueColor = [UIColor colorWithRed:68 / 255.0 green:68 / 255.0 blue:68 / 255.0 alpha:1 / 1.0];
                              if (self.pendency) {
                                  data.value = self.pendency.addWording;
                              } else if (self.groupPendency) {
                                  data.value = self.groupPendency.requestMsg;
                              }
                              data.reuseId = @"TextCell";
                              data.enableMultiLineValue = YES;
                              data;
                          })];
                  inlist;
              })];
    }

    self.dataList = list;

    if (self.actionType == PCA_ADD_FRIEND_MINI) {
        [[V2TIMManager sharedInstance] checkFriend:@[ self.userFullInfo.userID ]
                                         checkType:V2TIM_FRIEND_TYPE_BOTH
                                              succ:^(NSArray<V2TIMFriendCheckResult *> *resultList) {
            if (resultList.count == 0) {
              return;
            }
            V2TIMFriendCheckResult *result = resultList.firstObject;
            if (result.relationType == V2TIM_FRIEND_RELATION_TYPE_IN_MY_FRIEND_LIST || result.relationType == V2TIM_FRIEND_RELATION_TYPE_BOTH_WAY) {
              return;
            }
            if (![[TUIContactConfig sharedConfig] isItemHiddenInContactConfig:TUIContactConfigItem_AddFriend]) {
                [self.dataList addObject:({
                    NSMutableArray *inlist = @[].mutableCopy;
                    [inlist addObject:({
                        TUIContactButtonCellData_Minimalist *data = TUIContactButtonCellData_Minimalist.new;
                        data.title = TIMCommonLocalizableString(FriendAddTitle);
                        data.style = ButtonBule;
                        data.textColor = [UIColor tui_colorWithHex:@"147AFF"];
                        data.cbuttonSelector = @selector(onAddFriend);
                        data.reuseId = @"ButtonCell";
                        data.hideSeparatorLine = YES;
                        data;
                    })];
                    inlist;
                })];
            }
            [self.tableView reloadData];
        }
                                              fail:^(int code, NSString *desc) {
            NSLog(@"");
        }];
    }

    if (self.actionType == PCA_PENDENDY_CONFIRM_MINI) {
        [self.dataList addObject:({
                           NSMutableArray *inlist = @[].mutableCopy;
                           [inlist addObject:({
                                       TUIContactAcceptRejectCellData_Minimalist *data = TUIContactAcceptRejectCellData_Minimalist.new;
                                       __weak typeof(data) weakData = data;
                                       data.agreeClickCallback = ^{
                                         [self onAgreeFriend];
                                         weakData.isAccepted = YES;
                                         [self.tableView reloadData];
                                       };
                                       data.rejectClickCallback = ^{
                                         [self onRejectFriend];
                                         weakData.isRejected = YES;
                                         [self.tableView reloadData];
                                       };
                                       data.reuseId = @"ButtonAcceptCell";
                                       data;
                                   })];

                           inlist;
                       })];
    }

    if (self.actionType == PCA_GROUP_CONFIRM_MINI) {
        [self.dataList addObject:({
                           NSMutableArray *inlist = @[].mutableCopy;
                           [inlist addObject:({
                                       TUIContactButtonCellData_Minimalist *data = TUIContactButtonCellData_Minimalist.new;
                                       data.title = TIMCommonLocalizableString(Accept);
                                       data.style = ButtonWhite;
                                       data.textColor = TIMCommonDynamicColor(@"primary_theme_color", @"#147AFF");
                                       data.cbuttonSelector = @selector(onAgreeGroup);
                                       data.reuseId = @"ButtonCell";
                                       data;
                                   })];
                           [inlist addObject:({
                                       TUIContactButtonCellData_Minimalist *data = TUIContactButtonCellData_Minimalist.new;
                                       data.title = TIMCommonLocalizableString(Decline);
                                       data.style = ButtonRedText;
                                       data.cbuttonSelector = @selector(onRejectGroup);
                                       data.reuseId = @"ButtonCell";
                                       data;
                                   })];
                           inlist;
                       })];
    }

    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUICommonCellData *data = self.dataList[indexPath.section][indexPath.row];
    TUICommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data.reuseId forIndexPath:indexPath];
    if ([cell isKindOfClass:[TUICommonContactProfileCardCell_Minimalist class]]) {
        TUICommonContactProfileCardCell_Minimalist *cardCell = (TUICommonContactProfileCardCell_Minimalist *)cell;
        cardCell.delegate = self;
        cell = cardCell;
    }
    [cell fillWithData:data];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TUICommonCellData *data = self.dataList[indexPath.section][indexPath.row];
    return [data heightOfWidth:Screen_Width];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return section == 0 ? 0 : 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)onSendMessage {
    //    TUIChatConversationModel *data = [[TUIChatConversationModel alloc] init];
    //    data.conversationID = [NSString stringWithFormat:@"c2c_%@",self.userFullInfo.userID];
    //    data.userID = self.userFullInfo.userID;
    //    data.title = [self.userFullInfo showName];
    //    ChatViewController *chat = [[ChatViewController alloc] init];
    //    chat.conversationData = data;
    //    [self.navigationController pushViewController:chat animated:YES];
}

- (void)onAddFriend {
    TUIFriendRequestViewController_Minimalist *vc = [TUIFriendRequestViewController_Minimalist new];
    vc.profile = self.userFullInfo;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onAgreeFriend {
    __weak typeof(self)weakSelf = self;
    [self.pendency agreeWithSuccess:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(int code, NSString * _Nonnull msg) {
        
    }];
}

- (void)onRejectFriend {
    __weak typeof(self)weakSelf = self;
    [self.pendency rejectWithSuccess:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(int code, NSString * _Nonnull msg) {
        
    }];
}

- (void)onAgreeGroup {
    __weak typeof(self)weakSelf = self;
    [self.groupPendency agreeWithSuccess:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(int code, NSString * _Nonnull msg) {
        
    }];;
}

- (void)onRejectGroup {
    __weak typeof(self)weakSelf = self;
    [self.groupPendency rejectWithSuccess:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(int code, NSString * _Nonnull msg) {
        
    }];
}

- (UIView *)toastView {
    return [UIApplication sharedApplication].keyWindow;
}

- (void)didSelectAvatar {
    TUIContactAvatarViewController_Minimalist *image = [[TUIContactAvatarViewController_Minimalist alloc] init];
    image.avatarData.avatarUrl = [NSURL URLWithString:self.userFullInfo.faceURL];
    NSArray *list = self.dataList;
    NSLog(@"%@", list);

    [self.navigationController pushViewController:image animated:YES];
}

- (void)didTapOnAvatar:(TUICommonContactProfileCardCell_Minimalist *)cell {
    TUIContactAvatarViewController_Minimalist *image = [[TUIContactAvatarViewController_Minimalist alloc] init];
    image.avatarData = cell.cardData;
    [self.navigationController pushViewController:image animated:YES];
}

@end
