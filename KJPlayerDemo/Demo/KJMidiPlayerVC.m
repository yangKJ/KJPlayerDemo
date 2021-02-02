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
@property (nonatomic,strong) KJMidiPlayer *player;

@end

@implementation KJMidiPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUI];
}
- (void)setUI{
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.label.text = [NSString stringWithFormat:@"midi音源：%@",self.temps[[self.pickerView selectedRowInComponent:0]]];
    self.player = [KJMidiPlayer kj_sharedInstance];
}
- (IBAction)play:(id)sender {
    NSURL *URL = [[NSBundle mainBundle] URLForResource:self.temps[index] withExtension:@""];
    self.player.assetURL = URL;
    [self.player kj_playerPlay];
}
- (IBAction)pause:(id)sender {
    [self.player kj_playerPause];
}
- (IBAction)repause:(id)sender {
//    [[KJMIDIPlayer sharedInstance] kj_setPlayerPlaySeek:20];
    [self.player kj_playerResume];
}
- (IBAction)stop:(id)sender {
    [self.player kj_playerStop];
}
- (IBAction)slider:(UISlider *)sender {
    NSLog(@"----%f",sender.value);
}
- (IBAction)seekPlay:(UIButton *)sender {
    CGFloat seek = [self.textField.text floatValue];
    if (![self.player isPlaying]) {
        NSString *string = [self.label.text substringFromIndex:9];
        NSArray *array = [string componentsSeparatedByString:@"."];
        NSString *name = [NSString stringWithFormat:@"%@",array[0]];
        NSURL *URL = [[NSBundle mainBundle] URLForResource:name withExtension:@"mid"];
        self.player.assetURL = URL;
        [self.player kj_playerPlay];
    }
    [self.player kj_playerSeekTime:seek completionHandler:nil];
//    [self.player kj_setPlayerPlaySeek:seek];
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
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"MidiFile" ofType:@"bundle"];
        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:bundlePath];
        NSMutableArray *temps = [NSMutableArray array];
        NSString *imageName;
        while((imageName = [enumerator nextObject]) != nil) {
            [temps addObject:imageName];
        }
        _temps = temps.mutableCopy;
    }
    return _temps;
}
@end
