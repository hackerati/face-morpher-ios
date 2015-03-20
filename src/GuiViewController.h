//
//  GuiViewController.h
//  TerryFaceSubstitution
//
//  Created by Terry Bu on 3/6/15.
//
//

#ifndef __TerryFaceSubstitution__GuiViewController__
#define __TerryFaceSubstitution__GuiViewController__

#include <stdio.h>

#endif /* defined(__TerryFaceSubstitution__GuiViewController__) */

#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"

#include "ofApp.h"


typedef enum : NSUInteger {
    BeardImage,
    WomanImage,
    AvatarImage,
} SubImageType;

@interface GuiViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    
    ofApp *myApp;
    
    UIImage *pickedImage;
    
    ofImage img;
    UIImage *maskedImage;
    dispatch_queue_t main_queue;
    dispatch_queue_t sub_queue;
    
    BOOL usePhotoLibrary;
    
}

- (void)openCamera;
- (void)openPhotoLibrary;
- (void)getMaskedImage;

- (IBAction)retry:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction) usePhotosButton: (id) sender;


- (void)hideAllButton;
- (void)showAllButton;

@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIButton *retryButton;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *savedLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (strong, nonatomic) IBOutlet UIButton *usePhotosButton;


@property SubImageType faceSelectionControl;

@end