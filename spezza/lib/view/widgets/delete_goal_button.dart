import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spezza/shared/repositories/goal_repository.dart';

class DeleteGoalButton extends ConsumerStatefulWidget {
  final int id;
  final VoidCallback onDeleted;

  const DeleteGoalButton({
    super.key,
    required this.id,
    required this.onDeleted,
  });

  @override
  ConsumerState<DeleteGoalButton> createState() => _DeleteGoalButtonState();
}

class _DeleteGoalButtonState extends ConsumerState<DeleteGoalButton> {
  bool _showConfirm = false;
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    if (!_showConfirm) {
      return IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: const Icon(Icons.delete, color: Colors.white, size: 18),
        onPressed: () => setState(() => _showConfirm = true),
      );
    }

    if (_isDeleting) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.close, color: Colors.white, size: 18),
          onPressed: () => setState(() => _showConfirm = false),
        ),
        const SizedBox(width: 8),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.check, color: Colors.white, size: 18),
          onPressed: () async {
            setState(() => _isDeleting = true);
            try {
              // Use repository to delete
              await ref.read(goalRepositoryProvider).deleteGoal(widget.id);
              if (!mounted) return;
              widget.onDeleted();
            } catch (_) {
              if (!mounted) return;
              setState(() {
                _isDeleting = false;
                _showConfirm = false;
              });
            }
          },
        ),
      ],
    );
  }
}
