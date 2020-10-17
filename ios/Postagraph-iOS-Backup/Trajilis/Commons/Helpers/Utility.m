//
//  Utility.m
//  Trajilis
//
//  Created by bharats802 on 03/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

#import "Utility.h"
#import <UIKit/UIKit.h>


@implementation Utility
+(void)shareOnInsta:(NSString*)videoURL {
    NSString *instagramURL = [NSString stringWithFormat:@"instagram://library?AssetPath=%@",videoURL];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:instagramURL]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:instagramURL] options:@{}  completionHandler:nil];
    }
}
+(Boolean)canShareOnInsta {    
    NSString *instagramURL = [NSString stringWithFormat:@"instagram://"];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:instagramURL]]) {
        return  true;
    } else {
        return  false;
    }
}
@end
