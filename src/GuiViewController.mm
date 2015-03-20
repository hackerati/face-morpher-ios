//
//  GuiViewController.cpp
//  TerryFaceSubstitution
//
//  Created by Terry Bu on 3/6/15.
//
//

#include "GuiViewController.h"
#include "ofxiOSExtras.h"
#include <AVFoundation/AVFoundation.h>

@interface GuiViewController ()

@property (assign) SystemSoundID sound;
@property (nonatomic, strong) NSDictionary *tempDict;
@property (nonatomic, strong) NSCache *tempCache; 

@end

@implementation GuiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    main_queue = dispatch_get_main_queue();
    sub_queue = dispatch_queue_create("imageProcessing", 0);
    
    myApp = (ofApp *)ofGetAppPtr();
    
    [self hideAllButton];
    [self.retryButton.imageView setTintColor:[UIColor whiteColor]];
    [self.saveButton.imageView setTintColor:[UIColor whiteColor]];
    
    usePhotoLibrary = NO;
    self.tempCache = [[NSCache alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - touch event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if(myApp->myScene == ready){
        myApp->myScene = openCamera;
        [self openCamera];
    }
}


#pragma mark - UIImagePickerControllerDelegate

- (void)openCamera{
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
        
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
        
        [imagePickerController setAllowsEditing:NO];
        [imagePickerController setDelegate:self];
        [imagePickerController setEditing:NO];
        
        [self presentViewController:imagePickerController animated:YES completion:nil];
        
        
    }
    else{
        
        NSLog(@"camera invalid");
        
    }
    
}


- (IBAction) usePhotosButton:(id)sender {
    [self openPhotoLibrary];
}

- (void)openPhotoLibrary{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [imagePickerController setAllowsEditing:NO];
        [imagePickerController setDelegate:self];
        
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
    else{
        NSLog(@"photo library invalid");
    }
    usePhotoLibrary = YES;
}






- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self dismissViewControllerAnimated:YES completion:^{
        [SVProgressHUD show];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(main_queue, ^{
                pickedImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
                self.tempDict = @{ @"info" : [info objectForKey:UIImagePickerControllerOriginalImage] };
                [self getMaskedImage];
                [self showAllButton];
                [SVProgressHUD dismiss];
                if(!myApp->cloneReady){
                    [self showNotDetectedLabel];
                }
            });
        });
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    self.imageView.image = nil;
    [self hideAllButton];
    self.usePhotosButton.hidden = NO;
    
    myApp->myScene = ready;
    
}

UIImage * UIImageFromOFImage( ofImage & img ){
    int width = img.width;
    int height =img.height;
    
    int nrOfColorComponents = 1;
    
    if (img.type == OF_IMAGE_GRAYSCALE) nrOfColorComponents = 1;
    else if (img.type == OF_IMAGE_COLOR) nrOfColorComponents = 3;
    else if (img.type == OF_IMAGE_COLOR_ALPHA) nrOfColorComponents = 4;
    
    int bitsPerColorComponent = 8;
    int rawImageDataLength = width * height * nrOfColorComponents;
    BOOL interpolateAndSmoothPixels = NO;
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGDataProviderRef dataProviderRef;
    CGColorSpaceRef colorSpaceRef;
    CGImageRef imageRef;
    GLubyte *rawImageDataBuffer = img.getPixels();
    dataProviderRef = CGDataProviderCreateWithData(NULL, rawImageDataBuffer, rawImageDataLength, nil);
    colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    imageRef = CGImageCreate(width, height, bitsPerColorComponent, bitsPerColorComponent * nrOfColorComponents, width * nrOfColorComponents, colorSpaceRef, bitmapInfo, dataProviderRef, NULL, interpolateAndSmoothPixels, renderingIntent);
    UIImage * uimg = [UIImage imageWithCGImage:imageRef];
    return uimg;
    
}

#pragma mark - utility

