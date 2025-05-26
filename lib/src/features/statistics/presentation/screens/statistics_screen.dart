import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/styles/app_styles.dart';
import '../../../dashboard/domain/entities/balance.dart';
import '../../../dashboard/presentation/controllers/balance_controller.dart';
import '../../../dashboard/presentation/widgets/bottom_nav_bar.dart';
import '../../../dashboard/presentation/widgets/send_audio_button.dart';
import '../../../dashboard/data/mock/stats_mock_data.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  String _selectedTimeRange = 'month'; // Default to monthly view
  int _currentMonthIndex = 1; // Current month index (0-based)
  final List<String> _months = ['Abril 2025', 'Mayo 2025', 'Junio 2025'];

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(balanceControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        backgroundColor: AppStyles.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),

            // Monthly Overview Card
            _buildMonthlyOverviewCard(balanceAsync),

            // Expense vs Income Chart
            _buildExpenseVsIncomeChart(),

            // Category Distribution
            _buildCategoryDistributionChart(),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 70,
        child: const BottomNavBar(),
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 15),
        child: SendAudioButton(
          onTransactionAdded: () {
            ref.read(balanceControllerProvider.notifier).refreshBalance();
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estadísticas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Resumen del mes',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyOverviewCard(AsyncValue<Balance> balanceAsync) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppStyles.primaryColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.all(16.0),
        child: balanceAsync.when(
          data: (balance) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _months[_currentMonthIndex],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        _buildMonthNavigationButton(
                          icon: Icons.chevron_left,
                          onTap: () {
                            if (_currentMonthIndex > 0) {
                              setState(() {
                                _currentMonthIndex--;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildMonthNavigationButton(
                          icon: Icons.chevron_right,
                          onTap: () {
                            if (_currentMonthIndex < _months.length - 1) {
                              setState(() {
                                _currentMonthIndex++;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Balance del Mes',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${balance.currency} ${balance.totalBalance.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            '+12.5%',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'vs. mes anterior',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 120,
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
          error: (error, stack) => SizedBox(
            height: 120,
            child: Center(
              child: Text(
                'Error loading balance data',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthNavigationButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildExpenseVsIncomeChart() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gastos vs Ingresos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedTimeRange,
                  underline: Container(),
                  icon: const Icon(Icons.arrow_drop_down, size: 16),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedTimeRange = newValue;
                      });
                    }
                  },
                  items: <String>['month', 'lastMonth', 'year']
                      .map<DropdownMenuItem<String>>((String value) {
                    String displayText;
                    switch (value) {
                      case 'month':
                        displayText = 'Este Mes';
                        break;
                      case 'lastMonth':
                        displayText = 'Último Mes';
                        break;
                      case 'year':
                        displayText = 'Este Año';
                        break;
                      default:
                        displayText = value;
                    }
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(displayText),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: _buildExpenseIncomeBarChart(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  color: AppStyles.incomeColor,
                  label: 'Ingresos',
                ),
                const SizedBox(width: 24),
                _buildLegendItem(
                  color: AppStyles.expenseColor,
                  label: 'Gastos',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseIncomeBarChart() {
    final List<String> labels = _selectedTimeRange == 'year'
        ? ['Ene', 'Feb', 'Mar', 'Abr']
        : ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4'];

    // Sample data - in a real app this would come from your balance data
    final List<double> incomeData = [0.85, 0.65, 0.95, 0.55];
    final List<double> expenseData = [0.45, 0.35, 0.75, 0.25];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceBetween,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    labels[value.toInt()],
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          labels.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: incomeData[i] * 100,
                color: AppStyles.incomeColor,
                width: 8,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              BarChartRodData(
                toY: expenseData[i] * 100,
                color: AppStyles.expenseColor,
                width: 8,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            );
          },
        ),
        maxY: 100,
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDistributionChart() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribución por Categoría',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 240,
                  child: _buildPieChart(),
                ),
                const SizedBox(height: 16),
                _buildCategoryLegends(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: 35,
            color: Colors.purple.shade400,
            title: '35%',
            radius: 80,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          PieChartSectionData(
            value: 25,
            color: Colors.blue.shade400,
            title: '25%',
            radius: 80,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          PieChartSectionData(
            value: 20,
            color: Colors.green.shade400,
            title: '20%',
            radius: 80,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          PieChartSectionData(
            value: 15,
            color: Colors.red.shade200,
            title: '15%',
            radius: 80,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildCategoryLegends() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        _buildCategoryLegendItem(
          emoji: '🍔',
          color: Colors.purple.shade400,
          percentage: '35%',
        ),
        _buildCategoryLegendItem(
          emoji: '🚗',
          color: Colors.blue.shade400,
          percentage: '25%',
        ),
        _buildCategoryLegendItem(
          emoji: '🎮',
          color: Colors.green.shade400,
          percentage: '20%',
        ),
        _buildCategoryLegendItem(
          emoji: '⚕️',
          color: Colors.red.shade200,
          percentage: '15%',
        ),
      ],
    );
  }

  Widget _buildCategoryLegendItem({
    required String emoji,
    required Color color,
    required String percentage,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 4),
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              percentage,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
