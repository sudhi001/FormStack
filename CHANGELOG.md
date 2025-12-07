## 1.1.0
- **Dependencies Updated**: Updated all dependencies to latest stable versions
  - `webview_flutter`: ^4.9.0 → ^4.13.0
  - `dio`: ^5.8.0+1 → ^5.9.0
  - `uuid`: ^4.5.1 → ^4.5.2
  - `lottie`: ^3.3.1 → ^3.3.2
  - `file_picker`: ^8.3.7 → ^10.3.7
  - `google_maps_flutter_web`: ^0.5.12+2 → ^0.5.14+3
  - `google_maps_flutter`: ^2.12.3 → ^2.14.0
  - `http`: ^1.4.0 → ^1.6.0
- **Performance & Memory Optimizations**:
  - Fixed memory leak in Google Places autocomplete stream subscription
  - Added cache size limit (50 items) to prevent unbounded memory growth
  - Optimized image memory usage by clearing file results after encoding
  - Fixed component disposal in nested step views
  - Optimized controller recreation to only occur when form step result changes
  - Reduced unnecessary setState calls in base step view
  - Added proper GoogleMapController disposal
  - Made Future.delayed cancellable with proper cleanup
  - Optimized Lottie widget caching in completion step view
  - Added lazy loading for background animations
- **Bug Fixes**:
  - Fixed undefined `mounted` property issue in completion step view
  - Fixed auto-trigger callback firing multiple times
  - Improved resource cleanup across all views

## 0.9.33
- Library updates
## 0.9.4
* Support Nested Step with  Or condition to mutiple component, "validationExpression":"{\"or\":[{\"id\":\"vpa\",\"expression\":\"IS_NOT_EMPTY\"},{\"id\":\"upiNumber\",\"expression\":\"IS_NOT_EMPTY\"}],\"orValidationMessage\":\"Please ente UPI ID or Number.\"}",
## 0.7.7
* Location Picker with Google Map
## 0.7.5
* HTML Editor added
## 0.7.4
* Dropdown buttom componenty style with minimum and basic.
* Dynamic key value componet widget added.
## 0.7.0
* Date format result will be utc format
## 0.6.4
* Added hoice fild with switch.
## 0.6.3
* Added OTP View support.
* Added  File input type  (single file selection).
## 0.6.1
* Disable Ui dynamically.
## 0.6.0
*  Able to set erro dynamically
*  Able to set data dynamically.
## 0.5.1
*  NestedQuestionStep -> Renamed to -> NestedStep
*  To Shoe nested step in single view
## 0.4.0
* NestedQuestionStep creted to display mutiple questions in single screen.
* Documents updated and code optimisation.
## 0.2.10
* Documents updated and code optimisation.
## 0.1.4
* Documents updated.
## 0.1.4
* Documents updated.

## 0.1.3
* Example application created and document updated.

## 0.1.1

* Focused on creating a ui based on the model.
