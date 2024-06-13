import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProcessingPage extends StatefulWidget {
  const ProcessingPage({super.key});

  @override
  _ProcessingPageState createState() => _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage> {
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  Future<void> _startProcessing() async {
    try {
      // Using a Future with a timeout to simulate the image processing
      await Future.delayed(Duration(seconds: 30), () {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.5, 2.0],
            colors: [
              Color(0xff087ee1),
              Color(0xff05e8ba),
            ],
          ),
        ),
        child: Center(
          child: _hasError
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Something went wrong. Please check your internet connection or try again later.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'InriaSans',
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _hasError = false;
                        });
                        _startProcessing();
                      },
                      child: const Text('Retry',
                          style: TextStyle(
                              color: Color.fromARGB(255, 13, 71, 161),
                              fontWeight: FontWeight.w700,
                              fontFamily: 'InriaSans')),
                    ),
                  ],
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitFadingFour(color: Colors.white, size: 80),
                    SizedBox(height: 20),
                    Text(
                      'Analysing...',
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'InriaSans'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
