//
//  CustomUITextField.m
//  SimpleAppWithoutMVC
//
//  Created by Vladimir Khabarov on 02.11.2017.
//  Copyright © 2017 vs-khabarov. All rights reserved.
//

#import "CustomUITextField.h"

@implementation CustomUITextField

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(paste:)) {
        return NO;
    }
    return [super canPerformAction:action withSender:sender];
}

@end
