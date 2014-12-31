//
//  YAMLUnitTests.m
//  YAMLUnitTests
//
//  Created by Carl Brown on 7/31/11.
//  Copyright 2011 PDAgent, LLC. Released under MIT License.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "YAMLSerialization.h"

@interface YAMLUnitTests : XCTestCase

@end

@implementation YAMLUnitTests {
  NSBundle *_testBundle;
}

#pragma mark - Setup

- (void)setUp {
  [super setUp];
  _testBundle = [NSBundle bundleForClass:[self class]];
}

- (void)tearDown {
  [super tearDown];
}

#pragma mark - Tests


- (void)testYAMLReadData {
  NSString *fileName = [[NSBundle bundleForClass:[self class]] pathForResource:@"basic"
                                                                        ofType:@"yaml"];
	NSData *data = [NSData dataWithContentsOfFile:fileName];
  
  //NSTimeInterval before = [[NSDate date] timeIntervalSince1970];
  
  NSError *error;
  NSMutableArray *yaml = [YAMLSerialization objectsWithYAMLData:data
                                                        options:kYAMLReadOptionStringScalars
                                                          error:&error];

  XCTAssertNil(error, @"There should be no error");
	//NSLog(@"YAMLWithData took %f", ([[NSDate date] timeIntervalSince1970] - before));
	//NSLog(@"%@", yaml);
  XCTAssertEqual((int) 10, (int) [yaml count], @"Wrong number of expected objects");
}

- (void)testReadStream {
  NSString *fileName = [[NSBundle bundleForClass:[self class]] pathForResource:@"basic"
                                                                          ofType:@"yaml"];
  NSInputStream *stream = [[NSInputStream alloc] initWithFileAtPath: fileName];

  NSError *error;
	//NSTimeInterval before2 = [[NSDate date] timeIntervalSince1970];
	NSMutableArray *yaml2 = [YAMLSerialization objectsWithYAMLStream:stream
                                                           options:kYAMLReadOptionStringScalars
                                                             error:&error];
  
  XCTAssertNil(error, @"Error should not be raised");
	//NSLog(@"YAMLWithStream took %f", ([[NSDate date] timeIntervalSince1970] - before2));
  //NSLog(@"%@", yaml2);
  XCTAssertEqual((int) 10, (int) [yaml2 count], @"Wrong number of expected objects");
}

- (void)testEmptyYaml {
  NSInputStream* stream = [self streamForExample:@"empty"];
  NSError *error;
  NSMutableArray* objects = [YAMLSerialization objectsWithYAMLStream:stream options:kYAMLReadOptionStringScalars error:&error];
  XCTAssert([objects count] == 0, @"Objects should be nil");
  
  id object = [YAMLSerialization objectWithYAMLStream:stream options:kYAMLReadOptionStringScalars error:&error];
  XCTAssertNil(object, @"Object should be nil");
}


- (void)testSequenceParsing {
  NSInputStream* stream = [self streamForExample:@"sequence"];
  NSError *error;
  NSMutableArray* objects = [YAMLSerialization objectsWithYAMLStream:stream options:kYAMLReadOptionStringScalars error:&error];
  NSArray *list = objects[0];
  NSString *first = list[0];
  XCTAssert([first isEqualToString:@"foo"], @"Can't parse sequence");
}

- (void)testNullParsing {
  NSInputStream* stream = [self streamForExample:@"sequenceWithNull"];
  NSError *error;
  NSMutableArray* objects = [YAMLSerialization objectsWithYAMLStream:stream options:0 error:&error];
  NSArray *list = objects[0];
  XCTAssertEqual(list[0], [NSNull null], @"Should be nil.");
  XCTAssertEqual(list[1], [NSNull null], @"Should be nil.");
  XCTAssertEqual(list[2], [NSNull null], @"Should be nil.");
}

- (void)testNumberParsing {
  NSInputStream* stream = [self streamForExample:@"sequenceWithNumbers"];
  NSError *error;
  NSMutableArray* objects = [YAMLSerialization objectsWithYAMLStream:stream options:0 error:&error];
  NSArray *list = objects[0];
  XCTAssertEqualObjects(list[0], [NSNumber numberWithInt:1], @"Should parse integer 1.");
  XCTAssertEqualObjects(list[1], [NSNumber numberWithDouble:1.2], @"Should parse double 1.2");
  XCTAssertEqualObjects(list[2], [NSNumber numberWithDouble:100], @"Should parse double 1e2");
}

- (void)testBoolParsing {
  NSInputStream* stream = [self streamForExample:@"sequenceWithBools"];
  NSError *error;
  NSMutableArray* objects = [YAMLSerialization objectsWithYAMLStream:stream options:0 error:&error];
  NSArray *list = objects[0];
  XCTAssertEqualObjects(list[0], @YES, @"Should parse yes.");
  XCTAssertEqualObjects(list[1], @NO, @"Should parse no.");

  XCTAssertEqualObjects(list[2], @YES, @"Should parse y.");
  XCTAssertEqualObjects(list[3], @NO, @"Should parse n.");

  XCTAssertEqualObjects(list[4], @YES, @"Should parse true.");
  XCTAssertEqualObjects(list[5], @NO, @"Should parse false.");

  XCTAssertEqualObjects(list[6], @YES, @"Should parse on.");
  XCTAssertEqualObjects(list[7], @NO, @"Should parse off.");
}

- (void)testComplex {
  NSInputStream* stream = [self streamForExample:@"complex"];
  NSError *error;
  NSMutableArray* objects = [YAMLSerialization objectsWithYAMLStream:stream options:0 error:&error];
  NSArray *list = objects[0];
  XCTAssertNil(error, @"Error detected %@", error);
  NSLog(@"Objects: %@", list);
}

#pragma mark - Support Methods

-(NSInputStream *)streamForExample:(NSString *)example {
  NSString *fileName = [_testBundle pathForResource:example ofType:@"yaml"];
  return [[NSInputStream alloc] initWithFileAtPath: fileName];
}

@end
