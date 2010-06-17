//
//  ArtworkLoader.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-16.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ArtworkLoaderDelegate <NSObject>
@optional
- (void)loaderDidFinishLoadingArtwork:(NSData *)artworkData fromURL:(NSString *)url;
@end

@interface ArtworkLoader : NSOperation {
	NSString *url;
	id <ArtworkLoaderDelegate> delegate;
}

@property (nonatomic, retain) NSString *url;
@property (nonatomic, assign) id <ArtworkLoaderDelegate> delegate;

@end
