import 'dart:ui' as ui show Locale, LocaleStringAttribute, ParagraphBuilder, SpellOutStringAttribute, StringAttribute;

import 'package:elastic_box/widget_size.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TypeWriterController extends ChangeNotifier {
  Widget? _typing;

  Widget? get typing => _typing;

  void startTyping(Widget currentTyping) {
    _typing = currentTyping;
    notifyListeners();
  }

  void stopTyping() {
    _typing = null;
    notifyListeners();
  }

  Size? _size;

  Size? get size => _size;

  set size(Size? size) {
    _size = size;
    notifyListeners();
  }
}

class TypewriterTextSpan {
  String text;
  final TextStyle? style;
  final void Function(Size)? onTyping;
  final void Function()? onTap;

  TypewriterTextSpan({
    required this.text,
    this.style,
    this.onTyping,
    this.onTap,
  });
}

class Typewriter extends StatefulWidget {
  final String? text;
  final List<TypewriterTextSpan>? spans;
  final Widget? child;
  final TextStyle? textStyle;
  final Duration duration;
  final Duration? pause;
  final TypeWriterController? controller;
  final void Function(Size)? onTyping;
  final void Function()? onTap;

  Typewriter({
    Key? key,
    this.text,
    this.textStyle,
    this.duration = const Duration(milliseconds: 100),
    this.pause,
    this.controller,
    this.onTyping,
    this.onTap,
    this.child,
    this.spans,
  }) : super(key: key) {
    assert(!((text != null) && (spans != null)), 'text和spans不能同时传入');
    final bool isText = text != null || spans != null;
    assert(isText != (child != null), 'text和child不能同时为空');
  }

  @override
  State<Typewriter> createState() => _TypewriterState();

  static _typingText(String text, void Function(String) callback, {Duration duration = const Duration(milliseconds: 300)}) async {
    for (int i = 0; i < text.length; i++) {
      callback(text.substring(0, i + 1));
      await Future.delayed(duration);
    }
  }
}

class _TypewriterState extends State<Typewriter> {
  String _typedText = '';
  Widget? _typedWidget;
  List<TypewriterTextSpan> _typedSpans = [];

  void _typing() async {
    // controller未被占用，则抢占
    if (widget.controller?.typing == null) {
      widget.controller?.startTyping(widget);
    }
    // 如果被其他组件占用则等待500毫秒
    if (widget.controller != null && widget.controller!.typing != widget) {
      await Future.delayed(const Duration(milliseconds: 500));
      _typing();
      return;
    }
    // 打印完成后，释放controller
    if (widget.text != null && _typedText.length == widget.text!.length) {
      widget.controller?.stopTyping();
      return;
    }

    if (widget.spans != null) {
      _typedSpans = [];
      print('typing spans: ${widget.spans!.length}');
      for (int i = 0; i < widget.spans!.length; i++) {
        final TypewriterTextSpan span = widget.spans![i];
        if (_typedSpans.length < i + 1) {
          _typedSpans.add(TypewriterTextSpan(text: '', style: span.style, onTyping: span.onTyping, onTap: span.onTap));
        }
        TypewriterTextSpan currentSpan = _typedSpans.elementAt(i);
        if (currentSpan.text.length < span.text.length) {
          await Typewriter._typingText(
            span.text,
            (String text) {
              setState(() {
                currentSpan.text = text;
              });
            },
            duration: widget.duration,
          );
        }
      }
    } else if (widget.text != null) {
      await Typewriter._typingText(
        widget.text!,
        (String text) {
          setState(() {
            _typedText = text;
          });
        },
        duration: widget.duration,
      );
    } else {
      setState(() {
        _typedWidget = widget.child;
      });
    }

    widget.controller?.stopTyping();
  }

  @override
  void initState() {
    super.initState();
    _typing();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child != null
        ? _typedWidget != null
            ? _typedWidget!
            : Container()
        : widget.spans != null
            ? _typedSpans.isEmpty
                ? Container()
                : RichText(
                    text: TextSpan(
                      children: _typedSpans
                          .asMap()
                          .map((index, span) {
                            return MapEntry(
                              index,
                              TextSpan(
                                text: span.text,
                                style: TextStyle(
                                  color: widget.spans![index].onTap == null
                                      ? Theme.of(context).colorScheme.onBackground
                                      : Theme.of(context).colorScheme.primary,
                                  height: 1.8,
                                ),
                                recognizer: span.onTap == null ? null : TapGestureRecognizer()
                                  ?..onTap = () {
                                    span.onTap?.call();
                                  },
                              ),
                            );
                          })
                          .values
                          .toList(),
                    ),
                  )
            : _typedText.isEmpty
                ? Container()
                : DefaultTextStyle.merge(
                    style: TextStyle(
                      color: widget.onTap == null
                          ? Theme.of(context).colorScheme.onBackground
                          : Theme.of(context).colorScheme.primary,
                      height: 1.8,
                    ),
                    child: MouseRegion(
                      cursor: widget.onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: widget.onTap,
                        child: LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints constraints) {
                            print('777,${constraints.maxWidth}, $_typedText');
                            return Text(
                              _typedText,
                              style: widget.textStyle,
                              softWrap: true,
                            );
                          },
                        ),
                      ),
                    ),
                  );
  }
}
