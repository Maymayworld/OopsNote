import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Home extends HookConsumerWidget {
  final int selectedNumber;

  const Home({
    super.key,
    this.selectedNumber = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = useState<int>(selectedNumber);

    final pages = [
      const 
    ]
  }
}