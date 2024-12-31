import 'package:flutter/material.dart';

void main(){
  runApp(const OrderConfirmationPage());
}
class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3C7478),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: const Color(0xFF3C7478),

      ),
      body: const Center(
        child: Text(
          "Thank you for your order!\nYour order is being processed.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
