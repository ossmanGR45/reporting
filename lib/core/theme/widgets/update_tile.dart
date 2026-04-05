import 'package:flutter/material.dart';

class UpdateTile extends StatelessWidget {
  final String title;
  final String time;

  const UpdateTile({
    super.key,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(time, style: const TextStyle(color: Colors.grey)),
    );
  }
}
