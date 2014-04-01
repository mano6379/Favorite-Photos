//
//  ViewController.m
//  FavoritePhotos
//
//  Created by Marion Ano on 3/31/14.
//  Copyright (c) 2014 Marion Ano. All rights reserved.
// Flickr key: b16bc1003dbe73619e0bdb0b9177f255
//  secret: 4d95ad55f9fdbcb1

#import "ViewController.h"
#import "PhotoCustomViewCell.h"
#import "DetailViewController.h"

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UITabBarControllerDelegate, UISearchBarDelegate>

@property NSMutableArray *mainPhotoArray;
@property NSDictionary* flickrDictionary;
@property NSDictionary* flickrPhotoDictionary; 
@property (strong, nonatomic) IBOutlet UISearchBar *mySearchBar;
@property (strong, nonatomic) IBOutlet UICollectionView *myCollectionView;

@property NSString* tags;
@end

@implementation ViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.tabBarController.delegate = self;
    self.mySearchBar.delegate = self;
    
    self.tags = @"surf";
    self.mainPhotoArray = [NSMutableArray new];
    [self searchPhotos];
    
}

#pragma mark -- UICollectionView Delegate Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.mainPhotoArray.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

#pragma mark -- helper method
//helper method here to search for photos using tags:
-(void)searchPhotos
{
    //store incoming data into a string
    NSString *getPhotos = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=b16bc1003dbe73619e0bdb0b9177f255&tags=%@&sort=relevance&safe_search=1&per_page=10&format=json&nojsoncallback=1", self.tags];
    
    //NSLog(@"%@",getPhotos);
    //An NSURL object represents a URL that can potentially contain the location of a resource on a remote server, the path of a local file on disk, or even an arbitrary piece of encoded data.
    
    NSURL *url = [NSURL URLWithString:getPhotos];
    
    //NSURLRequest objects represent a URL load request
    NSURLRequest *flickrURLRequest = [NSURLRequest requestWithURL:url];
    
    //this is setting the spinner on in the nav bar
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    //An NSURLConnection object lets you load the contents of a URL by providing a URL request object.
    [NSURLConnection sendAsynchronousRequest:flickrURLRequest queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         NSLog(@"block executing");
         //create a dictionary from the JSON String
         self.flickrDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
         NSLog(@"%@", self.flickrDictionary);
         //create a second dictionary to get us into the "photos"
         self.flickrPhotoDictionary = self.flickrDictionary[@"photos"];
         
         //create an array which is filled with dictionary objects
         
         
         //         NSLog(@"first dictionary count: %lu", (unsigned long)self.flickrDictionary.count);
         //         NSLog(@"second dictionary count: %lu", (unsigned long)self.flickrPhotoDictionary.count);
         //         NSLog(@"array count: %lu", (unsigned long)gettingPhotosFromPhotosDictionary.count);
         
         //need to clear out what was previously in the array before adding new "searched" images back into the mutable array
         //[self.mainPhotoArray removeAllObjects];
         NSArray *gettingPhotosFromPhotosDictionary = self.flickrPhotoDictionary[@"photo"];
         //loop through each item in the NSDictionary in the array of dictionaries and then please do the following code in the curlies {}
         for (NSDictionary *items in  gettingPhotosFromPhotosDictionary)
         {
             //this string gets you the address where each photo lives. Note: farm, server, id, and secret are all dictionaries in the array
             NSString *photoURL = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@.jpg", items[@"farm"], items[@"server"], items[@"id"], items[@"secret"]];
             
             
             //object conversion. Work backwards: What can I create an image from? What do I have? and how do I get to UIImage object? They key is: What do I want and how do I get back to it.
             NSLog(@"%@", photoURL);
             NSURL* url = [NSURL URLWithString:photoURL];
             NSData* data = [NSData dataWithContentsOfURL:url];
             UIImage* image = [UIImage imageWithData:data];
             
             //now I have an array with image objects
             [self.mainPhotoArray addObject:image];
             
             //NSLog(@"data is being added to mutable array");
             
         }
         //NSLog(@"%lu", (unsigned long)self.myMutableArray.count);
         //remember that the view needs to reload in the block
         [self.myCollectionView reloadData];
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
     }];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCustomViewCell *photoCell =
    [self.myCollectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCollectionCellID" forIndexPath:indexPath];
    
    UIImage *flickrImage = [self.mainPhotoArray objectAtIndex:indexPath.row];
    photoCell.imageView.image = flickrImage;
    
    NSLog(@"make cell");
    
    return photoCell;
}

