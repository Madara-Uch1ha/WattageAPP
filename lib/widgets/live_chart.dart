import 'dart:collection';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import '../theme/app_theme.dart';

class LiveWattageChart extends StatelessWidget {
  final Queue<double> dataPoints;
  final int maxPoints;
  final Color color;
  final String label;

  const LiveWattageChart({
    super.key,
    required this.dataPoints,
    this.maxPoints = 60,
    this.color = AppColors.neonGreen,
    this.label = 'Wattage (W)',
  });

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    int i = 0;
    double maxVal = 1.0;
    for (final val in dataPoints) {
      spots.add(FlSpot(i.toDouble(), val));
      if (val > maxVal) maxVal = val;
      i++;
    }

    // Dynamic scale: 25% headroom so lines never hit or cross the top border
    // No hardcoded 100.0 cap!
    final double maxY = max(maxVal * 1.25, 4.0);
    final double interval = (maxY / 4).clamp(1.0, double.infinity);

    return Container(
      decoration: BoxDecoration(
        // Apple-style clean dark glass: neutral dark surface with subtle sheen
        color: const Color(0xFF13131A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.7),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Text(
                    '${dataPoints.length}s history',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 125,
              child: spots.length < 2
                  ? Center(
                      child: Text(
                        'Collecting live stream data...',
                        style: TextStyle(
                          color: AppColors.textMuted.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        clipData: const FlClipData.all(),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: interval,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.white.withValues(alpha: 0.04),
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: maxY >= 1000 ? 42 : 36,
                              interval: interval,
                              getTitlesWidget: (value, meta) {
                                if (value < 0 || value > maxY) return const SizedBox.shrink();
                                String text;
                                if (value >= 1000) {
                                  text = '${(value / 1000).toStringAsFixed(1)}k';
                                } else {
                                  text = value.toStringAsFixed(0);
                                }
                                return Text(
                                  text,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white.withValues(alpha: 0.35),
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: (maxPoints - 1).toDouble(),
                        minY: 0,
                        maxY: maxY,
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            curveSmoothness: 0.3,
                            color: color,
                            barWidth: 2.2,
                            isStrokeCapRound: true,
                            shadow: Shadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  color.withValues(alpha: 0.22),
                                  color.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ],
                        lineTouchData: const LineTouchData(enabled: false),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
