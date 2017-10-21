//
//  ZTMPropertyAttribute.h
//  ZTNetworking
//
//  Created by 黄露 on 2017/10/19.
//  Copyright © 2017年 huanglu. All rights reserved.
//

#import <Foundation/Foundation.h>

enum kCustomizationTypes {
    kNotInspected = 0,
    kCustom,
    kNo
};

typedef enum kCustomizationTypes PropertyGetterType;

@interface ZTMPropertyAttribute : NSObject

/** The name of the declared property (not the ivar name) */
@property (copy, nonatomic) NSString* name;

/** A property class type  */
@property (assign, nonatomic) Class type;

/** Struct name if a struct */
@property (strong, nonatomic) NSString* structName;

/** The name of the protocol the property conforms to (or nil) */
@property (copy, nonatomic) NSString* protocol;

/** If YES, it can be missing in the input data, and the input would be still valid */
@property (assign, nonatomic) BOOL isOptional;

/** If YES - create a mutable object for the value of the property */
@property (assign, nonatomic) BOOL isMutable;

/** If YES - create models on demand for the array members */
@property (assign, nonatomic) BOOL convertsOnDemand;

/** If YES - the value of this property determines equality to other models */
@property (assign, nonatomic) BOOL isIndex;

/** The status of property getter introspection in a model */
@property (assign, nonatomic) PropertyGetterType getterType;

/** a custom getter for this property, found in the owning model */
@property (assign, nonatomic) SEL customGetter;

/** custom setters for this property, found in the owning model */
@property (strong, nonatomic) NSMutableDictionary *customSetters;


@end
