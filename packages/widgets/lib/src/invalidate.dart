import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:mhu_widgets/mhu_widgets.dart';

Widget invalidatingWidget({
  required InvalidateController controller,
  required WidgetBuilder builder,
}) =>
    InvalidatingWidget(
      controller: controller,
      builder: builder,
    );

class InvalidateController {
  final _notifier = ChangeNotifierImpl();

  void invalidate() {
    _notifier.notifyListeners();
  }
}

class InvalidatingWidget extends StatefulWidget {
  final InvalidateController controller;
  final WidgetBuilder builder;
  const InvalidatingWidget({
    super.key,
    required this.controller,
    required this.builder,
  });

  @override
  State<InvalidatingWidget> createState() => _InvalidatingWidgetState();
}

class _InvalidatingWidgetState extends State<InvalidatingWidget> {
  Widget? cached;
  int seq = 0;

  void invalidate() {
    setState(() {
      cached = null;
      seq += 1;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.controller._notifier.addListener(invalidate);
  }

  @override
  void dispose() {
    widget.controller._notifier.removeListener(invalidate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = cached ?? widget.builder(context).also((w) => cached = w);

    return Builder(
      key: ValueKey(seq),
      builder: (context) => child,
    );
  }
}
