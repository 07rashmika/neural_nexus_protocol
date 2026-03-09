import 'package:flutter/material.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/widgets/chain/chain_node.dart';

import 'chain_line.dart';

class ChainWidget extends StatefulWidget {
  const ChainWidget({
    super.key,
    required this.count,
    this.activeCount,
    this.circleRadius = 8.0,
    this.lineLength = 20.0,
    this.lineThickness = 2.0,
    this.activeColor = NeuralColors.teal,
    this.inactiveColor = NeuralColors.tealDark,
    this.animate = true,
  }) : assert(count > 0, 'count must be at least 1'),
       assert(
         activeCount == null || (activeCount >= 0 && activeCount <= count),
         'activeCount must be between 0 and count',
       );

  final int count;
  final int? activeCount;
  final double circleRadius;
  final double lineLength;
  final double lineThickness;
  final Color activeColor;
  final Color inactiveColor;
  final bool animate;

  @override
  State<ChainWidget> createState() => _ChainWidgetState();
}

class _ChainWidgetState extends State<ChainWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulse = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.activeCount ?? widget.count;

    if (!widget.animate) {
      return _buildChain(active, glowOpacity: 0.6);
    }

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) =>
          _buildChain(active, glowOpacity: _pulse.value),
    );
  }

  Widget _buildChain(int active, {required double glowOpacity}) {
    return Row(
      mainAxisSize: .min,
      crossAxisAlignment: .center,
      children: List.generate(widget.count * 2 - 1, (i) {
        // Even indices → circle nodes, odd indices → connecting lines
        if (i.isEven) {
          final nodeIndex = i ~/ 2;
          final isActive = nodeIndex < active;
          return ChainNode(
            radius: widget.circleRadius,
            color: isActive ? widget.activeColor : widget.inactiveColor,
            glowOpacity: isActive ? glowOpacity : 0.0,
            glowColor: widget.activeColor,
          );
        } else {
          // Line between node i/2 and node i/2+1
          // Active if both surrounding nodes are active
          final leftActive = (i ~/ 2) < active;
          final rightActive = (i ~/ 2 + 1) < active;
          final lineActive = leftActive && rightActive;
          return ChainLine(
            length: widget.lineLength,
            thickness: widget.lineThickness,
            color: lineActive ? widget.activeColor : widget.inactiveColor,
            glowOpacity: lineActive ? glowOpacity * 0.5 : 0.0,
            glowColor: widget.activeColor,
          );
        }
      }),
    );
  }
}
