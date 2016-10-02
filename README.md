![Icon](https://github.com/teressaeid/Butler/blob/master/Icon/Icon.png) 
# Bulter

## Installation

This project uses [CocoaPods][1] to manage 3rd party libraries

```
$ pod install
```
```
$ open Butler.xcworkspace
```

## Sample Use
Users create tasks, assign them to location and a tracking radius. They then get notified whenever they are neabrby any of their pinned items.

## Extensions
I created a ```UIColor``` extension to allow me to use hex values when creating a UIColor.


## Design
Fir this app, I used a [Circle Menu][2] to animate the user selection on the first screen, while creating a task.

I used custom colors throught the app. 

I created user notifcation actions such as "Mute location" and "View on map".

This app uses Core Data to store the infromation.


##Work in progress

- [x] Allow users search for a location
- [x] Allow users long press map to add a location and reverse geocode
- [x] Custom Notification Actions
- [x] Custom Notifcation Sound
- [ ] Set Task Priority

[1]: http://www.cocoapods.org
[2]: https://github.com/Ramotion/circle-menu/

