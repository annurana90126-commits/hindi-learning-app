import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WaveformWidget extends StatefulWidget {
  final bool isRecording;

  const WaveformWidget({super.key, required this.isRecording});

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  List<double> _bars = List.filled(30, 0.15);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addListener(_updateBars)..repeat();
  }

  void _updateBars() {
    if (!mounted) return;
    if (widget.isRecording) {
      setState(() {
        _bars = List.generate(
          30,
          (i) => 0.1 + _random.nextDouble() * 0.9,
        );
      });
    } else {
      setState(() {
        _bars = List.generate(30, (i) {
          final phase = (i / 30) * 2 * pi +
              _controller.value * 2 * pi;
          return 0.1 + 0.08 * sin(phase).abs();
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_bars.length, (i) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 4,
            height: 64 * _bars[i],
            decoration: BoxDecoration(
              color: widget.isRecording
                  ? AppColors.error.withValues(alpha: 0.7 + _bars[i] * 0.3)
                  : AppColors.primary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}