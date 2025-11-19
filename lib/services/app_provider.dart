import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/salary_service.dart';

class AppProvider extends StatelessWidget {
  final Widget child;

  const AppProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SalaryService())],
      child: child,
    );
  }
}
