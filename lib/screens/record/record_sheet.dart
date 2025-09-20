// lib/screens/record/record_sheet.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RecordSheet extends HookConsumerWidget{
  const RecordSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 1,
      maxChildSize: 1,
      builder: (context, scrollController) {
        return 
        Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsetsGeometry.all(24),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ミス記録',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.close)
                      )
                    ],
                  )
                ],
              ),
            ),
            )
        );
      }
    );
  }
}