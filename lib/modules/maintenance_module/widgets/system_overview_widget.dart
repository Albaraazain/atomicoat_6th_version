// lib/widgets/system_overview_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/component.dart';
import '../providers/maintenance_ald_system_provider.dart';

class SystemOverviewWidget extends StatelessWidget {
  final List<Component> components;
  final Function(Component) onComponentTap;

  const SystemOverviewWidget({
    Key? key,
    required this.components,
    required this.onComponentTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 2.5, // Adjust this value to fit your layout
              child: SystemDiagram(),
            ),
          ],
        ),
      ),
    );
  }
}

class SystemDiagram extends StatelessWidget {
  const SystemDiagram({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MaintenanceSystemStateProvider>(
      builder: (context, aldSystem, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onTapDown: (TapDownDetails details) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final localPosition = box.globalToLocal(details.globalPosition);
                final relativeX = localPosition.dx / constraints.maxWidth;
                final relativeY = localPosition.dy / constraints.maxHeight;
                _handleTap(context, relativeX, relativeY);
              },
              child: SvgPicture.string(
                _getSvgContent(aldSystem),
                width: constraints.maxWidth,
                height: constraints.maxHeight,
              ),
            );
          },
        );
      },
    );
  }

  void _handleTap(BuildContext context, double relativeX, double relativeY) {
    final aldSystem = Provider.of<MaintenanceSystemStateProvider>(context, listen: false);
    if (relativeY > 0.375 && relativeY < 0.625) {
      if (relativeX < 0.13) aldSystem.toggleN2Gen();
      else if (relativeX < 0.26) aldSystem.toggleMFC();
      else if (relativeX < 0.54) aldSystem.toggleFrontlineHeater();
      else if (relativeX < 0.72) _showChamberDialog(context);
      else if (relativeX < 0.85) aldSystem.toggleBacklineHeater();
      else if (relativeX < 0.93) _showPCDialog(context);
      else aldSystem.togglePump();
    } else if (relativeY > 0.75 && relativeY < 0.85) {
      if (relativeX > 0.365 && relativeX < 0.405) aldSystem.toggleValve('v1');
      else if (relativeX > 0.445 && relativeX < 0.485) aldSystem.toggleValve('v2');
    } else if (relativeY > 0.9) {
      if (relativeX > 0.35 && relativeX < 0.42) aldSystem.toggleHeater('h1');
      else if (relativeX > 0.43 && relativeX < 0.5) aldSystem.toggleHeater('h2');
    }
  }

  void _showChamberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chamber Information'),
          content: Text('The chamber is always active during the process.'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPCDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pressure Controller Information'),
          content: Text('The pressure controller is always active to maintain the desired pressure.'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _getSvgContent(MaintenanceSystemStateProvider aldSystem) {
    return '''
    <svg viewBox="0 0 1000 400" xmlns="http://www.w3.org/2000/svg">
      <g>
        <path d="M50 200 H950" stroke="#BBBBBB" stroke-width="2" fill="none"/>
        <path d="M385 200 V300 M465 200 V300 M385 340 V370 M465 340 V370" stroke="#BBBBBB" stroke-width="2" fill="none"/>
      </g>
      <g>
        <rect x="50" y="130" width="100" height="120" fill="#2C3E50" stroke="#BBBBBB" stroke-width="2"/>
        <rect x="50" y="130" width="100" height="120" fill="${aldSystem.n2GenActive ? '#3498DB' : '#34495E'}" fill-opacity="0.6"/>
        <text x="100" y="200" text-anchor="middle" font-size="18" fill="#FFFFFF">N2 GEN</text>
        
        <rect x="170" y="130" width="100" height="120" fill="#2C3E50" stroke="#BBBBBB" stroke-width="2"/>
        <rect x="170" y="130" width="100" height="120" fill="${aldSystem.mfcActualFlow > 0 ? '#3498DB' : '#34495E'}" fill-opacity="0.6"/>
        <text x="220" y="200" text-anchor="middle" font-size="18" fill="#FFFFFF">MFC</text>
        
        <rect x="290" y="130" width="250" height="120" fill="#2C3E50" stroke="#BBBBBB" stroke-width="2"/>
        <rect x="290" y="130" width="250" height="120" fill="${aldSystem.frontlineHeaterActive ? '#E74C3C' : '#34495E'}" fill-opacity="0.6"/>
        <text x="415" y="200" text-anchor="middle" font-size="18" fill="#FFFFFF">Frontline Heater</text>
        
        <rect x="560" y="130" width="150" height="120" fill="#2C3E50" stroke="#BBBBBB" stroke-width="2"/>
        <rect x="560" y="130" width="150" height="120" fill="#3498DB" fill-opacity="0.6"/>
        <text x="635" y="200" text-anchor="middle" font-size="18" fill="#FFFFFF">CHAMBER</text>
        
        <rect x="730" y="130" width="100" height="120" fill="#2C3E50" stroke="#BBBBBB" stroke-width="2"/>
        <rect x="730" y="130" width="100" height="120" fill="${aldSystem.backlineHeaterActive ? '#E74C3C' : '#34495E'}" fill-opacity="0.6"/>
        <text x="780" y="200" text-anchor="middle" font-size="18" fill="#FFFFFF">Backline</text>
        
        <rect x="850" y="130" width="70" height="120" fill="#2C3E50" stroke="#BBBBBB" stroke-width="2"/>
        <rect x="850" y="130" width="70" height="120" fill="#3498DB" fill-opacity="0.6"/>
        <text x="885" y="200" text-anchor="middle" font-size="18" fill="#FFFFFF">PC</text>
        
        <rect x="940" y="130" width="70" height="120" fill="#2C3E50" stroke="#BBBBBB" stroke-width="2"/>
        <rect x="940" y="130" width="70" height="120" fill="${aldSystem.pumpActive ? '#3498DB' : '#34495E'}" fill-opacity="0.6"/>
        <text x="975" y="200" text-anchor="middle" font-size="18" fill="#FFFFFF">PU</text>
        
        <circle cx="385" cy="320" r="25" fill="#2C3E50" stroke="#BBBBBB" stroke-width="2"/>
        <circle cx="385" cy="320" r="25" fill="${aldSystem.v1Open ? '#2ECC71' : '#E74C3C'}" fill-opacity="0.6"/>
        <text x="385" y="327" text-anchor="middle" font-size="16" fill="#FFFFFF">V1</text>
        
        <circle cx="465" cy="320" r="25" fill="#2C3E50" stroke="#BBBBBB" stroke-width="2"/>
        <circle cx="465" cy="320" r="25" fill="${aldSystem.v2Open ? '#2ECC71' : '#E74C3C'}" fill-opacity="0.6"/>
        <text x="465" y="327" text-anchor="middle" font-size="16" fill="#FFFFFF">V2</text>
        
        <rect x="350" y="360" width="70" height="40" fill="#2C3E50" stroke="#BBBBBB" stroke-width="2"/>
        <rect x="350" y="360" width="70" height="40" fill="${aldSystem.h1Active ? '#E74C3C' : '#34495E'}" fill-opacity="0.6"/>
        <text x="385" y="385" text-anchor="middle" font-size="16" fill="#FFFFFF">H1</text>
        
        <rect x="430" y="360" width="70" height="40" fill="#2C3E50" stroke="#BBBBBB" stroke-width="2"/>
        <rect x="430" y="360" width="70" height="40" fill="${aldSystem.h2Active ? '#E74C3C' : '#34495E'}" fill-opacity="0.6"/>
        <text x="465" y="385" text-anchor="middle" font-size="16" fill="#FFFFFF">H2</text>
      </g>
    </svg>
    ''';
  }
}