import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/system_state_provider.dart';
import 'parameter_card.dart';

class ParameterDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SystemStateProvider>(
      builder: (context, systemStateProvider, child) {
        final reactionChamber = systemStateProvider.getComponentByName('Reaction Chamber');
        final mfc = systemStateProvider.getComponentByName('MFC');
        final nitrogenGenerator = systemStateProvider.getComponentByName('Nitrogen Generator');
        final precursorHeater1 = systemStateProvider.getComponentByName('Precursor Heater 1');
        final precursorHeater2 = systemStateProvider.getComponentByName('Precursor Heater 2');

        return LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = constraints.maxWidth;
            final int crossAxisCount = maxWidth > 600 ? 3 : (maxWidth > 400 ? 2 : 1);

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.extent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 1.5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    if (reactionChamber != null)
                      ParameterCard(
                        title: 'Chamber Pressure',
                        value: '${reactionChamber.currentValues['pressure']?.toStringAsFixed(2) ?? 'N/A'} atm',
                        normalRange: '0.9 - 1.1 atm',
                        isNormal: systemStateProvider.isReactorPressureNormal(),
                      ),
                    if (reactionChamber != null)
                      ParameterCard(
                        title: 'Chamber Temperature',
                        value: '${reactionChamber.currentValues['temperature']?.toStringAsFixed(1) ?? 'N/A'} °C',
                        normalRange: '145 - 155 °C',
                        isNormal: systemStateProvider.isReactorTemperatureNormal(),
                      ),
                    if (mfc != null)
                      ParameterCard(
                        title: 'MFC Flow Rate',
                        value: '${mfc.currentValues['flow_rate']?.toStringAsFixed(2) ?? 'N/A'} sccm',
                        normalRange: '0 - 100 sccm',
                        isNormal: true,
                      ),
                    if (nitrogenGenerator != null)
                      ParameterCard(
                        title: 'Nitrogen Flow Rate',
                        value: '${nitrogenGenerator.currentValues['flow_rate']?.toStringAsFixed(2) ?? 'N/A'} sccm',
                        normalRange: '0 - 100 sccm',
                        isNormal: true,
                      ),
                    if (precursorHeater1 != null)
                      ParameterCard(
                        title: 'Precursor Heater 1',
                        value: '${precursorHeater1.currentValues['temperature']?.toStringAsFixed(1) ?? 'N/A'} °C',
                        normalRange: '28 - 32 °C',
                        isNormal: systemStateProvider.isPrecursorTemperatureNormal('Precursor Heater 1'),
                      ),
                    if (precursorHeater2 != null)
                      ParameterCard(
                        title: 'Precursor Heater 2',
                        value: '${precursorHeater2.currentValues['temperature']?.toStringAsFixed(1) ?? 'N/A'} °C',
                        normalRange: '28 - 32 °C',
                        isNormal: systemStateProvider.isPrecursorTemperatureNormal('Precursor Heater 2'),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildParameterCard(String title, String value, String normalRange, bool isNormal) {
    return ParameterCard(
      title: title,
      value: value,
      normalRange: normalRange,
      isNormal: isNormal,
    );
  }
}