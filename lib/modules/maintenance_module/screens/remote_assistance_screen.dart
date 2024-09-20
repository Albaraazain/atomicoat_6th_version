// lib/screens/remote_assistance_screen.dart
import 'package:flutter/material.dart';

class RemoteAssistanceScreen extends StatefulWidget {
  @override
  _RemoteAssistanceScreenState createState() => _RemoteAssistanceScreenState();
}

class _RemoteAssistanceScreenState extends State<RemoteAssistanceScreen> {
  bool _isCallActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text('Remote Assistance'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isCallActive ? Icons.videocam : Icons.videocam_off,
              size: 100,
              color: _isCallActive ? Colors.green : Colors.red,
            ),
            SizedBox(height: 20),
            Text(
              _isCallActive ? 'Call in progress' : 'No active call',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isCallActive ? _endCall : _startCall,
              child: Text(_isCallActive ? 'End Call' : 'Request Assistance'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isCallActive ? Colors.red : Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _shareScreen,
              child: Text('Share Screen'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startCall() {
    // TODO: Implement call initiation logic
    setState(() {
      _isCallActive = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Initiating remote assistance call...')),
    );
  }

  void _endCall() {
    // TODO: Implement call termination logic
    setState(() {
      _isCallActive = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ended remote assistance call')),
    );
  }

  void _shareScreen() {
    // TODO: Implement screen sharing logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Screen sharing initiated')),
    );
  }
}