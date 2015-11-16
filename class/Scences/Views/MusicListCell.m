//
//  MusicListCell.m
//  MusicPlayer
//
//  Created by lanou3g on 15/10/15.
//  Copyright (c) 2015年 魏义涛. All rights reserved.
//

#import "MusicListCell.h"
#import "UIImageView+WebCache.h"
@interface MusicListCell ()

@property (strong, nonatomic) IBOutlet UILabel *songNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *singerNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *songImageView;

@end

@implementation MusicListCell

- (void)binModel:(MusicModel *)model
{
    self.songNameLabel.text = model.name;
    self.singerNameLabel.text = model.singer;
    [self.songImageView sd_setImageWithURL:[NSURL URLWithString:model.picUrl]];
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
