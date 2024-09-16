import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/system_state_provider.dart';

class SystemDiagramView extends StatelessWidget {
  final List<Widget> overlays;
  final double zoomFactor;
  final bool enableOverlaySwiping;

  const SystemDiagramView({
    Key? key,
    required this.overlays,
    this.zoomFactor = 1.0,
    this.enableOverlaySwiping = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SystemStateProvider>(
      builder: (context, systemProvider, child) {
        Widget overlayWidget;

        if (enableOverlaySwiping && overlays.length > 1) {
          PageController _pageController = PageController();

          overlayWidget = PageView(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            children: overlays,
          );
        } else {
          overlayWidget = overlays.first;
        }

        return Stack(
          children: [
            Positioned.fill(
              child: Transform.scale(
                scale: zoomFactor,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Image.asset(
                    'assets/ald_system_diagram.png',
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: overlayWidget,
            ),
            // You can add additional widgets here that react to system state changes

          ],
        );
      },
    );
  }
}