import 'package:flutter/material.dart';

class ParameterCard extends StatefulWidget {
  final String title;
  final String value;
  final String normalRange;
  final bool isNormal;

  const ParameterCard({
    Key? key,
    required this.title,
    required this.value,
    required this.normalRange,
    required this.isNormal,
  }) : super(key: key);

  @override
  _ParameterCardState createState() => _ParameterCardState();
}

class _ParameterCardState extends State<ParameterCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _isExpanded ? 130 : 90,
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E), // Darker background for contrast
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF333333), width: 1), // Subtle border for definition
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleExpand,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          color: Color(0xFFB0B0B0), // Slightly dimmed text for title
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    _buildStatusIndicator(),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  widget.value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        'Normal Range:',
                        style: TextStyle(
                          color: Color(0xFF808080), // Dimmed text for label
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        widget.normalRange,
                        style: TextStyle(
                          color: Color(0xFFA0A0A0), // Slightly brighter for readability
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.isNormal ? Color(0xFF4CAF50) : Color(0xFFF44336),
      ),
    );
  }
}