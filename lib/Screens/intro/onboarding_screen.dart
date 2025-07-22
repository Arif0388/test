import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/Screens/auth/sign_in.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardState();
}

class _OnboardState extends State<OnboardingScreen> {
  int currentIndex = 0;
  late PageController _controller;

  List<String> contents = [
    "assets/images/1.png",
    "assets/images/2.png",
    "assets/images/3.png",
    "assets/images/4.png"
  ];

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.white,
          child: Stack(
            children: [
              PageView.builder(
                  controller: _controller,
                  itemCount: contents.length,
                  onPageChanged: (int index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (_, i) {
                    return Image.asset(
                      contents[i],
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.contain,
                    );
                  }),
              Positioned(
                bottom: 120,
                left: 0,
                right: 0,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      contents.length,
                      (index) => buildDot(index, context),
                    )),
              ),
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    if (currentIndex == contents.length - 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignIn()),
                      );
                    }
                    _controller.nextPage(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeIn);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue),
                    height: 50,
                    width: double.infinity,
                    child: Center(
                        child: Text(
                            currentIndex == contents.length - 1
                                ? "Start"
                                : "Next",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20))),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: currentIndex == index ? 18 : 7,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6), color: Colors.black87),
    );
  }
}
