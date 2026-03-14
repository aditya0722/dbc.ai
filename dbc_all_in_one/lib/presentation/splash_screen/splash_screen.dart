import 'package:flutter/material.dart';
import '../business_dashboard/business_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _introController;
  late AnimationController _floatController;

  late Animation<double> _logoFloat;
  late Animation<double> _titleFade;
  late Animation<double> _subtitleFade;

  @override
  void initState() {
    super.initState();

    /// Intro animation (runs once)
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    /// Floating animation (loops)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    /// Logo floating
    _logoFloat = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    /// Title fade
    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(0.3, 0.7)),
    );

    /// Subtitle fade
    _subtitleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(0.5, 1)),
    );

    _introController.forward();

    /// Navigate after delay
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BusinessDashboard(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        /// 🔵 Keep your purple gradient (as you said)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6A5ACD),
              Color(0xFF4B3F72),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: AnimatedBuilder(
          animation: Listenable.merge([_introController, _floatController]),
          builder: (context, _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                /// 🔷 LOGO (floating)
                Transform.translate(
                  offset: Offset(0, _logoFloat.value),
                  child: Container(
                    width: 130,
                    height: 130,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                        )
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/DBC_latest_Logo-1765449512865.jpg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                /// 📝 TITLE
                Opacity(
                  opacity: _titleFade.value,
                  child: const Text(
                    "DBC.AI",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// 📝 SUBTITLE
                Opacity(
                  opacity: _subtitleFade.value,
                  child: const Text(
                    "Enterprise Resource Planning",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// 🔵 LOADING DOTS
                const LoadingDots(),

                const SizedBox(height: 8),

                const Text(
                  "Loading...",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 🔵 Animated Loading Dots
class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key});

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {

  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // faster
    )..repeat();
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _dotController,
      builder: (context, child) {
        double delay = index * 0.2;
        double value = (_dotController.value - delay) % 1;

        return Opacity(
          opacity: value,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: CircleAvatar(
              radius: 3.5,
              backgroundColor: Colors.white,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(0),
        _buildDot(1),
        _buildDot(2),
      ],
    );
  }
}
