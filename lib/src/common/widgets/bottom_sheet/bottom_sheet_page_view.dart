import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/single_child_widget.dart';

import '../../../../../generated/colors.gen.dart';
import 'controller/bottom_sheet_page_controller.dart';
import 'controller/bottom_sheet_page_state.dart';
import 'core/bottom_sheet_page_delegate.dart';

part 'core/bottom_sheet_core.dart';

class BottomSheetPageView extends StatefulWidget {
  const BottomSheetPageView({
    super.key,
    required this.children,
    this.anchor,
    this.onClose,
  });

  final List<BottomSheetPageChildDelegate> children;
  final VoidCallback? onClose;
  final double? anchor;

  static void showBottomSheet(
    BuildContext context, {
    required List<BottomSheetPageChildDelegate> children,
    bool isScrollController = true,
    double? elevation,
    ShapeBorder shape = const Border(),
    Clip? clipBehavior = Clip.antiAlias,
    BoxConstraints? constraints,
    Color? barrierColor,
    Color? backgroundColor,
    bool useSafeArea = false,
    double? anchor,
    List<SingleChildWidget> providers = const [],
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: isScrollController,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      barrierColor: barrierColor,
      elevation: elevation,
      enableDrag: false,
      backgroundColor: backgroundColor,
      useSafeArea: useSafeArea,
      builder: (context) {
        Widget child = BottomSheetPageView(
          children: children,
          anchor: anchor,
          onClose: () {
            children.firstOrNull?.onCanceled?.call();
            Navigator.of(context).maybePop();
          },
        );
        return child;
        // return providers.isNotEmpty
        //     ? MultiBlocProvider(providers: providers, child: child)
        //     : child;
      },
    );
  }

  @override
  State<BottomSheetPageView> createState() => _BottomSheetPageViewState();
}

class _BottomSheetPageViewState extends State<BottomSheetPageView> {
  late final BottomSheetPageViewController controller;

  @override
  void initState() {
    controller = BottomSheetPageViewController(
      widget.children,
      widget.anchor,
    );
    controller.addCloseListener(widget.onClose);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark.copyWith(
        systemNavigationBarColor: ColorName.background,
      ),
      child: BottomSheetPageViewScope(
        controller: controller,
        child: Builder(
          builder: (context) {
            return _BottomSheetWidget(
              controller: BottomSheetPageViewScope.of(context).controller,
            );
          },
        ),
      ),
    );
  }
}

class BottomSheetPageViewScope extends InheritedWidget {
  const BottomSheetPageViewScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final BottomSheetPageViewController controller;

  void jumpNext() => controller.jumpNext();

  void jumpPrevious() => controller.jumpPrevious();

  void jumpToPage(int page) => controller.jumpToPage(page);

  static BottomSheetPageViewScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<BottomSheetPageViewScope>();
  }

  static BottomSheetPageViewScope of(BuildContext context) {
    final BottomSheetPageViewScope? result = maybeOf(context);
    assert(result != null, 'No BottomSheetPageViewScope found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(BottomSheetPageViewScope oldWidget) =>
      controller != oldWidget.controller;
}
