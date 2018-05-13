//
//  GSObject.h
//  JasonStuff
//
//  Created by Geoffrey Slinker on 1/2/16.
//  Copyright © 2016 Slinkworks LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GSObject : NSObject

- (id)valueForKey:(NSString *)key;
- (void)setValue:(id)value forKey:(NSString *)key;
- (NSData *) toJsonDataWithOptions:(NSJSONWritingOptions)opt;
- (NSString *) toJsonStringWithOptions:(NSJSONWritingOptions)opt;

+ (id<NSObject>) create:(Class) class fromJsonString:(NSString *)jsonString;
+ (id<NSObject>) create:(Class) class fromJsonData:(NSData *)jsonData;

+ (NSDictionary<NSString *,id> *)dictionaryWithValues : (id) object;
+ (BOOL) hasPropertyNamed:(NSString*) propertyName forObject: (id) object;
+ (Class)classOfPropertyNamed:(NSString*) propertyName forObject: (id) object;


@end
