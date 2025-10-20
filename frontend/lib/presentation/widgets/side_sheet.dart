import 'package:flutter/material.dart';

Future<T?> showAppSideSheet<T>({
  required BuildContext context,
  required Widget child,
  double width = 420,
  EdgeInsets margin = const EdgeInsets.all(16),
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(16)),
  Color barrierColor = Colors.black54,
  Duration transitionDuration = const Duration(milliseconds: 250),
  Curve curve = Curves.easeOutCubic,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'SideSheet',
    barrierColor: barrierColor,
    transitionDuration: transitionDuration,
    pageBuilder: (ctx, anim, secAnim) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (ctx, anim, secAnim, _) {
      final animation = CurvedAnimation(parent: anim, curve: curve, reverseCurve: Curves.easeInCubic);

      return Stack(
        children: [
          // Barrier handled by showGeneralDialog
          Align(
            alignment: Alignment.centerRight,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
              child: SafeArea(
                child: Container(
                  margin: margin,
                  constraints: BoxConstraints.tightFor(width: width),
                  child: ClipRRect(
                    borderRadius: borderRadius,
                    child: Material(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      elevation: 12,
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}


