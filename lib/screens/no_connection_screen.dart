// import 'package:flutter/material.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';

// class NetworkAwareScreen extends StatefulWidget {
//   final Widget child;

//   const NetworkAwareScreen({super.key, required this.child});

//   @override
//   State<NetworkAwareScreen> createState() => _NetworkAwareScreenState();
// }

// class _NetworkAwareScreenState extends State<NetworkAwareScreen> {
//   bool _hasConnection = true;

//   @override
//   void initState() {
//     super.initState();
//     _checkConnection();

//     Connectivity().onConnectivityChanged.listen((
//       List<ConnectivityResult> resultList,
//     ) {
//       // Asumimos que si al menos uno tiene conexión, estamos conectados
//       final hasConnection = resultList.any((r) => r != ConnectivityResult.none);
//       setState(() {
//         _hasConnection = hasConnection;
//       });
//     });
//   }

//   Future<void> _checkConnection() async {
//     final statusList = await Connectivity().checkConnectivity();

//     // Como checkConnectivity sigue retornando un único valor, mantenemos esto:
//     _updateConnectionStatus(statusList);
//   }

//   void _updateConnectionStatus(ConnectivityResult result) {
//     setState(() {
//       _hasConnection = result != ConnectivityResult.none;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_hasConnection) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.wifi_off, size: 80, color: Colors.grey),
//             SizedBox(height: 20),
//             Text(
//               'Sin conexión',
//               style: TextStyle(fontSize: 24, color: Colors.grey),
//             ),
//           ],
//         ),
//       );
//     }

//     return widget.child;
//   }
// }
