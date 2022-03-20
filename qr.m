#include <unistd.h>
#include <stdlib.h>
#import <Cocoa/Cocoa.h>
#import <CoreImage/CoreImage.h>

#define DEF_SCALE	16.0

// switch hack
#define CASE(str) if ([__s__ isEqualToString:(str)])
#define SWITCH(s) for (NSString *__s__ = (s); __s__; __s__ = nil)
#define DEFAULT

NSBitmapImageFileType fileTypeFromFilename(const NSString *filename)
{
    NSBitmapImageFileType ret;
    if(!filename){
	ret = NSBitmapImageFileTypePNG;
    }else{
	NSString *extension = [[filename pathExtension] lowercaseString];
	if(extension){
	    SWITCH(extension){
		CASE(@"png"){
		    ret = NSBitmapImageFileTypePNG;
		    break;
		}
		CASE(@"gif"){
		    ret = NSBitmapImageFileTypeGIF;
		    break;
		}
		CASE(@"bmp"){
		    ret = NSBitmapImageFileTypeBMP;
		    break;
		}
		CASE(@"jpeg"){
		    ret = NSBitmapImageFileTypeJPEG;
		    break;
		}
		CASE(@"jpg"){
		    ret = NSBitmapImageFileTypeJPEG;
		    break;
		}
		DEFAULT{
		    ret = NSBitmapImageFileTypePNG;
		    break;
		}
	    }
	}else{
	    ret = NSBitmapImageFileTypePNG;
	}
    }
    return ret;
}


int main(int argc, char *argv[])
{
    char sw;
    NSFileHandle *msgFileHandle = nil;
    NSFileHandle *outputFileHandle = nil;
    NSFileManager *fileManager;
    NSString *correctionLevel = @"M";	// correction level's default is "M"
    CGFloat scale = DEF_SCALE;
    NSString *str = @"QRコードに変換される文字列";
    NSString *outputFileName = nil;

    @autoreleasepool{

	while((sw = getopt(argc, argv, "s:m:o:c:")) != -1){
	    switch(sw){
		case 's':
		    scale = atoi(optarg) * 1.0;
		    break;
		case 'm':
		    msgFileHandle = [NSFileHandle fileHandleForReadingAtPath: [NSString stringWithUTF8String: optarg]];	
		    if(msgFileHandle == nil)
			return 1;
		    break;
		case 'o':
		    outputFileName = [NSString stringWithUTF8String: optarg];
		    break;
		case 'c':
		    // inputCorrectionLevel must be one of "L", "M", "Q", "H"
		    correctionLevel = [NSString stringWithUTF8String: optarg];
		    break;
		default:
		    break;
	    }
	}
	argc -= optind;
	argv += optind;

	if(msgFileHandle == nil)
	    msgFileHandle = [NSFileHandle fileHandleWithStandardInput];

//	Text in Japanese must be Shift_JIS encoded.
//	NSData *strData = [str dataUsingEncoding: NSShiftJISStringEncoding];
	NSData *strData = [msgFileHandle readDataToEndOfFile];

	CIFilter *qrFilter = [ CIFilter filterWithName: @"CIQRCodeGenerator"];
	[qrFilter setValue: strData forKey: @"inputMessage"];
	[qrFilter setValue: correctionLevel forKey: @"inputCorrectionLevel"];

	CIImage *image = qrFilter.outputImage;
	CIImage *scaledImage = [image imageByApplyingTransform: CGAffineTransformMakeScale(scale, scale)];
	NSBitmapImageRep *bitmapRep = 
	        [[NSBitmapImageRep alloc] initWithCIImage: scaledImage];
	NSDictionary *prop = [[NSDictionary alloc] init];
	NSBitmapImageFileType filetype = fileTypeFromFilename(outputFileName);
	NSData *data = [bitmapRep representationUsingType: filetype 
	    properties: prop];
//	[prop autorelease];

	if(outputFileName == nil){
	    outputFileHandle = [NSFileHandle fileHandleWithStandardOutput];
	}else{
	    fileManager = [NSFileManager defaultManager];
	    if([fileManager createFileAtPath: outputFileName contents: nil attributes: nil])
		outputFileHandle = [NSFileHandle fileHandleForWritingAtPath: outputFileName];
	    else
		return 1;
	}
        NSError *err;
	if(![outputFileHandle writeData: data error: &err]){
            NSLog(@"Error: %@", err);
            return 1;
        }
	
//	[bitmapRep autorelease];
    }
    return 0;
}