//the selected photo gets sent to the destination viewcontroller
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(PhotoCustomViewCell*)sender
{
    DetailViewController *viewController = segue.destinationViewController;
    NSIndexPath *indexPath = [self.myCollectionView indexPathForCell:sender];
    //NSDictionary *specificPhoto = [self.mainPhotoArray objectAtIndex:indexPath.row];
    viewController.myImageView = sender.imageView.image;
}

#pragma mark -- UISearchBar Delegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (![searchBar.text isEqualToString:@""]) {
        [self userSearch:searchBar.text];
        [self.mySearchBar endEditing:YES];
    }
}

-(void)userSearch:(NSString*)text
{
    NSString *getPhotos = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=b16bc1003dbe73619e0bdb0b9177f255&tags=%@&sort=relevance&safe_search=1&per_page=10&format=json&nojsoncallback=1", text];
    
    //NSLog(@"%@",getPhotos);
    
    NSURL *url = [NSURL URLWithString:getPhotos];
    
    //NSURLRequest objects represent a URL load request
    NSURLRequest *flickrURLRequest = [NSURLRequest requestWithURL:url];
    
    //this is setting the spinner on in the nav bar
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    //An NSURLConnection object lets you load the contents of a URL by providing a URL request object.
    [NSURLConnection sendAsynchronousRequest:flickrURLRequest queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         NSLog(@"block executing");
         //create a dictionary from the JSON String
         self.flickrDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
         NSLog(@"%@", self.flickrDictionary);
         //create a second dictionary to get us into the "photos"
         self.flickrPhotoDictionary = self.flickrDictionary[@"photos"];

         //         NSLog(@"first dictionary count: %lu", (unsigned long)self.flickrDictionary.count);
         //         NSLog(@"second dictionary count: %lu", (unsigned long)self.flickrPhotoDictionary.count);
         //         NSLog(@"array count: %lu", (unsigned long)gettingPhotosFromPhotosDictionary.count);
         
         //[self.mainPhotoArray removeAllObjects];
         NSArray *gettingPhotosFromPhotosDictionary = self.flickrPhotoDictionary[@"photo"];
        
         for (NSDictionary *items in  gettingPhotosFromPhotosDictionary)
         {
             
             NSString *photoURL = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@.jpg", items[@"farm"], items[@"server"], items[@"id"], items[@"secret"]];
             
             
             NSLog(@"%@", photoURL);
             NSURL* url = [NSURL URLWithString:photoURL];
             NSData* data = [NSData dataWithContentsOfURL:url];
             UIImage* image = [UIImage imageWithData:data];
             
             //now I have an array with image objects
             [self.mainPhotoArray addObject:image];
             
             //NSLog(@"data is being added to mutable array");
             
         }
         //NSLog(@"%lu", (unsigned long)self.myMutableArray.count);
         //remember that the view needs to reload in the block
         [self.myCollectionView reloadData];
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
     }];

}


    
#pragma mark -- UITabBarController Delegate 

//- (void) tabBarController: (UITabBarController *) tabBarController didSelectViewController: (UIViewController *) viewController
//{
//    if (tabBarController.selectedIndex == 0)
//    {
//        self.tags = @"";
//        
//    }
//    
//    else if (tabBarController.selectedIndex == 1)
//    {
//        self.tags = self.mySearchBar.text;
//        [self userSearch:self.tags];
//        NSLog(@"selected 1 %d",tabBarController.selectedIndex);
//    }
//}

//-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
//{
//    if (viewController == ) {
//        <#statements#>
//    }
//}
//    
@end
