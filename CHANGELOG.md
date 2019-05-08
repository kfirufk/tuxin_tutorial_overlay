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
