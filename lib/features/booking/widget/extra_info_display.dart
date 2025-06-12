import 'dart:io';
import 'package:flutter/material.dart';

class ExtraInfoDisplay extends StatelessWidget {
  final String title;
  final String extraInfoText;
  final List<File> extraImages;

  const ExtraInfoDisplay({
    Key? key,
    required this.title,
    required this.extraInfoText,
    required this.extraImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (extraInfoText.isEmpty && extraImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (extraInfoText.isNotEmpty) ...[
                const Text(
                  'Lý do thăm khám:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  extraInfoText,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                if (extraImages.isNotEmpty) const SizedBox(height: 12),
              ],
              if (extraImages.isNotEmpty) ...[
                const Text(
                  'Ảnh đính kèm:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: extraImages.map((file) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        file,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}