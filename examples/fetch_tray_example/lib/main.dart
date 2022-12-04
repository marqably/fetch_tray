import 'package:fetch_tray/fetch_tray.dart';
import 'package:fetch_tray_example/data/hooks/use_fetch_apis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends HookWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final fetchApisHook = useFetchApis(
      requestDebugLevel: FetchTrayDebugLevel.everything,
    );

    if (fetchApisHook.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (fetchApisHook.data != null) {
      return Scaffold(
        body: ListView.builder(
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                Clipboard.setData(
                  ClipboardData(text: fetchApisHook.data![index].link),
                ).then(
                  (value) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Copied url of ${fetchApisHook.data![index].title} to clipboard.'),
                    ),
                  ),
                );
              },
              title: Text('${fetchApisHook.data![index].title}'),
            );
          },
        ),
      );
    }
    if (fetchApisHook.error != null) {
      return const Scaffold(
        body: Center(
          child: Text('Error'),
        ),
      );
    }
    return const Scaffold(
      body: Center(
        child: Text('Something went wrong.'),
      ),
    );
  }
}
