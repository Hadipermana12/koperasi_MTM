import 'package:flutter/material.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Berpindah ke halaman login setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Biru Melengkung di bagian bawah (Mirip gambar)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 300),
              painter: WavePainter(),
            ),
          ),

          // Konten Tengah
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo (Menggunakan logo_kmma.png yang sudah disiapkan)
                Image.asset(
                  'assets/images/logo_kmma.png',
                  width: 180,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.business_rounded,
                    size: 100,
                    color: Color(0xFF1296C4),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'KMMA',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1296C4),
                    letterSpacing: 2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1296C4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ONE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Slogan di bagian bawah
          const Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Sinergi Untuk Sejahtera',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Melukis bentuk gelombang/biru di bawah mirip desain asli
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = const Color(0xFF0D47A1) // Biru tua
      ..style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(0, size.height * 0.4);

    // Kurva pertama (Hijau tipis pembatas)
    var greenPaint = Paint()
      ..color = const Color(0xFF14A96B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    var greenPath = Path();
    greenPath.moveTo(0, size.height * 0.38);
    greenPath.quadraticBezierTo(
      size.width * 0.25, size.height * 0.2,
      size.width, size.height * 0.35
    );
    canvas.drawPath(greenPath, greenPaint);

    // Area Biru
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.22,
      size.width, size.height * 0.37
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
