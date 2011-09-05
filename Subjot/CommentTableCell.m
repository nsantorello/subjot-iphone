//
//  CommentTableCell.m
//  Subjot
//
//  Created by Noah Santorello on 9/4/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "CommentTableCell.h"
#import "ImageCache.h"

@implementation CommentTableCell

@synthesize commentTextLabel, commentAuthorImage, publishedLabel, usernameLabel;

- (void)setComment:(Comment*)comment
{
    commentTextLabel.text = comment.text;
    publishedLabel.text = [comment.published description];
    usernameLabel.text = comment.author.username;
    commentAuthorImage.image = [ImageCache getImageByUrl:comment.author.profilePicUrl];
    [commentTextLabel sizeToFit];
}

- (void)dealloc
{
    commentTextLabel = publishedLabel = usernameLabel = nil;
    commentAuthorImage = nil;
    [super dealloc];
}

@end
