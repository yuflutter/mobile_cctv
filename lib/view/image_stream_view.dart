import 'package:flutter/material.dart';

import '/core/states.dart';
import '/data/image_dto.dart';
import '/view/image_view.dart';

class ImageStreamView extends StatelessWidget {
  final Stream<ImageDto> imageStream;

  const ImageStreamView({super.key, required this.imageStream});

  @override
  build(context) {
    return StreamBuilder<ImageDto>(
      stream: imageStream,
      builder: (context, snapshot) {
        return (snapshot.hasError)
            ? ErrorView(snapshot.error!)
            : (!snapshot.hasData)
                ? Waiting()
                : ImageView(imageDto: snapshot.data!);
      },
    );
  }
}
