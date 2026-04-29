import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Logowanie',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.gray,
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}



class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  
  // void _handleConnectToQKD() {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text('Connecting to QKD...'),
  //       duration: Duration(seconds: 2),
  //     ),
  //   );

  //   debugPrint('Initiating QKD connection logic...');
  // }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: TextButton.icon(
                  onPressed: () {

                  },
                  icon: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Więcej informacji',
                    style: TextStyle(color: Colors.white),
                  )
                )
              ),

              const Spacer(),

              const Text(
                '<BRAKET>',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: AppColors.red,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 50),

              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Login',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(
                    Icons.person_2_outlined,
                    color: Colors.white70
                  ),
                  filled: true,
                  fillColor: AppColors.gray_light,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20), 
              
              TextField(
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(
                    Icons.lock_outlined,
                    color: Colors.white70
                  ),
                  filled: true,
                  fillColor: AppColors.gray_light,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30), 

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {

                  }, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const Spacer()
            ],
          ),
        )
      ),
    );
  }
}
