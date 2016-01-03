# GSObject

GSObject is a class that allows you to serialize to JSON or deserialize from JSON.

GSObject is a subclass of NSObject.
GSObject overrides valueForKey and setValue:forKey

GSObject also looks for the following SELECTORs:
- (NSString *) jsonValue
+ (NSNumber *) initWithJsonValue : (NSString *) jsonValue

These SELECTORS allow you to create subclasses or categories to control the JSON. Examples of usages would be with NSDate or NSNumber as currency.

Following are some simple classes to use as an example:


//
//  ThingOne.h
//  JasonStuff
//
//  Created by Geoffrey Slinker on 12/28/15.
//  Copyright © 2015 Slinkworks LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSObject.h"
#import "ThingTwo.h"

@interface ThingOne : GSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) ThingTwo *thingTwo;
@property (nonatomic, retain) NSArray *values;
@property (nonatomic, retain) NSDictionary *dict;
@property int myInt;
@property float myFloat;
@property BOOL myBool;
@property (nonatomic, retain) NSNumber* someMoney;


@end

-----------------------------------------------------------------------

//
//  ThingOne.m
//  JasonStuff
//
//  Created by Geoffrey Slinker on 12/28/15.
//  Copyright © 2015 Slinkworks LLC. All rights reserved.
//

#import "ThingOne.h"

@implementation ThingOne

@synthesize name;
@synthesize thingTwo;
@synthesize values;
@synthesize dict;
@synthesize myInt;
@synthesize myFloat;
@synthesize myBool;
@synthesize someMoney;

- (instancetype)init
{
self = [super init];

thingTwo = [[ThingTwo alloc] init];

thingTwo.stuff = @"Thing Two Stuff";
thingTwo.someOtherStuff = @"Thing Two Other Stuff";
NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
[dateFormater setDateFormat:@"yyyy-mm-dd"];
thingTwo.someDate =  [dateFormater dateFromString:@"1963-10-07"];

values = [NSArray arrayWithObjects:@"Value1", @"Value2", @"Value3", nil];

dict = [NSDictionary dictionaryWithObjectsAndKeys:@"value1", @"key1", @"value2", @"key2", nil];

myInt = 5431;
myFloat = 123.456f;
myBool = YES;

someMoney = [NSNumber numberWithInt:503];

return self;
}

@end

-----------------------------------------------------------------------

//
//  ThingTwo.h
//  JasonStuff
//
//  Created by Geoffrey Slinker on 12/28/15.
//  Copyright © 2015 Slinkworks LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSObject.h"

@interface ThingTwo : GSObject

@property (nonatomic, retain) NSString *stuff;
@property (nonatomic, retain) NSString *someOtherStuff;
@property (nonatomic, retain) NSDate *someDate;
@property (nonatomic, retain) NSString *nullString;
@property (nonatomic, retain) NSDate *nullDate;

@end

-----------------------------------------------------------------------

//
//  ThingTwo.m
//  JasonStuff
//
//  Created by Geoffrey Slinker on 12/28/15.
//  Copyright © 2015 Slinkworks LLC. All rights reserved.
//

#import "ThingTwo.h"

@implementation ThingTwo

@synthesize stuff;
@synthesize someOtherStuff;
@synthesize someDate;

- (instancetype)init
{
self = [super init];

someDate = [NSDate date];

return self;
}

@end

-----------------------------------------------------------------------

Here is some example code on how to use it:

ThingOne* object1 = [[ThingOne alloc] init];
object1.name = @"John Jones";


NSData* jsonData1 = [object1 toJsonDataWithOptions:NSJSONWritingPrettyPrinted];
NSString *jsonString1 = [object1 toJsonStringWithOptions:NSJSONWritingPrettyPrinted];

NSDictionary<NSString *,id> *dict1 =  [GSObject dictionaryWithValues:object1];

NSString *roundTripJson1 = [object1 toJsonStringWithOptions:NSJSONWritingPrettyPrinted];

ThingOne *object2 = [GSObject create:[ThingOne class] fromJsonString:roundTripJson1];
NSString *roundTripJson2 = [object2 toJsonStringWithOptions:NSJSONWritingPrettyPrinted];


NSString *json3 = @"{\"myInt\" : 2039,\"thingTwo\" : {\"stuff\" : \"Thing Two Stuff2\",\"someOtherStuff\" : \"Thing Two Other Stuff2\"},\"name\" : \"William Smith\",\"dict\" : {\"key10\" : \"value10\",\"key20\" : \"value20\"},\"values\" : [\"ValueA\",\"ValueB\",\"ValueC\"]}";

ThingOne *object3 = [GSObject create:[ThingOne class] fromJsonString:json3];
NSDictionary<NSString *,id> *dict3 =  [GSObject dictionaryWithValues:object3];
NSString *roundTripJson3 = [object3 toJsonStringWithOptions:NSJSONWritingPrettyPrinted];

-----------------------------------------------------------------------
Here are the variables from the debugger:



(lldb) po jsonString1
{
  "values" : [
    "Value1",
    "Value2",
    "Value3"
  ],
  "myInt" : 5431,
  "myFloat" : 123.456,
  "myBool" : true,
  "someMoney" : "$503.00",
  "thingTwo" : {
    "stuff" : "Thing Two Stuff",
    "nullDate" : null,
    "someDate" : "1963-01-07 07:10:00 +0000",
    "nullString" : null,
    "someOtherStuff" : "Thing Two Other Stuff"
  },
  "name" : "John Jones",
  "dict" : {
    "key1" : "value1",
    "key2" : "value2"
  }
}

(lldb) po roundTripJson1
{
  "values" : [
    "Value1",
    "Value2",
    "Value3"
  ],
  "myInt" : 5431,
  "myFloat" : 123.456,
  "myBool" : true,
  "someMoney" : "$503.00",
  "thingTwo" : {
    "stuff" : "Thing Two Stuff",
    "nullDate" : null,
    "someDate" : "1963-01-07 07:10:00 +0000",
    "nullString" : null,
    "someOtherStuff" : "Thing Two Other Stuff"
  },
  "name" : "John Jones",
  "dict" : {
    "key1" : "value1",
    "key2" : "value2"
  }
}

(lldb) po roundTripJson2
{
  "values" : [
    "Value1",
    "Value2",
    "Value3"
  ],
  "myInt" : 5431,
  "myFloat" : 123.456,
  "myBool" : true,
  "someMoney" : "$503.00",
  "thingTwo" : {
    "stuff" : "Thing Two Stuff",
    "nullDate" : null,
    "someDate" : "1963-01-07 07:10:00 +0000",
    "nullString" : null,
    "someOtherStuff" : "Thing Two Other Stuff"
  },
  "name" : "John Jones",
  "dict" : {
    "key1" : "value1",
    "key2" : "value2"
  }
}

(lldb) po roundTripJson3
{
  "values" : [
    "ValueA",
    "ValueB",
    "ValueC"
  ],
  "myInt" : 2039,
  "myFloat" : 123.456,
  "myBool" : true,
  "someMoney" : "$503.00",
  "thingTwo" : {
    "stuff" : "Thing Two Stuff2",
    "nullDate" : null,
    "someDate" : "1963-01-07 07:10:00 +0000",
    "nullString" : null,
    "someOtherStuff" : "Thing Two Other Stuff2"
  },
  "name" : "William Smith",
  "dict" : {
    "key10" : "value10",
    "key20" : "value20"
  }
}

(lldb) 


-----------------------------------------------------------------------

-----------------------------------------------------------------------



