import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/salary_service.dart';
import '../widgets/salary_stats_widget.dart';
import '../widgets/progress_widget.dart';
import '../screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Current selected period for viewing
  String _currentPeriod = 'Daily';

  @override
  Widget build(BuildContext context) {
    final salaryService = Provider.of<SalaryService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('财富累积器'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Period selector
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPeriodButton('年', 'Yearly'),
                _buildPeriodButton('月', 'Monthly'),
                _buildPeriodButton('周', 'Weekly'),
                _buildPeriodButton('日', 'Daily'),
              ],
            ),
          ),

          // Selected period display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              '$_currentPeriod 累计薪资',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),

          // Stats widgets
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Accumulated salary for the selected period
                  Consumer<SalaryService>(
                    builder: (context, salaryService, child) {
                      DateTime now = DateTime.now();
                      DateTime startDate = _getStartDate(now);
                      DateTime endDate = _getEndDate(now);

                      String title = _currentPeriod == 'Daily' ? '今日累计' :
                                    _currentPeriod == 'Weekly' ? '本周累计' :
                                    _currentPeriod == 'Monthly' ? '本月累计' : '本年累计';

                      return SalaryStatsWidget(
                        title: title,
                        amount: salaryService.getFormattedSalaryForPeriod(startDate, endDate),
                        color: Colors.green,
                        icon: Icons.paid,
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Current total salary
                  Consumer<SalaryService>(
                    builder: (context, salaryService, child) {
                      return SalaryStatsWidget(
                        title: '当前总额',
                        amount: salaryService.getFormattedSalary(),
                        color: Colors.blue,
                        icon: Icons.account_balance_wallet,
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Progress widget
                  Consumer<SalaryService>(
                    builder: (context, salaryService, child) {
                      DateTime now = DateTime.now();
                      DateTime startDate = _getStartDate(now);
                      DateTime endDate = _getEndDate(now);

                      // Use the salary service method to calculate progress percentage
                      double progress = salaryService.getProgressPercentage(startDate, endDate);

                      String progressTitle = _currentPeriod == 'Daily' ? '今日进度' :
                                           _currentPeriod == 'Weekly' ? '本周进度' :
                                           _currentPeriod == 'Monthly' ? '本月进度' : '本年进度';

                      String progressText = '${(progress * 100).toStringAsFixed(1)}%';

                      return ProgressWidget(
                        title: progressTitle,
                        progressText: progressText,
                        progressValue: progress,
                        color: Colors.orange,
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Additional information
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '薪资累积信息',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '您的薪资累积基于您在应用中设置的配置。\n'
                          '您可以在设置菜单中自定义计算模式、更新频率和其他参数。',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period, String periodLabel) {
    bool isSelected = _currentPeriod == periodLabel;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.blue : null,
            foregroundColor: isSelected ? Colors.white : null,
          ),
          onPressed: () {
            setState(() {
              _currentPeriod = periodLabel;
            });
          },
          child: Text(period),
        ),
      ),
    );
  }

  DateTime _getStartDate(DateTime now) {
    switch (_currentPeriod) {
      case 'Yearly':
        return DateTime(now.year, 1, 1);
      case 'Monthly':
        return DateTime(now.year, now.month, 1);
      case 'Weekly':
        // Calculate the start of the week (Monday)
        int daysSinceMonday = now.weekday - 1;
        return DateTime(now.year, now.month, now.day - daysSinceMonday);
      case 'Daily':
      default:
        return DateTime(now.year, now.month, now.day);
    }
  }

  DateTime _getEndDate(DateTime now) {
    switch (_currentPeriod) {
      case 'Yearly':
        return DateTime(now.year, 12, 31, 23, 59, 59);
      case 'Monthly':
        return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      case 'Weekly':
        // Calculate the start of the week (Monday)
        int daysSinceMonday = now.weekday - 1;
        DateTime startOfWeek = DateTime(now.year, now.month, now.day - daysSinceMonday);
        return startOfWeek.add(const Duration(days: 6));
      case 'Daily':
      default:
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
    }
  }
}