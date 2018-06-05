#import "Cocoa/Cocoa.h"
#import "CoreImage/CoreImage.h"


NSArray *detectQRCode(CIImage *image)
{
    NSDictionary *options;
    
    CIContext * context = [CIContext context];
    options = @{CIDetectorAccuracy: CIDetectorAccuracyHigh};
    CIDetector *qrDetector = [CIDetector detectorOfType: CIDetectorTypeQRCode
				       context: context
				       options: options];
    if([[image properties] valueForKey: (NSString *)kCGImagePropertyOrientation] == nil){
	options = @{CIDetectorImageOrientation: @1};
    }else{
	options = @{CIDetectorImageOrientation: [[image properties] valueForKey: (NSString *)kCGImagePropertyOrientation]};
    }

    NSArray *features = [qrDetector featuresInImage: image options: options];

    return features;
}


int main(int argc, char *argv[])
{
    @autoreleasepool{
	NSFileHandle *inputFileHandle = [NSFileHandle fileHandleWithStandardInput];
	NSFileHandle *outputFileHandle = [NSFileHandle fileHandleWithStandardOutput];
	NSData *data = [inputFileHandle readDataToEndOfFile];
	NSData *message;

	CIImage *image = [CIImage imageWithData: data];
	if(!image)
	    return 1;

	NSArray *features = detectQRCode(image);
	if(!features)
	    return 1;

	if(features.count > 0){
	    for(CIQRCodeFeature *qrFeature in features){
		// Japanese text in QR must be in Shift_JIS
		message = [qrFeature.messageString dataUsingEncoding: NSShiftJISStringEncoding];
		[outputFileHandle writeData: message];
	    }
	}

	return 0;
    }
}
