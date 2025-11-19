import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/salary_model.dart';
import '../services/salary_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Form controllers
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _decimalsController = TextEditingController();

  // Form values
  double _annualSalary = 60000.0;
  double _updateFrequency = 1.0;
  int _decimalPlaces = 2;
  String _currencySymbol = '\$';
  SalaryCalculationMode _calculationMode = SalaryCalculationMode.fullYear;
  late TimeRange _workHours;

  @override
  void initState() {
    super.initState();
    _workHours = TimeRange(
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 18, minute: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final salaryService = Provider.of<SalaryService>(context);

    // Initialize controllers with current values
    if (_salaryController.text.isEmpty) {
      _salaryController.text = _annualSalary.toString();
      _frequencyController.text = _updateFrequency.toString();
      _decimalsController.text = _decimalPlaces.toString();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Salary input
              const Text(
                '薪资信息',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _salaryController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '年薪',
                  prefixText: '¥ ',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  double? parsedValue = double.tryParse(value);
                  if (parsedValue != null) {
                    _annualSalary = parsedValue;
                  }
                },
              ),
              const SizedBox(height: 20),

              // Update frequency
              const Text(
                '更新频率',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _frequencyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '更新间隔（秒）',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  double? parsedValue = double.tryParse(value);
                  if (parsedValue != null && parsedValue > 0) {
                    _updateFrequency = parsedValue;
                  }
                },
              ),
              const SizedBox(height: 20),

              // Decimal places
              const Text(
                '小数位数',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _decimalsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '小数位数',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  int? parsedValue = int.tryParse(value);
                  if (parsedValue != null && parsedValue >= 0) {
                    _decimalPlaces = parsedValue;
                  }
                },
              ),
              const SizedBox(height: 20),

              // Currency symbol
              const Text(
                '货币符号',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _currencySymbol,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: '¥', child: Text('¥ (人民币)')),
                  DropdownMenuItem(value: '\$', child: Text('\$ (美元)')),
                  DropdownMenuItem(value: '€', child: Text('€ (欧元)')),
                  DropdownMenuItem(value: '£', child: Text('£ (英镑)')),
                  DropdownMenuItem(value: '₹', child: Text('₹ (印度卢比)')),
                  DropdownMenuItem(value: '元', child: Text('元 (人民币)')),
                ],
                onChanged: (value) {
                  setState(() {
                    _currencySymbol = value ?? '¥';
                  });
                },
              ),
              const SizedBox(height: 20),

              // Calculation mode
              const Text(
                '薪资计算模式',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SegmentedButton<SalaryCalculationMode>(
                segments: const [
                  ButtonSegment(
                    value: SalaryCalculationMode.fullYear,
                    label: Text('全年(365天)'),
                  ),
                  ButtonSegment(
                    value: SalaryCalculationMode.workDays,
                    label: Text('仅工作日'),
                  ),
                  ButtonSegment(
                    value: SalaryCalculationMode.workHours,
                    label: Text('仅工作时段'),
                  ),
                ],
                selected: {_calculationMode},
                onSelectionChanged: (Set<SalaryCalculationMode> value) {
                  setState(() {
                    _calculationMode = value.first;
                  });
                },
              ),
              const SizedBox(height: 10),

              // Work hours selector (only visible if workHours mode is selected)
              if (_calculationMode == SalaryCalculationMode.workHours) ...[
                const Text(
                  '工作时段',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('开始时间'),
                        subtitle: Text(_workHours.startTime.format(context)),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () async {
                          TimeOfDay? newTime = await showTimePicker(
                            context: context,
                            initialTime: _workHours.startTime,
                          );
                          if (newTime != null) {
                            setState(() {
                              _workHours = _workHours.copyWith(
                                startTime: newTime,
                              );
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('结束时间'),
                        subtitle: Text(_workHours.endTime.format(context)),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () async {
                          TimeOfDay? newTime = await showTimePicker(
                            context: context,
                            initialTime: _workHours.endTime,
                          );
                          if (newTime != null) {
                            setState(() {
                              _workHours = _workHours.copyWith(
                                endTime: newTime,
                              );
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 30),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _saveSettings(salaryService);
                    Navigator.pop(context);
                  },
                  child: const Text('保存设置'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSettings(SalaryService salaryService) {
    SalaryModel newModel = SalaryModel(
      annualSalary: _annualSalary,
      updateFrequency: _updateFrequency,
      decimalPlaces: _decimalPlaces,
      currencySymbol: _currencySymbol,
      calculationMode: _calculationMode,
      workHours: _workHours,
    );

    salaryService.updateSalaryModel(newModel);
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _frequencyController.dispose();
    _decimalsController.dispose();
    super.dispose();
  }
}
