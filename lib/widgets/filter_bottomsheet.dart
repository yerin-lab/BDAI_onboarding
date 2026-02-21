import 'package:flutter/material.dart';

enum FeedFilter { all, post, question }

class FeedFilterSheet extends StatelessWidget {
  const FeedFilterSheet({super.key, required this.selected});

  final FeedFilter selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '필터',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                _chip(
                  label: '전체',
                  selected: selected == FeedFilter.all,
                  onTap: () => Navigator.pop(context, FeedFilter.all),
                ),
                const SizedBox(width: 8),
                _chip(
                  label: '게시글',
                  selected: selected == FeedFilter.post,
                  onTap: () => Navigator.pop(context, FeedFilter.post),
                ),
                const SizedBox(width: 8),
                _chip(
                  label: '질문',
                  selected: selected == FeedFilter.question,
                  onTap: () => Navigator.pop(context, FeedFilter.question),
                ),
              ],
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selected ? Colors.black : Colors.white,
            border: Border.all(color: Colors.black12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
