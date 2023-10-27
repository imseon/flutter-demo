import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ElasticBox extends StatefulWidget {
  final double maxWidth;
  final Widget child;

  const ElasticBox({
    Key? key,
    required this.maxWidth,
    required this.child,
  }) : super(key: key);

  @override
  State<ElasticBox> createState() => _ElasticBoxState();
}

class _ElasticBoxState extends State<ElasticBox> {
  double? _width;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(0),
      ),
      child: _ElasticBox(
        maxWidth: widget.maxWidth,
        child: widget.child,
      ),
    );
  }
}

class _ElasticBox extends SingleChildRenderObjectWidget {
  final double maxWidth;

  const _ElasticBox({
    Key? key,
    required Widget child,
    this.maxWidth = double.infinity,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderCustomBox(widget: this);
  }
}

class _RenderCustomBox extends RenderShiftedBox {
  final _ElasticBox widget;
  double _childWidth = 0;

  _RenderCustomBox({RenderBox? child, required this.widget}) : super(child);

  @override
  void performLayout() {
    child!.layout(
      _childWidth >= widget.maxWidth ? constraints.tighten(width: widget.maxWidth) : constraints.loosen(), //将约束传递给子节点
      parentUsesSize: true, // 因为我们接下来要使用child的size,所以不能为false
    );

    print('width: ${child!.size.width}, height: ${child!.size.height}');

    // size = constraints.constrain(Size(
    //   constraints.maxWidth == double.infinity
    //       ? child!.size.width
    //       : double.infinity,
    //   constraints.maxHeight == double.infinity
    //       ? child!.size.height
    //       : double.infinity,
    // ));
    _childWidth = child!.size.width;

    size = constraints.constrain(Size(min(widget.maxWidth, _childWidth), child!.size.height));
  }
}
