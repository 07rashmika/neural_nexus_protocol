// import 'package:flutter/material.dart';
// import 'package:neural_nexus_protocol/services/api_service.dart';
// import 'package:neural_nexus_protocol/widgets/common/button.dart';

// class ButtonLogout extends StatefulWidget {
//   const ButtonLogout({super.key});

//   @override
//   State<ButtonLogout> createState() => _ButtonLogoutState();
// }

// class _ButtonLogoutState extends State<ButtonLogout> {
//   Future<void> _handleLogout() async {
//     await ApiService.logout();
//     if (!mounted) return;
//     // Pop the dialog first, then replace the entire route stack with AuthScreen
//     Navigator.of(context).pop();
//     Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Button(text: 'Logout', onTap: _handleLogout);
//   }
// }
