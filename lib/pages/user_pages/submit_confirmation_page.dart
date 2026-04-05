import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SubmissionConfirmationPage extends StatelessWidget {
  final String referenceId;
  final String category;
  final String location;
  final DateTime submittedAt;

  const SubmissionConfirmationPage({
    super.key,
    required this.referenceId,
    required this.category,
    required this.location,
    required this.submittedAt,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        "${submittedAt.month}/${submittedAt.day}/${submittedAt.year} ${submittedAt.hour}:${submittedAt.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Submission Status'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6EE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 38, color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Issue Submitted Successfully",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Reference ID: #",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    Text(
                      referenceId,
                      style: const TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(Icons.category_outlined, "Category", category),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.location_on_outlined, "Location", location),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.access_time, "Submitted on", formattedDate),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (context.mounted) context.go('/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("View My Issues",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                if (context.mounted) context.go('/home');
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Return to Home",
                  style: TextStyle(color: Colors.black87, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.black54),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 15, color: Colors.black87, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }
}
