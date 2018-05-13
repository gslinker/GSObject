//
//  GSObject.m
//  JasonStuff
//
//  Created by Geoffrey Slinker on 1/2/16.
//  Copyright © 2016 Slinkworks LLC. All rights reserved.
//

#import "GSObject.h"
#import <objc/runtime.h>

@implementation GSObject

- (id)valueForKey:(NSString *)key {
    id results = nil;
    
    //Get the class of the property for the key
    Class propertyClass = [GSObject classOfPropertyNamed:key forObject:self];
    if(propertyClass != nil) {
        
        @try {
            
            //Call the default behavior
            id temp = [super valueForKey:key];
            
            //If the property is a GSObject then return the dictionary that represents the object
            if([propertyClass isSubclassOfClass:[GSObject class]])
            {
                NSDictionary<NSString *,id> *dict = [GSObject dictionaryWithValues:temp];
                if ([dict.allKeys count] != 0) {
                    results = dict;
                }
                else {  //If there were no properties returned in the dictionary
                    results = [NSNull null];
                }
            }
            else { //This is not a GSObject
                
                //If the property is an NSObject has the user provided a method / selector named descriptionForJson?
                if([[temp class] isSubclassOfClass:[NSObject class]])
                {
                    NSObject *tempNSOBject = (NSObject *)temp;
                    SEL selector = NSSelectorFromString(@"jsonValue");
                    
                    if ([tempNSOBject respondsToSelector:selector]) {
                        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                                    [[tempNSOBject class] instanceMethodSignatureForSelector:selector]];
                        [invocation setSelector:selector];
                        [invocation setTarget:tempNSOBject];
                        [invocation invoke];
                        NSString *resultJSONDescription = nil;
                        [invocation getReturnValue:&resultJSONDescription];
                        temp = resultJSONDescription;
                    }
                    else { //This is an NSObject that doesn't respond to the selector descriptionForJSON
                        
                        //If the property is an NSDate return the string representation
                        if([propertyClass isSubclassOfClass:[NSDate class]])
                        {
                            temp = [temp description];
                        }
                    }
                }
                
                
                results = temp;
            }
            
        }
        @catch (NSException *exception) {
            results = [super valueForKey:key];
        }
        @finally {
        }
        
        
    }
    else {
        //The property is not some type of class, so call the default behavior.
        //This means the property could be an int, float, etc.
        results = [super valueForKey:key];
    }
    
    return results;
    
}


- (void)setValue:(id)value forKey:(NSString *)key {
    
    BOOL hasProperty = [GSObject hasPropertyNamed:key forObject:self];
    
    if(YES == hasProperty)
    {
        Class propertClass = [GSObject classOfPropertyNamed:key forObject:self];
        
        if ( [value isKindOfClass:[NSDictionary class]] ) {
            
            //If the value is a dictionary, is this a dictionary of property values to instantiate a GSObject?
            
            if([propertClass isSubclassOfClass:[GSObject class]])
            {
                id temp = [super valueForKey:key];
                if(temp == nil)
                {
                    
                    temp = [[propertClass alloc]init];
                    [super setValue:temp forKey:key];
                }
                
                [temp setValuesForKeysWithDictionary:value];
            }
            else //This is just a dictionary value for a dictionary property
            {
                [super setValue:value forKey:key];
            }
            
        }
        else {
            @try {
                
                if( [propertClass isSubclassOfClass:[NSObject class]])
                {
                    SEL selector = NSSelectorFromString(@"initWithJsonValue:");
                    
                    if ([[propertClass class] respondsToSelector:selector]) {
                        NSMethodSignature *signature = [[propertClass class] methodSignatureForSelector:selector];
                        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
                        [invocation setSelector:selector];
                        [invocation setArgument:&value atIndex:2];
                        [invocation setTarget:[propertClass class]];
                        [invocation invoke];
                        id results = nil;
                        [invocation getReturnValue:&results];
                        value = results;    //change the value to the newly created json value results
                    }
                    
                    [super setValue:value forKey:key];
                    
                }
                else {
                    //properties that are not objects, like long, float, char, etc.
                    [super setValue:value forKey:key];
                }
            }
            @catch (NSException *exception) {
            }
            @finally {
            }
        }
    }
}

- (NSData *) toJsonDataWithOptions:(NSJSONWritingOptions)opt {
    
    NSDictionary<NSString *,id> *results =  [GSObject dictionaryWithValues:self];
    
    NSError *error;
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:results options:opt error:&error];
    return jsonData;
}

- (NSString *) toJsonStringWithOptions:(NSJSONWritingOptions)opt {
    
    NSData* jsonData = [self toJsonDataWithOptions:opt];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

+ (id<NSObject>) create:(Class) class fromJsonString:(NSString *)jsonString {
    
    id<NSObject> results = nil;
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    results = [GSObject create:class fromJsonData:jsonData];
    
    return results;
}

+ (id<NSObject>) create:(Class) class fromJsonData:(NSData *)jsonData {
    
    id<NSObject> results = nil;
    
    if([class isSubclassOfClass:[NSObject class]])
    {
        NSError *localError;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&localError];
        
        id temp = [[class alloc] init];
        [temp setValuesForKeysWithDictionary:dict];
        results = temp;
    }
    
    return results;
}



+ (NSDictionary<NSString *,id> *)dictionaryWithValues : (id) object {
    
    NSDictionary<NSString *,id> * results = nil;
    
    //Use introspection to get all of the properties.
    
    uint count;
    objc_property_t* properties = class_copyPropertyList([object class], &count);
    NSMutableArray<NSString *> *propertyNames = [[NSMutableArray<NSString *> alloc] init];
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        NSString *name = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        [propertyNames addObject:name];
    }
    free(properties);
    
    if([propertyNames count] > 0)
    {
        results = [object dictionaryWithValuesForKeys:propertyNames];
    }
    
    return results;
}

+ (BOOL) hasPropertyNamed:(NSString*) propertyName forObject: (id) object {
    BOOL results = NO;
    
    objc_property_t property = class_getProperty([object class], [propertyName UTF8String]);
    
    //Unknown properties are skipped
    if(nil != property)
    {
        results = YES;
    }
    
    return results;
}

+ (Class)classOfPropertyNamed:(NSString*) propertyName forObject: (id) object {
    
    Class propertyClass = nil;
    objc_property_t property = class_getProperty([object class], [propertyName UTF8String]);
    
    //Unknown properties are skipped
    if(nil != property)
    {
        NSString *propertyAttributes = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        NSArray *splitPropertyAttributes = [propertyAttributes componentsSeparatedByString:@","];
        if (splitPropertyAttributes.count > 1)
        {
            NSString *encodeType = splitPropertyAttributes[0];
            NSArray *splitEncodeType = [encodeType componentsSeparatedByString:@"\""];
            
            //https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101
            //The first element is the type, T@ will be a class, Tq is a long long, Ts short, Tc character, Td double, etc...
            
            if([splitEncodeType count] > 1) {
                NSString *className = splitEncodeType[1];
                propertyClass = NSClassFromString(className);
            }
        }
    }
    return propertyClass;
}


@end
