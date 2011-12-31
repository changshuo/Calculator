//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Shuo Chang on 11-12-24.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController() // private interface
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringNumber;
@property (strong, nonatomic) CalculatorBrain *brain;
@property (weak, nonatomic) IBOutlet UILabel *history;
@property (weak, nonatomic) IBOutlet UILabel *variables;
@property (strong, nonatomic) NSDictionary *testVariableValues;
- (BOOL) hasDecimalPoint:(NSString *) str;
- (void) displayHistory:(NSString *) str;
- (void) updateDisplays;
@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize userIsInTheMiddleOfEnteringNumber = _userIsInTheMiddleOfEnteringNumber;
@synthesize brain = _brain;
@synthesize history = _history;
@synthesize variables = _variables;
@synthesize testVariableValues = _testVariableValues;

- (CalculatorBrain *)brain{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (IBAction)digitPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringNumber) {
        self.display.text = [self.display.text stringByAppendingString:sender.currentTitle];
    }else{
        self.userIsInTheMiddleOfEnteringNumber = YES;
        self.display.text = sender.currentTitle;
    }
}

- (IBAction)pointPressed {
    if ([self hasDecimalPoint:self.display.text]) {
        self.display.text = [self.display.text stringByAppendingString:@"."];
        self.userIsInTheMiddleOfEnteringNumber = YES;
    }
}

- (BOOL) hasDecimalPoint:(NSString *) str{
    if (floor([str doubleValue])==[str doubleValue]) return YES;
    return NO;
}

- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    [self displayHistory:self.display.text];
    self.userIsInTheMiddleOfEnteringNumber = NO;
}

- (IBAction)operationPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringNumber) [self enterPressed];
    double result = [self.brain performOperation:sender.currentTitle];
    [self displayHistory:sender.currentTitle];
    NSString *resultString = [NSString stringWithFormat:@"%g",result]; // puting double into a string
    self.display.text = resultString;
}

- (IBAction)variablePressed:(UIButton *)sender {
    [self.brain pushVariable:sender.currentTitle];
}

- (void) displayHistory:(NSString *) str{
    self.history.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
}

- (IBAction)utilityPressed:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"C"]){
        self.display.text = @"0";
        self.history.text = @"";
        self.userIsInTheMiddleOfEnteringNumber = NO;
        self.brain = [[CalculatorBrain alloc] init];
    }else if([sender.currentTitle isEqualToString:@"Undo"]){
        // undo codes here
    }
}

- (void)updateDisplays
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setUsesSignificantDigits:YES];
    NSString *result = [formatter stringFromNumber:[NSNumber numberWithDouble:[CalculatorBrain runProgram:self.brain.program usingVariables:self.testVariableValues]]];
    self.display.text = result;
    self.variables.text = @"";
    for (id key in self.testVariableValues) {
        id value = [self.testVariableValues objectForKey:key];
        if ([key isKindOfClass:[NSString class]]&&[value isKindOfClass:[NSNumber class]]) {
            [self.variables.text stringByAppendingString:[NSString stringWithFormat:@"%@ = %@ ",key, [formatter stringFromNumber:value]]];
        }
    }
    
}

- (IBAction)testPressed:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"Test 1"]) {
        self.testVariableValues = nil;
    }else if ([sender.currentTitle isEqualToString:@"Test 2"]) {
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:1.5], @"x", [NSNumber numberWithDouble:2], @"y", [NSNumber numberWithDouble:0.5], @"z", nil];
    }else if ([sender.currentTitle isEqualToString:@"Test 3"]) {
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:0], @"x", nil];
    }
    [self updateDisplays];
}

- (void)viewDidUnload {
    [self setVariables:nil];
    [super viewDidUnload];
}
@end
