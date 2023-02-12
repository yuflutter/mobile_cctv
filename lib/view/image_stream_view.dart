import 'package:flutter/material.dart';

import '/core/states.dart';
import '/data/image_dto.dart';
import '/view/image_view.dart';

class ImageStreamView extends StatelessWidget {
  final Stream<ImageDto> imageStream;
  final Widget placeholder;

  const ImageStreamView({super.key, required this.imageStream, this.placeholder = const Waiting()});

  @override
  build(context) {
    return StreamBuilder<ImageDto>(
      stream: imageStream,
      builder: (context, snapshot) {
        return (snapshot.hasError)
            ? ErrorView(snapshot.error!)
            : (!snapshot.hasData)
                ? placeholder
                : ImageView(imageDto: snapshot.data!);
      },
    );
  }
}
