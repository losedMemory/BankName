//
//  ViewController.m
//  BankName
//
//  Created by 周松 on 17/4/1.
//  Copyright © 2017年 周松. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITextFieldDelegate>
@property (nonatomic,weak) UILabel *cardNumLabel;
@property (nonatomic,weak) UITextField *cardNumTextField;//卡号
@property (nonatomic,weak) UILabel *bank;
@property (nonatomic,weak) UILabel *bankName;
@property (nonatomic,weak) UILabel *bankAccountLabel;
@property (nonatomic,weak) UITextField *bankAccountTextField;//开户行
@end

@implementation ViewController

#pragma mark -- 懒加载
- (UILabel *)cardNumLabel {
    if (_cardNumLabel == nil) {
        UILabel *label = [[UILabel alloc]init];
        [self.view addSubview:label];
        _cardNumLabel = label;
        label.text = @"卡号";
    }
    return _cardNumLabel;
}

- (UITextField *)cardNumTextField {
    if (_cardNumTextField == nil) {
        UITextField *textField = [[UITextField alloc]init];
        [self.view addSubview:textField];
        _cardNumTextField = textField;
        textField.placeholder = @"请输入卡号";
        textField.tag = 2;
    }
    return _cardNumTextField;
}

- (UILabel *)bank {
    if (_bank == nil) {
        UILabel *label = [[UILabel alloc]init];
        [self.view addSubview:label];
        _bank = label;
        label.text = @"银行";
    }
    return _bank;
}

- (UILabel *)bankName {
    if (_bankName == nil) {
        UILabel *label = [[UILabel alloc]init];
        [self.view addSubview:label];
        _bankName = label;
    }
    return _bankName;
}

- (UILabel *)bankAccountLabel {
    if (_bankAccountLabel == nil) {
        UILabel *label = [[UILabel alloc]init];
        [self.view addSubview:label];
        label.text = @"开户行";
        _bankAccountLabel = label;
    }
    return _bankAccountLabel;
}

- (UITextField *)bankAccountTextField {
    if (_bankAccountTextField == nil) {
        UITextField *textField = [[UITextField alloc]init];
        [self.view addSubview:textField];
        _bankAccountTextField = textField;
        textField.placeholder = @"请输入开户行";
        textField.tag = 1;
    }
    return _bankAccountTextField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bankAccountTextField.tag = 1;
    self.cardNumTextField.delegate = self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.cardNumLabel.frame = CGRectMake(20, 50, 60, 30);
    self.cardNumTextField.frame = CGRectMake(100, 50, 250, 30);
    self.bank.frame = CGRectMake(20, 100, 60, 30);
    self.bankName.frame = CGRectMake(100, 100, 150, 30);
    self.bankAccountLabel.frame = CGRectMake(20, 150, 60, 30);
    self.bankAccountTextField.frame = CGRectMake(100, 150, 150, 30);
}

#pragma mark --UITextFieldDelegate
//输入时一直监听,返回YES表示修改生效,返回NO表示不修改
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == 1) {
        return YES;
    }
    NSString *text = [self.cardNumTextField text];
    //返回一个字符集,指定字符串中包含的字符
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789\b"];
    //string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //invertedSet  除了characterSet中包含的字符都找出来
    if ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound) {
        return NO;
    }
    
    text = [text stringByReplacingCharactersInRange:range withString:string];
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //不能写nil
    NSString *newString = @"";
    while (text.length > 0) {
        //每4位截取/不够4位有多少截取多少
        NSString *subString = [text substringToIndex:MIN(text.length, 4)];
        newString = [newString stringByAppendingString:subString];
        //加空格
        if (subString.length == 4) {
            newString = [newString stringByAppendingString:@" "];
        }
        text = [text substringFromIndex:MIN(text.length, 4)];
    }
    newString = [newString stringByTrimmingCharactersInSet:[characterSet invertedSet]];
    //限制长度
    if (newString.length >= 24) {
        return NO;
    }
    
    [self.cardNumTextField setText:newString];
    NSString *originalStr = [newString stringByReplacingOccurrencesOfString:@" " withString:@""];
    //判断实哪家银行,并赋值
    if ([self returnBankName:originalStr].length > 0) {
        self.bankName.text = [self returnBankName:originalStr];
    }
    //小于6位清空
    if (self.cardNumTextField.text.length < 6) {
        self.bankName.text = @"";
    }
    
    return NO;
}
//编辑结束
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.cardNumTextField.text.length <= 0 || self.cardNumTextField.text.length > 24) {
        //提示错误信息
        self.bankName.text = @"";
    }
}

//根据卡号判断银行
- (NSString *)returnBankName:(NSString *)cardName {
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"bank" ofType:@"plist"];
    NSDictionary *resultDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSArray *bankBin = resultDic.allKeys;
    if (cardName.length < 6) {
        return @"";
    }
    NSString *cardbin_6 ;
    if (cardName.length >= 6) {
        cardbin_6 = [cardName substringWithRange:NSMakeRange(0, 6)];
    }
    NSString *cardbin_8 = nil;
    if (cardName.length >= 8) {
        //8位
        cardbin_8 = [cardName substringWithRange:NSMakeRange(0, 8)];
    }
    if ([bankBin containsObject:cardbin_6]) {
        return [resultDic objectForKey:cardbin_6];
    } else if ([bankBin containsObject:cardbin_8]){
        return [resultDic objectForKey:cardbin_8];
    } else {
        return @"";
    }
    return @"";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
