//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Shuo Chang on 11-12-24.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"
#include <math.h>
@interface CalculatorBrain()
@property (nonatomic,strong) NSMutableArray *programStack;
+ (double)popOperandOffStack:(NSMutableArray *) stack;
+ (void) replaceVariable:(NSString *)key
         WithNumber:(NSNumber *)value
         FromStack:(NSMutableArray *)stack;
+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack
                     PreviousOperator:(NSString *)preOp;
@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;
- (NSMutableArray *)programStack
{
    if (_programStack == nil) { // lazy instantiation
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (void)pushVariable:(NSString *)variable
{
    [self.programStack addObject:variable];
}

- (double)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program];
}

- (id)program
{
    return [self.programStack copy];
}

+ (BOOL)isBinaryOperator:(NSString *)operator
{
    return [[NSSet setWithObjects:@"+", @"-", @"*", @"/", nil] containsObject:operator];
}

+ (BOOL)isUnaryOperator:(NSString *)operator
{
    return [[NSSet setWithObjects:@"sin", @"cos", @"sqrt", nil] containsObject:operator];
}

+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack
              PreviousOperator:(NSString *)preOp
{
    NSString *description;
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setUsesSignificantDigits:YES];
        description = [formatter stringFromNumber:topOfStack];
    }else if ([topOfStack isKindOfClass:[NSString class]]){
        if ([self isBinaryOperator:topOfStack]) {
            NSString *rexpr = [self descriptionOfTopOfStack:stack PreviousOperator:topOfStack];
            description = [NSString stringWithFormat:@"%@ %@ %@", [self descriptionOfTopOfStack:stack PreviousOperator:topOfStack], topOfStack, rexpr];
            NSSet *additionSubstraction = [NSSet setWithObjects:@"+", @"-", nil];
            BOOL requireParenthesis = [preOp isEqualToString:@"/"]||([preOp isEqualToString:@"*"]&&[additionSubstraction containsObject:topOfStack])||([preOp isEqualToString:@"-"]&&[additionSubstraction containsObject:topOfStack]);
            if (requireParenthesis) description = [NSString stringWithFormat:@"(%@)",description];
        }else if ([self isUnaryOperator:topOfStack]) {
            description = [NSString stringWithFormat:@"%@(%@)",topOfStack, [self descriptionOfTopOfStack:stack PreviousOperator:topOfStack]];
        }else{
            description = topOfStack;
        }
    }
    
    return description;
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSString *description = @"";
    
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
        description = [self descriptionOfTopOfStack:stack PreviousOperator:@""];
        while ([stack count]!=0) {
            description = [NSString stringWithFormat:@"%@, %@",description,[self descriptionOfTopOfStack:stack PreviousOperator:@""]];
        }
    }
    
    return description;
}

+ (double)popOperandOffStack:(NSMutableArray *) stack
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;
        
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        }else if ([operation isEqualToString:@"-"]) {
            double rexpr = [self popOperandOffStack:stack];
            result = [self popOperandOffStack:stack] - rexpr;
        }else if ([operation isEqualToString:@"*"]) {
            result = [self popOperandOffStack:stack] * [self popOperandOffStack:stack];
        }else if ([operation isEqualToString:@"/"]) {
            double rexpr = [self popOperandOffStack:stack];
            if (rexpr != 0) {
                result = [self popOperandOffStack:stack] / rexpr;
            }
        }else if ([operation isEqualToString:@"sin"]){
            result = sin([self popOperandOffStack:stack]);
        }else if ([operation isEqualToString:@"cos"]){
            result = cos([self popOperandOffStack:stack]);
        }else if ([operation isEqualToString:@"sqrt"]){
            result = sqrt([self popOperandOffStack:stack]);
        }else if ([operation isEqualToString:@"π"]){
            result = M_PI;
        }
    }else if([topOfStack isKindOfClass:[NSNumber class]]){
        result = [topOfStack doubleValue];
    }
    
    return result;
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
    NSMutableSet* variableSet;
    NSSet* operationSet = [NSSet setWithObjects:@"+",@"-",@"*",@"/",@"sin",@"cos",@"sqrt",@"π", nil];
    if ([program isKindOfClass:[NSArray class]]) {
        for (id item in program) {
            if ([item isKindOfClass:[NSString class]])  [variableSet addObject:(NSString *)item];
        }
    }
    [variableSet minusSet:operationSet];
    return [variableSet copy];
}

+ (void) replaceVariable:(NSString *)key
              WithNumber:(NSNumber *)value
               FromStack:(NSMutableArray *)stack
{
    for (NSUInteger i = 0; i<[stack count]; i++) {
        if ([[stack objectAtIndex:i] isKindOfClass:[NSString class]]) {
            if ([[stack objectAtIndex:i] isEqualToString:key]) [stack replaceObjectAtIndex:i withObject:value];
        }
    }
    
}

+ (double)runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack];
}

+ (double)runProgram:(id)program 
      usingVariables:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]&&variableValues) {
        stack = [program mutableCopy];
        NSSet *variableSet = [self variablesUsedInProgram:program];
        for (NSString *key in variableSet) {
            id value = [variableValues objectForKey:key];
            if (value == nil) [self replaceVariable:key WithNumber:[NSNumber numberWithDouble:0] FromStack:stack];
            else if ([value isKindOfClass:[NSNumber class]]) [self replaceVariable:key WithNumber:value FromStack:stack];
        }
    }
    return [self popOperandOffStack:stack];
}

@end
