//
//  ImageCache.h
//  Meep_IOS
//
//  Created by Ryan Sharp on 6/14/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject
@property (nonatomic, retain) NSCache *imgCache;

#pragma mark - Methods

+ (ImageCache*)sharedImageCache;
- (void) AddImage:(NSString *)imageURL: (UIImage *)image;
- (UIImage*) GetImage:(NSString *)imageURL;
- (BOOL) DoesExist:(NSString *)imageURL;
@end
