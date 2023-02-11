import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class ProviderInjector extends StatelessWidget {
  final List<SingleChildWidget> providers;
  final Widget Function(BuildContext) builder;

  const ProviderInjector({super.key, required this.providers, required this.builder});

  @override
  build(context) {
    return MultiProvider(
      providers: providers,
      child: Navigator(
        onGenerateRoute: (_) => MaterialPageRoute(builder: builder),
      ),
    );
  }
}
