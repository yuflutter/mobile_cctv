import 'package:flutter/material.dart';

final themeData = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.brown,
);

class Void extends StatelessWidget {
  @override
  build(context) => SizedBox();
}

class Space1 extends StatelessWidget {
  @override
  build(context) => SizedBox(width: 5, height: 5);
}

class Space2 extends StatelessWidget {
  @override
  build(context) => SizedBox(width: 10, height: 10);
}

class Space3 extends StatelessWidget {
  @override
  build(context) => SizedBox(width: 15, height: 15);
}

class Space4 extends StatelessWidget {
  @override
  build(context) => SizedBox(width: 20, height: 20);
}

Size mediaSize(BuildContext context) => MediaQuery.of(context).size;

class Screen extends StatelessWidget {
  final Widget body;
  final bool noBackButton;

  const Screen({super.key, required this.body, this.noBackButton = false});

  @override
  build(context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: body,
        ),
      ),
      floatingActionButton: (!noBackButton)
          ? FloatingActionButton(
              onPressed: () => _back(context),
              mini: true,
              backgroundColor: Colors.brown,
              child: Icon(Icons.arrow_back),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
    );
  }

  void _back(context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
