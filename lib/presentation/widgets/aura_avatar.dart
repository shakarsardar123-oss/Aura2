import 'package:flutter/material.dart';

class AuraAvatar extends LeafRenderObjectWidget {
  const AuraAvatar({super.key});

  @override
  RenderBox createRenderObject(BuildContext context) {
    return RenderProxyBox();
  }

  @override
  void updateRenderObject(BuildContext context, RenderProxyBox renderObject) {}
}
