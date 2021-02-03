//
//  KJMidiPlayerVC.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/2.
//  Copyright © 2021 杨科军. All rights reserved.
//

#import "KJMidiPlayerVC.h"
#import "KJMidiPlayer.h"
@interface KJMidiPlayerVC ()<UIPickerViewDataSource, UIPickerViewDelegate>{
    NSInteger index;
}
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel1;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel2;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic,strong) NSArray *temps;

@end

@implementation KJMidiPlayerVC
- (void)dealloc{
    [KJMidiPlayer kj_attempDealloc];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUI];
}
- (void)setUI{
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.label.text = [NSString stringWithFormat:@"midi音源：%@",self.temps[[self.pickerView selectedRowInComponent:0]]];
}
- (IBAction)play:(id)sender {
    NSURL *URL = [[NSBundle mainBundle] URLForResource:self.temps[index] withExtension:@"mid"];
    KJMidiPlayer.shared.videoURL = URL;
    [KJMidiPlayer.shared kj_playerPlay];
}
- (IBAction)pause:(id)sender {
    [KJMidiPlayer.shared kj_playerPause];
}
- (IBAction)repause:(id)sender {
    [KJMidiPlayer.shared kj_playerResume];
}
- (IBAction)stop:(id)sender {
    [KJMidiPlayer.shared kj_playerStop];
}
- (IBAction)slider:(UISlider *)sender {
    NSLog(@"----%f",sender.value);
}
- (IBAction)seekPlay:(UIButton *)sender {
    CGFloat seek = [self.textField.text floatValue];
    if (![KJMidiPlayer.shared isPlaying]) {
        NSURL *URL = [[NSBundle mainBundle] URLForResource:self.temps[index] withExtension:@"mid"];
        KJMidiPlayer.shared.videoURL = URL;
        [KJMidiPlayer.shared kj_playerPlay];
    }
    [KJMidiPlayer.shared kj_playerSeekTime:seek completionHandler:nil];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.temps.count;
}
#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.temps[row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.label.text = [NSString stringWithFormat:@"midi音源：%@",self.temps[row]];
    index = row;
}
#pragma mark - lazy
- (NSArray *)temps{
    if (!_temps) {
        _temps = @[@"绮想轮旋曲",@"命运交响曲第一章",@"埃克赛斯舞曲",@"致爱丽丝"];
    }
    return _temps;
}
@end
