//
//  RouteDetailViewController.m
//  NGTMap
//
//  Created by Bromot Alexey on 16.10.13.
//  Copyright (c) 2013 Alexey Bromot. All rights reserved.
//

#import "RouteDetailViewController.h"
#import "Track.h"
#import "TracksManager.h"
#import "TransportUnitsManager.h"
#import "FavoritesManager.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface RouteDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *routeTypeImageView;
@property (weak, nonatomic) IBOutlet UILabel *routeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeStopBeginLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeStopEndLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UILabel *numberOfRoutesLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) NSDictionary *routeTypeImageNames;

@property (strong, nonatomic) NSArray *transportUnits;
@property (strong, nonatomic) Track *track;

- (IBAction)favouriteAction:(id)sender;
- (IBAction)showMapAction:(id)sender;


@end

@implementation RouteDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.routeTypeImageNames = @{[NSNumber numberWithInteger:BusRouteType]: @"routes_bus_icon.png", [NSNumber numberWithInteger:TrolleyBusRouteType]: @"routes_trolleybus_icon.png", [NSNumber numberWithInteger:TramRouteType]: @"routes_trambus_icon.png", [NSNumber numberWithInteger:MicroBusRouteType]: @"routes_microbus_icon.png"};
    
    NSArray *routesArray = @[_route.identifier];
    
    [[TransportUnitsManager sharedManager] getTransportUnitsByRoutes:routesArray successHandler:^(NSArray *transportUnits) {
        NSPredicate *filterOnlinePredictate = [NSPredicate predicateWithFormat:@"offlineStatus == %d", OnlineTransportUnitWorkStatus];
        _transportUnits = [transportUnits filteredArrayUsingPredicate:filterOnlinePredictate];
        _numberOfRoutesLabel.text = [NSString stringWithFormat:@"%d", _transportUnits.count];
    } failHandler:^(NSError *error) {
        
    }];
    
    [[TracksManager sharedManager] getTracksByRoutes:routesArray successHandler:^(NSArray *tracks) {
        _track = routesArray[0];
    } failHandler:^(NSError *error) {
        
    }];
    
    [self.mapView setRegion:NOVOSIBIRSK_COORDINATES_REGION];
    
    MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    annot.title = @"Title";
    annot.coordinate = CLLocationCoordinate2DMake(NOVOSIVIRSK_DEFAULT_LATITUDE, NOVOSIVIRSK_DEFAULT_LONGITUDE);
    [self.mapView addAnnotation:annot];
	
    [self updateData];
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self isMovingFromParentViewController]) {
        [[TracksManager sharedManager] cancelGetTracks];
        [[TransportUnitsManager sharedManager] cancelGetTransportUnits];
    }
}

- (void)updateData {
    NSString *imageTypeName = [_routeTypeImageNames objectForKey:_route.type];
    self.routeTypeImageView.image = [UIImage imageNamed:imageTypeName];
    
    self.routeTitleLabel.text = _route.title;
    self.routeStopBeginLabel.text = _route.stopBegin;
    self.routeStopEndLabel.text = _route.stopEnd;
    
    [self updateFavouiritesButton];
}

#pragma mark - Actions

- (IBAction)favouriteAction:(id)sender {
    if ([[FavoritesManager sharedManager] isFavoriteRoute:_route]) {
        [[FavoritesManager sharedManager] removeRoute:_route];
    } else {
        [[FavoritesManager sharedManager] addRoute:_route];
    }
    
    [self updateFavouiritesButton];
}

- (IBAction)showMapAction:(id)sender {
}


#pragma mark - Private methods

- (void)updateFavouiritesButton {
    NSString *favoriteButtonTitle = [[FavoritesManager sharedManager] isFavoriteRoute:_route] ? @"Удалить" : @"В избранное";
    [_favoriteButton setTitle:favoriteButtonTitle forState:UIControlStateNormal];
}

@end
