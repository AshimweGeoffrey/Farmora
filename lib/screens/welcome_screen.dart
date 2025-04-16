import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Text(
                'Farmora',
                style: TextStyle(
                  fontFamily: 'Abnes',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E88E5), // Light dark blue
                ),
              ),
              SizedBox(height: 20),
              PlantWidget(),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1E88E5), // Light dark blue
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text('Login'),
              ),
              SizedBox(height: 10), // Add space between buttons
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1E88E5), // Light dark blue
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlantWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      child: CustomPaint(
        painter: PlantPainter(),
      ),
    );
  }
}

class PlantPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    final stem = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(size.width / 2, size.height / 2)
      ..lineTo(size.width / 2 + 5, size.height / 2)
      ..lineTo(size.width / 2 + 5, size.height)
      ..close();

    final leaf1 = Path()
      ..moveTo(size.width / 2, size.height / 2)
      ..quadraticBezierTo(size.width / 2 - 20, size.height / 2 - 20, size.width / 2 - 40, size.height / 2)
      ..quadraticBezierTo(size.width / 2 - 20, size.height / 2 + 20, size.width / 2, size.height / 2)
      ..close();

    final leaf2 = Path()
      ..moveTo(size.width / 2 + 5, size.height / 2)
      ..quadraticBezierTo(size.width / 2 + 25, size.height / 2 - 20, size.width / 2 + 45, size.height / 2)
      ..quadraticBezierTo(size.width / 2 + 25, size.height / 2 + 20, size.width / 2 + 5, size.height / 2)
      ..close();

    canvas.drawPath(stem, paint);
    canvas.drawPath(leaf1, paint);
    canvas.drawPath(leaf2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

