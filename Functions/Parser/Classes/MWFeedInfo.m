//
//  MWFeedInfo.m
//  MWFeedParser
//
//  Copyright (c) 2010 Michael Waterfall
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  1. The above copyright notice and this permission notice shall be included
//     in all copies or substantial portions of the Software.
//  
//  2. This Software cannot be used to archive or collect data such as (but not
//     limited to) that of events, news, experiences and activities, for the 
//     purpose of any concept relating to diary/journal keeping.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "MWFeedInfo.h"

#define EXCERPT(str, len) (([str length] > len) ? [[str substringToIndex:len-1] stringByAppendingString:@"…"] : str)

@implementation MWFeedInfo

@synthesize title, link, summary, url,language;

#pragma mark NSObject

- (NSString *)description {
	NSMutableString *string = [[NSMutableString alloc] initWithString:@"MWFeedInfo: "];
	if (title)   [string appendFormat:@"“%@”", EXCERPT(title, 50)];
	//if (link)    [string appendFormat:@" (%@)", link];
    if (summary) [string appendFormat:@", %@", EXCERPT(summary, 50)];
    if (self.pubDate) {
        [string appendFormat:@"\n pubDate %@ ",EXCERPT([[self pubDate] description], 50)];
    }
    if (self.managingEditor) {
        [string appendFormat:@"\n %@ ",EXCERPT([[self managingEditor] description], 50)];
    }
    if (self.lastBuildDate) {
        [string appendFormat:@"\n lastBuildDate %@ ",EXCERPT([[self lastBuildDate] description], 50)];
    }
    if (self.icon) {
        [string appendFormat:@"\n icon %@ ",EXCERPT([[self icon] description], 50)];
    }
    if (self.copyright) {
        [string appendFormat:@"\n copyright %@ ",EXCERPT([[self copyright] description], 50)];
    }
    if (self.language) {
         [string appendFormat:@"\n language %@ ",EXCERPT([[self language] description], 50)];
    }
    if (self.generator) {
         [string appendFormat:@"\n generator %@ ",EXCERPT([[self generator] description], 50)];
    }
	return string;
}


#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
	if ((self = [super init])) {
		title = [decoder decodeObjectForKey:@"title"];
		link = [decoder decodeObjectForKey:@"link"];
		summary = [decoder decodeObjectForKey:@"summary"];
		url = [decoder decodeObjectForKey:@"url"];
        language = [decoder decodeObjectForKey:@"language"];
        self.pubDate = [decoder decodeObjectForKey:@"pubDate"];
        self.managingEditor = [decoder decodeObjectForKey:@"managingEditor"];
        self.ttl = [decoder decodeObjectForKey:@"ttl"];
        self.lastBuildDate = [decoder decodeObjectForKey:@"lastBuildDate"];
        self.copyright = [decoder decodeObjectForKey:@"copyright"];
        self.icon = [decoder decodeObjectForKey:@"icon"];
        self.generator = [decoder decodeObjectForKey:@"generator"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	if (title) [encoder encodeObject:title forKey:@"title"];
	if (link) [encoder encodeObject:link forKey:@"link"];
	if (summary) [encoder encodeObject:summary forKey:@"summary"];
	if (url) [encoder encodeObject:url forKey:@"url"];
    if (language) [encoder encodeObject:language forKey:@"language"];
    if (self.pubDate) {
        [encoder encodeObject:self.pubDate forKey:@"pubDate"];
    }
    if (self.managingEditor) {
        [encoder encodeObject:self.managingEditor forKey:@"managingEditor"];
    }
    if (self.ttl) {
        [encoder encodeObject:self.ttl forKey:@"ttl"];
    }
    if (self.lastBuildDate) {
        [encoder encodeObject:self.lastBuildDate forKey:@"lastBuildDate"];
    }
    if (self.copyright) {
        [encoder encodeObject:self.copyright forKey:@"copyright"];
    }
    if (self.icon) {
        [encoder encodeObject:self.icon forKey:@"icon"];
    }
    if (self.generator) {
        [encoder encodeObject:self.generator forKey:@"generator"];
    }
}

@end
