import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  void _skip() {
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF071827);
    const green = Color(0xFF73D13D);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildPage(
                    title: "Welcome to\nCarvePlus Cut Pro",
                    subtitle:
                        "Professional nesting and cut optimization for cabinet makers and CNC woodworking professionals.",
                    illustration: const Icon(
                      Icons.dashboard_customize_rounded,
                      size: 170,
                      color: green,
                    ),
                  ),

                  _buildPage(
                    title: "Optimize\nEvery Sheet",
                    subtitle:
                        "Generate efficient cutting layouts, reduce waste, and maximize material utilization.",
                    illustration: const Icon(
                      Icons.grid_view_rounded,
                      size: 170,
                      color: green,
                    ),
                  ),

                  _buildPage(
                    title: "Export\nwith Confidence",
                    subtitle:
                        "Export PDF reports and DXF files ready for your CNC workflow.",
                    illustration: const Icon(
                      Icons.description_outlined,
                      size: 170,
                      color: green,
                    ),
                  ),
                ],
              ),
            ),

            _buildBottomBar(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String subtitle,
    required Widget illustration,
  }) {
    const green = Color(0xFF73D13D);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          const SizedBox(height: 20),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _currentPage == 2 ? _finishOnboarding : _skip,
              child: const Text("Skip", style: TextStyle(color: green)),
            ),
          ),

          const Spacer(),

          illustration,

          const SizedBox(height: 45),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 17,
              height: 1.5,
            ),
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    const green = Color(0xFF73D13D);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: _currentPage == index ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? green : Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                if (_currentPage == 2) {
                  _finishOnboarding();
                } else {
                  _nextPage();
                }
              },
              child: Text(
                _currentPage == 2 ? "Get Started" : "Next",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "Your data stays local. Works offline.",
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
