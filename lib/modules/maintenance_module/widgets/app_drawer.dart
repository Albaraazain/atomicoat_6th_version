// import 'package:flutter/material.dart';
//
// import '../screens/report_generation_screen.dart';
//
// class AppDrawer extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: <Widget>[
//           DrawerHeader(
//             decoration: BoxDecoration(
//               color: Theme.of(context).primaryColor,
//             ),
//             child: Text(
//               'ALD Maintenance',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//               ),
//             ),
//           ),
//           ExpansionTile(
//             leading: Icon(Icons.build),
//             title: Text('Maintenance'),
//             children: [
//               ListTile(
//                 leading: Icon(Icons.home),
//                 title: Text('Overview'),
//                 onTap: () => Navigator.of(context).pushReplacementNamed('/maintenance'),
//               ),
//               ListTile(
//                 leading: Icon(Icons.calendar_today),
//                 title: Text('Schedule'),
//                 onTap: () {
//                   // TODO: Implement navigation to maintenance schedule
//                 },
//               ),
//             ],
//           ),
//           ListTile(
//             leading: Icon(Icons.science),
//             title: Text('Calibration'),
//             onTap: () => Navigator.of(context).pushReplacementNamed('/calibration'),
//           ),
//           ListTile(
//             leading: Icon(Icons.assessment),
//             title: Text('Reports'),
//             onTap: () {
//               Navigator.of(context).pushReplacement(
//                 MaterialPageRoute(builder: (context) => ReportGenerationScreen()),
//               );
//             },
//           ),
//           ListTile(
//             leading: Icon(Icons.help),
//             title: Text('Troubleshooting'),
//             onTap: () => Navigator.of(context).pushReplacementNamed('/troubleshooting'),
//           ),
//           ListTile(
//             leading: Icon(Icons.inventory),
//             title: Text('Spare Parts'),
//             onTap: () => Navigator.of(context).pushReplacementNamed('/spare_parts'),
//           ),
//           ListTile(
//             leading: Icon(Icons.library_books),
//             title: Text('Documentation'),
//             onTap: () => Navigator.of(context).pushReplacementNamed('/documentation'),
//           ),
//           ListTile(
//             leading: Icon(Icons.assessment),
//             title: Text('Reporting'),
//             onTap: () => Navigator.of(context).pushReplacementNamed('/reporting'),
//           ),
//           ListTile(
//             leading: Icon(Icons.video_call),
//             title: Text('Remote Assistance'),
//             onTap: () => Navigator.of(context).pushReplacementNamed('/remote_assistance'),
//           ),
//           ListTile(
//             leading: Icon(Icons.health_and_safety),
//             title: Text('Safety Procedures'),
//             onTap: () => Navigator.of(context).pushReplacementNamed('/safety_procedures'),
//           ),
//         ],
//       ),
//     );
//   }
// }