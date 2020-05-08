# Aware

Aware is a menubar app for OSX and macOS that displays how long you've been actively using your computer.

![dark](https://cloud.githubusercontent.com/assets/896475/12149285/eee30008-b470-11e5-81e9-de7072a11827.png)
![light](https://cloud.githubusercontent.com/assets/896475/12149287/eeeac37e-b470-11e5-9bda-8a2502a39148.png)

## Installing the app

<img src="https://cloud.githubusercontent.com/assets/896475/19049990/9dd65572-897a-11e6-99a1-7b83db895cc7.png" width="256" height="256">

[View in Mac App Store](https://itunes.apple.com/us/app/aware/id1082170746?mt=12) or [download the latest release from GitHub](https://github.com/josh/Aware/releases/latest).

## Preferences

Change the time after which the app considers the user inactive. When the app goes inactive, the break reminder notifications will reset. Defaults to 2 minutes.
```
defaults write com.awaremac.Aware UserIdleSeconds 120
```

Change the session limit time. When the user is active for this amount of time, the apps sends a break reminder notification. Defaults to 30 minutes.
```
defaults write com.awaremac.Aware SessionLimitSeconds 1800
```

Change the time to snooze break reminders for. When clicking the "Snooze" button on a break reminder notification, the next break reminder is sent after this amount of time. Defaults to 5 minutes.
```
defaults write com.awaremac.Aware SnoozeDurationSeconds 300
```

## Development information

Requires Xcode 10.2

``` sh
$ git clone https://github.com/josh/Aware
$ cd Aware/
$ open Aware.xcodeproj/
```

## License

Copyright © 2016 Joshua Peek, Patrick Marsceill. All rights reserved.
