import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/abstract_model.dart';

class Waiting extends StatelessWidget {
  @override
  build(context) => Center(child: CircularProgressIndicator());
}

class ErrorView extends StatelessWidget {
  final Object error;

  const ErrorView(this.error, {super.key});

  @override
  build(context) {
    return SingleChildScrollView(
      child: SelectableText('$error', style: TextStyle(color: Colors.red)),
    );
  }
}

class ModelViewer<T extends AbstractModel> extends StatelessWidget {
  final Widget Function(BuildContext context, T model) builder;

  const ModelViewer({required this.builder});

  @override
  build(context) {
    final model = context.watch<T>();
    return (model.error != null)
        ? ErrorView(model.error!)
        : (model.waiting)
            ? Waiting()
            : builder(context, model);
  }
}
