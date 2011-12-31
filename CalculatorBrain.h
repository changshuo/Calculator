//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Shuo Chang on 11-12-24.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject
- (void)pushOperand:(double)operand;
- (void)pushVariable:(NSString *)variable;
- (double)performOperation:(NSString *)operation;

@property (readonly) id program;
+ (double)runProgram:(id)program;
+ (double)runProgram:(id)program 
      usingVariables:(NSDictionary *)variableValues;
+ (NSSet *)variablesUsedInProgram:(id)program;
+ (NSString *)descriptionOfProgram:(id)program;
@end
