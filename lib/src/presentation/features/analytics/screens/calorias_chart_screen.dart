// lib/src/presentation/features/analytics/screens/calorias_chart_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/consumo_calorico.dart';

class CaloriasChartScreen extends StatelessWidget {
  final Map<String, List<ConsumoCalorico>> todosLosConsumos;
  const CaloriasChartScreen({super.key, required this.todosLosConsumos});

  List<BarChartGroupData> _procesarDatos() {
    final List<BarChartGroupData> data = [];
    final hoy = DateUtils.dateOnly(DateTime.now());

    for (int i = 6; i >= 0; i--) {
      final dia = hoy.subtract(Duration(days: i));
      final fechaString = DateFormat('yyyy-MM-dd').format(dia);
      final consumosDelDia = todosLosConsumos[fechaString] ?? [];
      final totalCalorias = consumosDelDia.fold<double>(
        0,
        (sum, item) => sum + item.calorias,
      );

      data.add(
        BarChartGroupData(
          x: 6 - i,
          barRods: [
            BarChartRodData(
              toY: totalCalorias,
              color: Colors.teal,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }
    return data;
  }

  // --- CORRECCIÓN FINAL ---
  // El widget SideTitleWidget ahora requiere que se le pase el parámetro 'meta'.
  Widget _getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    final diaDeHoy = DateTime.now();
    final diaDelTitulo = diaDeHoy.subtract(Duration(days: 6 - value.toInt()));
    String textoDia = DateFormat('E', 'es_ES').format(diaDelTitulo)[0];

    return SideTitleWidget(
      meta: meta, // <-- SE AÑADE EL PARÁMETRO 'meta' REQUERIDO
      space: 4,
      child: Text(textoDia, style: style),
    );
  }

  Widget _getLeftTitles(double value, TitleMeta meta) {
    if (value % 500 != 0 || value == 0 && meta.max > 0) {
      return Container();
    }
    // --- CORRECCIÓN FINAL ---
    // También se añade aquí el parámetro 'meta' requerido.
    return SideTitleWidget(
      meta: meta, // <-- SE AÑADE EL PARÁMETRO 'meta' REQUERIDO
      space: 4,
      child: Text('${value.toInt()}', style: const TextStyle(fontSize: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consumo Calórico Semanal'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 3500,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => Colors.blueGrey,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${rod.toY.round()} kcal',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: _getLeftTitles,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: _getBottomTitles,
                  reservedSize: 30,
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 500,
            ),
            barGroups: _procesarDatos(),
          ),
        ),
      ),
    );
  }
}
