## [0.4.3] - 19/06/19

* added isOverlayBgTransparent optional parameter to allow overlay without a blocking background

## [0.4.2] - 16/05/19

* added hooks to hide and showing overlays (for analytics or what not)

## [0.4.1] - 15/05/19

* removed printing debug information by default
* added missing new parameters to createTutorialOverlayIfNotExists function

## [0.4.0] - 14/05/19

* added uuid package to distinguish between each overlay with same tag name
* added animation repeat functionality
* changed createTutorialOverlay() function to include animation related parameters

## [0.3.0] - 12/05/19
* BuildContext is now required when creating the overlay page instead of when showing it
* added animation support
* added default padding for all visible widgets
* api changes \
      - createTutorialOverlay requires a context\
      - showOverlayEntry required named parameters and does not require context parameter\
      - showOverlayEntry as a new optional parameter 
      redisplayOverlayIfSameTAgName if to redraw the overlay when requested to display an already displayed overlay 

## [0.2.0] - 08/05/19

* global keys that are null or not connected to a Widgets are silently 
ignored instead of throwing an exception
* detecting position and size change of widgets in order to redraw the overlay
* added synchronized package dependency to make sure showOverlayEntry is being
called synchronized. 

## [0.1.0] - 28/04/19

* included onTap event
* removed context parameter requirement from createTutorialOverlay()
* breaking changes to API - now uses WidgetData class 
                            instead of list of Global Keys.
* added more shapes - (formerly supported only Oval) now also supports 
                      Rect and RRect.
* added bgColor property to createTutorialOverlay() to allow changing
  default background color                                          

## [0.0.1] - 27/04/19

* Initial release
