
<p align="center">
<img src="https://i.ibb.co/vcszHt9/logo.png" alt="logo" border="0" width="300" height="300">
</p>

<h1 align="center"><b>FormStack</b></h1>
<p align="center">Comprehensive Library for Creating Dynamic Form</p>
<p align="center">
<a href="https://flutter.dev">
    <img src="https://img.shields.io/badge/Platform-Flutter-02569B?logo=flutter" alt="Platform">
  </a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://pub.dev/packages/formstack"><img src="https://img.shields.io/pub/v/formstack.svg" alt="FormStack Library version"></a>
<a href="https://pub.dev/publishers/nullsafety.com/packages"><img src="https://img.shields.io/pub/publisher/path.svg" alt="License: MIT"></a>

</p>

FormStack is a library designed to help developers create dynamic user interfaces in Flutter. Specifically, the library is focused on creating forms and surveys using a JSON or Dart language model.

The primary goal of FormStack is to make it easy for developers to create dynamic UIs without having to write a lot of code. By using a JSON or Dart model to define the structure of a form or survey, developers can quickly create UIs that are easy to customize and update.

While the library was initially created to help developers create survey UIs, the focus has expanded to include any type of dynamic application UI. With FormStack, developers can create UIs that are responsive and adaptable to different devices and screen sizes.

Overall, FormStack is a powerful tool for creating dynamic user interfaces in Flutter. It offers a flexible and customizable approach to UI design, allowing developers to create UIs that are easy to use and maintain.

## Online Demo

- [Demo Web Application](https://formstackexample-89ed3.web.app)

## Dart Versions

- Dart >=2.19.6 < 3.0.0

## Examples

- [Simple Example](https://github.com/sudhi001/FormStack/tree/main/example) - an example of how to create a UI using FormStack.

- [DEMO APPLICATION Example](https://github.com/sudhi001/formstack_example_one) - Load from from json file..



## Implementation 

### Follwoing JSON medel will render the above demo screen ui.
```json
{
    "default":
    {
      "backgroundAnimationFile":"assets/bg.json",
      "backgroundAlignment":"bottomCenter",
      "steps":[
        {
          "type": "QuestionStep",
          "title":"My Car",
          "cancellable":false,
          "titleIconAnimationFile":"assets/car.json",
          "nextButtonText":"",
          "autoTrigger":true,
          "inputType":"singleChoice",
          "options":[
             {"key":"CAR_SELECTED","title":"Select A Car"},
             {"key":"CALL_DRIVER","title":"Call Driver Now"}
          ],
          "id":"CHOICE",
          "relevantConditions":[{"id":"CALL_DRIVER","expression":"IN CALL_DRIVER"}]
        },{
          "type": "QuestionStep",
          "title":"Select Car",
          "titleIconAnimationFile":"assets/car.json",
          "nextButtonText":"",
          "autoTrigger":true,
          "inputType":"singleChoice",
          "options":[
             {"key":"AUDI","title":"Audi"},
             {"key":"BENZ","title":"Benz"},
             {"key":"Suzuki","title":"Suzuki"}
          ],
          "id":"CAR_SELECTED",
          "relevantConditions":[{"id":"SMILE","expression":"FOR_ALL"}]
        },{
          "type": "QuestionStep",
          "title":"Call / Ping Driver",
          "titleIconAnimationFile":"assets/car.json",
          "nextButtonText":"",
          "autoTrigger":true,
          "inputType":"singleChoice",
          "options":[
             {"key":"CALL","title":"Call"},
             {"key":"PING","title":"PING"}
          ],
          "id":"CALL_DRIVER"
        },
        {
         "type": "QuestionStep",
         "title":"Are you Happy",
         "text":"",
         "inputType":"smile",
         "id":"SMILE"
       },
        {
          "type": "CompletionStep",
          "autoTrigger":true,
          "nextButtonText":"",
          "title":"Please wait..",
          "id":"IS_COMPLETED"
        }
      ]
    
   }
}


```
### Load single json file from assets folder 
``` dart
     await FormStack.api() .loadFromAsset('assets/app.json');

```
### Load Mutiple json file from assets folder 
``` dart
     await FormStack.api()
                      .loadFromAssets(['assets/app.json', 'assets/full.json']);

```
### Read json file from assets to FormStack

```dart
await FormStack.api().buildFormFromJson(
        await json.decode(await rootBundle.loadString('assets/app.json')));

```

### Completion Call back 

Here you can implement your logic.
Example: if you want to trigger a network call or something like that.

```dart

    FormStack.api().addCompletionCallback(
      GenericIdentifier(id: "IS_COMPLETED"),
      onBeforeFinishCallback: (result) async {
        await Future.delayed(const Duration(seconds: 2));/// Replace this line and add your network logic
        return Future.value(true);
      },
      onFinish: (result) {
        debugPrint("Completed With Result : $result");
        FormConfig.setState?.call();
      },
    );
```

### Render Form in UI


```dart
 FormStack.api().render()

```

# Demo Application Video

[![FormStack Demo Application Video](https://i.ibb.co/M1zxp7k/image.jpg)](https://youtu.be/afFNWkhQbJk "FormStack Demo")

# Screenshots

<table>
   <tbody>
      <tr>
         <td align="center" style="background-color: white">
            <img src="https://i.ibb.co/ZzbVBJV/img1.png" alt="img1" border="0" width="450"/>
         </td>
         <td align="center" style="background-color: white">
            <img src="https://i.ibb.co/nPzjmZD/img2.png" alt="img2" border="0" width="450"/>
         </td>
      </tr>
        <tr>
         <td align="center" style="background-color: white">
            <img src="https://i.ibb.co/4W9ywqM/img3.png" alt="img3" border="0" width="450"/>
         </td>
          <td align="center" style="background-color: white">
            <img src="https://i.ibb.co/471ykX0/img4.png" alt="img4" border="0" width="450"/>
         </td>
      </tr>
      <tr>
         <td align="center" style="background-color: white">
            <img src="https://i.ibb.co/JzvGHy4/img5.png" alt="img5" border="0" width="450"/>
         </td>
         <td align="center" style="background-color: white">
            <img src="https://i.ibb.co/61DWvSh/img6.png" alt="img6" border="0" width="450">
         </td>
      </tr>
      <tr>
         <td align="center" style="background-color: white">
            <img src="https://i.ibb.co/0hPvSWD/img7.png" alt="img7" border="0" width="450">
         </td>
         <td align="center" style="background-color: white">
            <img src="https://i.ibb.co/jJd2nSp/img8.png" alt="img8" border="0" width="450">
         </td>
      </tr>
      <tr>
         <td align="center" style="background-color: white">
            <img src="https://i.ibb.co/7SrKKbM/img10.png" alt="img10" border="0" width="450">
         </td>
         <td align="center" style="background-color: white">
            <img src="https://i.ibb.co/0MVPjBT/img11.png" alt="img11" border="0" width="450">
         </td>
      </tr>
        <tr>
         <td align="center" style="background-color: white">
            <img src="https://i.ibb.co/wLRftP3/img9.png" alt="img9" border="0" width="450">
         </td>
      </tr>
   </tbody>
</table>

# Bugs or Requests

If you come across any difficulties, don't hesitate to open an [issue](https://github.com/sudhi001/FormStack/issues) on GitHub. If you believe that the library lacks a particular feature, please create a [ticket](https://github.com/sudhi001/FormStack/issues) on GitHub, and I'll investigate it. Additionally, I welcome pull requests if you would like to contribute to the project.

## Maintainers

- [Sudhi S](https://github.com/sudhi001)
