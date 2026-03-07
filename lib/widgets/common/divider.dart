import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class Divider extends StatelessWidget {
  const Divider({super.key});

  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: NeuralColors.tealBorder);
}
