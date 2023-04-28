import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formstack/formstack.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.blue, backgroundColor: Colors.white),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false);
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ListTile(
                  trailing: const Icon(Icons.arrow_forward_ios_outlined),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoadFromObjectScreen(),
                        ));
                  },
                  title: const Text("Load Form using Object"),
                  subtitle:
                      const Text("Render UI by constructing dart objects"),
                ),
                ListTile(
                  trailing: const Icon(Icons.arrow_forward_ios_outlined),
                  onTap: () async {
                    FormStack.clearForms();
                    await FormStack.api().loadFromAssets(
                        ['assets/app.json', 'assets/full.json']);
                    FormStack.api().addCompletionCallback(
                      GenericIdentifier(id: "IS_COMPLETED"),
                      formName: "login_form",
                      onFinish: (p0) {
                        debugPrint("$p0");
                      },
                      onBeforeFinishCallback: (result) async {
                        FormStack.api().setError(
                            GenericIdentifier(id: "email"), "Invalid email,",
                            formName: "login_form");
                        FormStack.api()
                            .setResult(result, formName: "login_form");
                        return Future.value(false);
                      },
                    );
                    FormStack.api().setResult({"email": "sudhi.s@live.com"},
                        formName: "login_form");
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoadFromJSONScreen(),
                        ));
                  },
                  title: const Text("Load Form Json File"),
                  subtitle: const Text("Render UI by loading from json file"),
                )
              ]),
        ),
      ),
    );
  }
}

class LoadFromObjectScreen extends StatelessWidget {
  const LoadFromObjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FormStack.api().form(steps: [
      InstructionStep(
          id: GenericIdentifier(id: "IS_STARTED"),
          title: "Example Survey",
          text: "Simple survey example using dart model",
          cancellable: false),
      QuestionStep(
        title: "Name",
        text: "Your name",
        inputType: InputType.name,
        id: GenericIdentifier(id: "NAME"),
      ),
      QuestionStep(
        title: "Your Email ?",
        text: "Tell Email address",
        inputType: InputType.email,
        id: GenericIdentifier(id: "EMAIL"),
      ),
      QuestionStep(
        title: "Phone Number",
        text: "Share your phone number.",
        inputType: InputType.number,
        id: GenericIdentifier(id: "NUM"),
      ),
      QuestionStep(
        title: "Comment",
        text:
            "Tell us about your self and why you want our help to imprve your health.",
        inputType: InputType.text,
        numberOfLines: 5,
        id: GenericIdentifier(id: "COMMENT"),
      ),
      QuestionStep(
        title: "Multiple Choice",
        text:
            "Tell us about your self and why you want our help to imprve your health.",
        inputType: InputType.multipleChoice,
        options: [
          Options("IN", "India"),
          Options("CH", "China"),
          Options("AM", "America"),
          Options("SR", "Sreelanka")
        ],
        id: GenericIdentifier(id: "MULTIPLE_CHOICE"),
      ),
      QuestionStep(
        title: "Single Choice",
        text:
            "Tell us about your self and why you want our help to imprve your health.",
        inputType: InputType.singleChoice,
        options: [
          Options("IN", "India"),
          Options("CH", "China"),
          Options("AM", "America"),
          Options("SR", "Sreelanka")
        ],
        id: GenericIdentifier(id: "SINGLE_CHOICE"),
      ),
      QuestionStep(
        title: "Time Only",
        text:
            "Tell us about your self and why you want our help to imprve your health.",
        inputType: InputType.time,
        id: GenericIdentifier(id: "TIME_ONLY"),
      ),
      QuestionStep(
        title: "Date Of Birth",
        text:
            "Tell us about your self and why you want our help to imprve your health.",
        inputType: InputType.dateTime,
        id: GenericIdentifier(id: "DATE_TIME"),
      ),
      QuestionStep(
        title: "Are you happy",
        text:
            "Tell us about your self and why you want our help to imprve your health.",
        inputType: InputType.smile,
        id: GenericIdentifier(id: "IS_HAPPY"),
      ),
      QuestionStep(
        title: "Date Of Birth",
        text:
            "Tell us about your self and why you want our help to imprve your health.",
        inputType: InputType.date,
        id: GenericIdentifier(id: "DOB"),
      ),
      CompletionStep(
        id: GenericIdentifier(id: "IS_COMPLETED"),
        title: "Survey Completed",
        text: "ENd Of ",
        onFinish: (result) {
          debugPrint("Completed With Result : $result");
        },
      ),
    ]);
    return Scaffold(
      body: FormStack.api().render(),
    );
  }
}

class LoadFromJSONScreen extends StatelessWidget {
  const LoadFromJSONScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FormStack.api().render(),
    );
  }
}
