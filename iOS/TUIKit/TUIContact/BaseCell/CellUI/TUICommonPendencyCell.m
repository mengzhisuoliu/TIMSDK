//
//  TCommonPendencyCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/7.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUICommonPendencyCell.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUICommonPendencyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.avatarView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
        [self.contentView addSubview:self.avatarView];

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.textColor = TIMCommonDynamicColor(@"form_title_color", @"#000000");

        self.addSourceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.addSourceLabel];
        self.addSourceLabel.textColor = [UIColor d_systemGrayColor];
        self.addSourceLabel.font = [UIFont systemFontOfSize:15];

        self.addWordingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.addWordingLabel];
        self.addWordingLabel.textColor = [UIColor d_systemGrayColor];
        self.addWordingLabel.font = [UIFont systemFontOfSize:15];

        self.agreeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.agreeButton setTitleColor:TIMCommonDynamicColor(@"form_title_color", @"#000000") forState:UIControlStateNormal];
        [self.agreeButton addTarget:self action:@selector(agreeClick) forControlEvents:UIControlEventTouchUpInside];

        self.rejectButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.rejectButton setTitleColor:TIMCommonDynamicColor(@"form_title_color", @"#000000") forState:UIControlStateNormal];
        [self.rejectButton addTarget:self action:@selector(rejectClick) forControlEvents:UIControlEventTouchUpInside];

        UIStackView *stackView = [[UIStackView alloc] init];
        [stackView addSubview:self.agreeButton];
        [stackView addSubview:self.rejectButton];
        stackView.axis = UILayoutConstraintAxisHorizontal;
        stackView.alignment = UIStackViewAlignmentCenter;
        [stackView sizeToFit];
        self.stackView = stackView;
        self.accessoryView = stackView;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillWithData:(TUICommonPendencyCellData *)pendencyData {
    [super fillWithData:pendencyData];

    self.pendencyData = pendencyData;
    self.titleLabel.text = pendencyData.title;
    self.addSourceLabel.text = pendencyData.addSource;
    self.addWordingLabel.text = pendencyData.addWording;
    self.avatarView.image = DefaultAvatarImage;
    if (pendencyData.avatarUrl) {
        [self.avatarView sd_setImageWithURL:pendencyData.avatarUrl];
    }
    if (pendencyData.isAccepted) {
        [self.agreeButton setTitle:TIMCommonLocalizableString(Agreed) forState:UIControlStateNormal];
        self.agreeButton.enabled = NO;
        self.agreeButton.layer.borderColor = [UIColor clearColor].CGColor;
        [self.agreeButton setTitleColor:TIMCommonDynamicColor(@"form_title_color", @"#000000") forState:UIControlStateNormal];
        self.agreeButton.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
    } else {
        [self.agreeButton setTitle:TIMCommonLocalizableString(Agree) forState:UIControlStateNormal];
        self.agreeButton.enabled = YES;
        self.agreeButton.layer.borderColor = [UIColor clearColor].CGColor;
        self.agreeButton.layer.borderWidth = 1;
        [self.agreeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        self.agreeButton.backgroundColor = TIMCommonDynamicColor(@"primary_theme_color", @"#147AFF");
    }

    if (pendencyData.isRejected) {
        [self.rejectButton setTitle:TIMCommonLocalizableString(Disclined) forState:UIControlStateNormal];
        self.rejectButton.enabled = NO;
        self.rejectButton.layer.borderColor = [UIColor clearColor].CGColor;
        [self.rejectButton setTitleColor:TIMCommonDynamicColor(@"form_title_color", @"#000000") forState:UIControlStateNormal];
    } else {
        [self.rejectButton setTitle:TIMCommonLocalizableString(Discline) forState:UIControlStateNormal];
        self.rejectButton.enabled = YES;
        self.rejectButton.layer.borderColor = TUIDemoDynamicColor(@"separator_color", @"#DBDBDB").CGColor;
        self.rejectButton.layer.borderWidth = 0.2;
        [self.rejectButton setTitleColor:TIMCommonDynamicColor(@"primary_theme_color", @"#147AFF") forState:UIControlStateNormal];
    }
    if (self.pendencyData.isRejected && !self.pendencyData.isAccepted) {
        self.agreeButton.hidden = YES;
        self.rejectButton.hidden = NO;
    } else if (self.pendencyData.isAccepted && !self.pendencyData.isRejected) {
        self.agreeButton.hidden = NO;
        self.rejectButton.hidden = YES;
    } else {
        self.agreeButton.hidden = NO;
        self.rejectButton.hidden = NO;
    }

    self.addSourceLabel.hidden = self.pendencyData.hideSource;
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
}
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    CGSize headSize = CGSizeMake(70, 70);

    [self.avatarView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(headSize);
        make.leading.mas_equalTo(12);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = headSize.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).mas_offset(14);
        make.leading.mas_equalTo(self.avatarView.mas_trailing).mas_offset(12);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(120);
    }];
    
    [self.addSourceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(6);
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.height.mas_equalTo(15);
        make.width.mas_equalTo(120);
    }];

    [self.addWordingLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.addSourceLabel.mas_bottom).mas_offset(6);
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.height.mas_equalTo(15);
        make.width.mas_equalTo(120);
    }];
    
    [self.agreeButton sizeToFit];
    [self.agreeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.stackView.mas_leading);
        make.centerY.mas_equalTo(self.stackView);
        make.height.mas_equalTo(self.agreeButton.frame.size.height);
        make.width.mas_equalTo(self.agreeButton.frame.size.width + 20);
    }];
    [self.rejectButton sizeToFit];
    [self.rejectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.agreeButton.mas_trailing).mas_offset(10);
        make.height.mas_equalTo(self.rejectButton.frame.size.height);
        make.width.mas_equalTo(self.rejectButton.frame.size.width + 20);
    }];
    self.stackView.bounds = CGRectMake(0, 0, 3 * self.agreeButton.mm_w + 10, self.agreeButton.mm_h);

}
- (void)agreeClick {
    if (self.pendencyData.cbuttonSelector) {
        UIViewController *vc = self.mm_viewController;
        if ([vc respondsToSelector:self.pendencyData.cbuttonSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [vc performSelector:self.pendencyData.cbuttonSelector withObject:self];
#pragma clang diagnostic pop
        }
    }
}

- (void)rejectClick {
    if (self.pendencyData.cRejectButtonSelector) {
        UIViewController *vc = self.mm_viewController;
        if ([vc respondsToSelector:self.pendencyData.cRejectButtonSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [vc performSelector:self.pendencyData.cRejectButtonSelector withObject:self];
#pragma clang diagnostic pop
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ((touch.view == self.agreeButton)) {
        return NO;
    } else if (touch.view == self.rejectButton) {
        return NO;
    }
    return YES;
}
@end
