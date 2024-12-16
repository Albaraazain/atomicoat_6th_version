

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/system_state/bloc/system_state_bloc.dart';
import '../../../blocs/system_state/bloc/system_state_state.dart';
import '../../../blocs/component/bloc/component_list_bloc.dart';
import '../../../blocs/component/bloc/component_list_state.dart';

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

  Widget build(BuildContext context) {
    print("SystemDiagramView: build called with ${overlays.length} overlays");
    return BlocBuilder<ComponentListBloc, ComponentListState>(
      builder: (context, componentState) {
        print(
            "SystemDiagramView: ComponentListState update - Components: ${componentState.components.length}");
        return BlocBuilder<SystemStateBloc, SystemStateState>(
          builder: (context, systemState) {
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
                // Additional widgets can be added here based on system or component state
                if (systemState.isError) _buildErrorOverlay(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.red.withOpacity(0.3),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'System Error',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
