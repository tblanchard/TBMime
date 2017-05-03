// ETStringEncodingProtocol.h
//
// Author: ab
//
// CVS Info: $Id: ETStringEncodingProtocol.h,v 1.1 2000/06/23 16:44:25 abrouwer Exp $ 
//
// Copyright (c) 1996-1999 Annard Brouwer. All rights reserved.
// Read the "License" file included in the distribution to find out what you can do with this code.

#import <Foundation/Foundation.h>

@protocol ETStringEncodingProtocol
// This protocol is used for encoding contents of objects in a property
// list, preserving special characters and omitting pretty print features
// (compared to for example NSDictionary's #description implementation).
//
// An object which wants to implement this protocol needs to stringify its
// contents using the concept of a property list.

- (NSString *)stringEncoding;
  // Returns a string describing the contents of the receiver.

@end
