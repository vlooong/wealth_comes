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
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _decimalsController = TextEditingController();

  double _annualSalary = 60000.0;
  double _updateFrequency = 1.0;
  int _decimalPlaces = 2;
  String _currencySymbol = '¥';
  SalaryCalculationMode _calculationMode = SalaryCalculationMode.fullYear;
  late TimeRange _workHours;

  @override
  void initState() {
    super.initState();
    final salaryService = context.read<SalaryService>();
    final model = salaryService.salaryModel;
    
    _annualSalary = model.annualSalary;
    _updateFrequency = model.updateFrequency;
    _decimalPlaces = model.decimalPlaces;
    _currencySymbol = model.currencySymbol;
    _calculationMode = model.calculationMode;
    _workHours = model.workHours;

    _salaryController.text = _annualSalary.toString();
    _frequencyController.text = _updateFrequency.toString();
    _decimalsController.text = _decimalPlaces.toString();
  }

  @override
  Widget build(BuildContext context) {
    final salaryService = Provider.of<SalaryService>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: '恢复默认设置',
            onPressed: _resetToDefaults,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: '薪资信息',
              icon: Icons.attach_money,
              color: Colors.green,
              children: [
                TextField(
                  controller: _salaryController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '年薪',
                    prefixText: '$_currencySymbol ',
                    border: const OutlineInputBorder(),
                    filled: true,
                  ),
                  onChanged: (value) {
                    double? parsedValue = double.tryParse(value);
                    if (parsedValue != null && parsedValue >= 0) {
                      setState(() => _annualSalary = parsedValue);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSectionCard(
              title: '显示设置',
              icon: Icons.display_settings,
              color: Colors.blue,
              children: [
                TextField(
                  controller: _frequencyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '更新间隔（秒）',
                    hintText: '推荐: 0.1 - 5',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  onChanged: (value) {
                    double? parsedValue = double.tryParse(value);
                    if (parsedValue != null && parsedValue > 0) {
                      setState(() => _updateFrequency = parsedValue);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _decimalsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '小数位数',
                    hintText: '0-6',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  onChanged: (value) {
                    int? parsedValue = int.tryParse(value);
                    if (parsedValue != null && parsedValue >= 0 && parsedValue <= 6) {
                      setState(() => _decimalPlaces = parsedValue);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _currencySymbol,
                  decoration: const InputDecoration(
                    labelText: '货币符号',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: '¥', child: Text('¥ (人民币)')),
                    DropdownMenuItem(value: '\$', child: Text('\$ (美元)')),
                    DropdownMenuItem(value: '€', child: Text('€ (欧元)')),
                    DropdownMenuItem(value: '£', child: Text('£ (英镑)')),
                    DropdownMenuItem(value: '₹', child: Text('₹ (印度卢比)')),
                    DropdownMenuItem(value: '元', child: Text('元 (人民币)')),
                  ],
                  onChanged: (value) {
                    setState(() => _currencySymbol = value ?? '¥');
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSectionCard(
              title: '计算模式',
              icon: Icons.calculate,
              color: Colors.orange,
              children: [
                SegmentedButton<SalaryCalculationMode>(
                  segments: const [
                    ButtonSegment(
                      value: SalaryCalculationMode.fullYear,
                      label: Text('全年', style: TextStyle(fontSize: 12)),
                      icon: Icon(Icons.calendar_today, size: 16),
                    ),
                    ButtonSegment(
                      value: SalaryCalculationMode.workDays,
                      label: Text('工作日', style: TextStyle(fontSize: 12)),
                      icon: Icon(Icons.work, size: 16),
                    ),
                    ButtonSegment(
                      value: SalaryCalculationMode.workHours,
                      label: Text('工作时段', style: TextStyle(fontSize: 12)),
                      icon: Icon(Icons.access_time, size: 16),
                    ),
                  ],
                  selected: {_calculationMode},
                  onSelectionChanged: (Set<SalaryCalculationMode> value) {
                    setState(() => _calculationMode = value.first);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return colorScheme.primaryContainer;
                      }
                      return null;
                    }),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getModeDescription(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),

                if (_calculationMode == SalaryCalculationMode.workHours) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    '工作时段',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeSelector(
                          label: '开始时间',
                          time: _workHours.startTime,
                          onTap: () => _selectTime(true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTimeSelector(
                          label: '结束时间',
                          time: _workHours.endTime,
                          onTap: () => _selectTime(false),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () {
                  _saveSettings(salaryService);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('设置已保存'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('保存设置', style: TextStyle(fontSize: 16)),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
          color: Colors.orange.withOpacity(0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time.format(context),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                ),
                const Icon(Icons.access_time, color: Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getModeDescription() {
    switch (_calculationMode) {
      case SalaryCalculationMode.fullYear:
        return '全年365天×24小时不间断计算薪资累积';
      case SalaryCalculationMode.workDays:
        return '仅计算工作日（周一至周五）的薪资累积';
      case SalaryCalculationMode.workHours:
        return '仅计算工作日的指定工作时段内的薪资累积';
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: isStart ? _workHours.startTime : _workHours.endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (newTime != null) {
      setState(() {
        _workHours = isStart
            ? _workHours.copyWith(startTime: newTime)
            : _workHours.copyWith(endTime: newTime);
      });
    }
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('恢复默认设置'),
        content: const Text('确定要恢复所有设置为默认值吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _annualSalary = 60000.0;
                _updateFrequency = 1.0;
                _decimalPlaces = 2;
                _currencySymbol = '¥';
                _calculationMode = SalaryCalculationMode.fullYear;
                _workHours = TimeRange(
                  startTime: const TimeOfDay(hour: 9, minute: 0),
                  endTime: const TimeOfDay(hour: 18, minute: 0),
                );
                _salaryController.text = _annualSalary.toString();
                _frequencyController.text = _updateFrequency.toString();
                _decimalsController.text = _decimalPlaces.toString();
              });
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
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