- (void)getMaskedImage{
    
    ofxiOSUIImageToOFImage(pickedImage, img);
    
    if(!usePhotoLibrary)
        img.rotate90(45);
    myApp->maskTakenPhoto(img);
    
    maskedImage = [UIImage imageWithCGImage:UIImageFromOFImage(myApp->maskedImage).CGImage];
    self.imageView.image = maskedImage;
    [self.tempCache setObject:maskedImage forKey:[NSString stringWithFormat:@"%u", self.faceSelectionControl]];
    
    myApp->myScene = preview;
    
    [self playBeepSound];
}

- (IBAction)retry:(id)sender {
    self.tempCache = [[NSCache alloc]init];
    [self openCamera];
}

- (IBAction)save:(id)sender {
    
    UIImageWriteToSavedPhotosAlbum(maskedImage, self, @selector(finishSaving:didFinishSavingWithError:contextInfo:), nil);
    
}

- (void)finishSaving:(UIImage *)_image didFinishSavingWithError:(NSError*)_error contextInfo:(void *)_contextinfo{
    
    if(_error){
        NSLog(@"error logging: %@", _error);
        self.savedLabel.text = @"error: saving failed";
        
    }
    else{
        self.savedLabel.text = @"Saved to Photos Album succeeded";
        [self playBeepSound];
    }
    
    [[self.savedLabel layer]setCornerRadius:8.0];
    [self.savedLabel setClipsToBounds:YES];
    
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    [[self.savedLabel layer]addAnimation:animation forKey:nil];
    
    self.savedLabel.hidden = NO;
    NSTimer *tm = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(hideSavedLabel:) userInfo:nil repeats:NO];
}

- (void) playBeepSound {
    NSString *pewPewPath = [[NSBundle mainBundle]
                            pathForResource:@"beep-hightone" ofType:@"aif"];
    NSURL *pewPewURL = [NSURL fileURLWithPath:pewPewPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)pewPewURL, &_sound);
    AudioServicesPlaySystemSound(self.sound);
}

- (void)hideSavedLabel:(NSTimer*)timer{
    
    self.savedLabel.hidden = YES;
    
}

- (void)showNotDetectedLabel{
    self.savedLabel.text = @"Please Try Again...";
    
    [[self.savedLabel layer]setCornerRadius:8.0];
    [self.savedLabel setClipsToBounds:YES];
    
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    [[self.savedLabel layer]addAnimation:animation forKey:nil];
    
    self.savedLabel.hidden = NO;
    NSTimer *tm = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(hideSavedLabel:) userInfo:nil repeats:NO];
}



- (void)hideAllButton{
    self.retryButton.hidden     = YES;
    self.saveButton.hidden      = YES;
    self.savedLabel.hidden      = YES;
    self.segControl.hidden = YES;
    self.usePhotosButton.hidden = YES;
}

- (void)showAllButton{
    self.retryButton.hidden = NO;
    self.saveButton.hidden = NO;
    self.segControl.hidden = NO;
    self.usePhotosButton.hidden = NO;
}


- (IBAction) segmentSwitch: (id) sender {
    [SVProgressHUD show];
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    if (selectedSegment == 0) {
        //Beard
        self.faceSelectionControl = BeardImage;
    }
    else if (selectedSegment == 1){
        //Woman
        self.faceSelectionControl = WomanImage;
    }
    else if (selectedSegment == 2) {
        //Avatar
        self.faceSelectionControl = AvatarImage;
    }
    [self showImageWithCurrentSelection];
}

- (void)showImageWithCurrentSelection {
    UIImage *image =[self.tempCache objectForKey:[NSString stringWithFormat:@"%u", self.faceSelectionControl]];
    if (image) {
        self.imageView.image = image;
        [SVProgressHUD dismiss];
    }
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // time-consuming task
            pickedImage = (UIImage *) [self.tempDict objectForKey:@"info"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getMaskedImage];
                [SVProgressHUD dismiss];
            });
        });
    }
}

@end
