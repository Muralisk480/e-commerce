import 'dart:convert';
import 'package:e_commerce/order_confirmation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  DateTime? selectedDate;
  List<Map<String, dynamic>> cartItems = [];
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  void loadCart() async {
    final preferences = await SharedPreferences.getInstance();
    List<String> cartData = preferences.getStringList('cart') ?? [];
    List<Map<String, dynamic>> loadedCart = cartData.map((item) {
      return json.decode(item) as Map<String, dynamic>;
    }).toList();

    double price = loadedCart.fold(0.0, (total, item) {
      return total + (item['count'] * item['price']);
    });

    setState(() {
      cartItems = loadedCart;
      totalPrice = price;
    });
  }

  Future<void> pickDate() async {
    DateTime today = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(today.year + 1),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // Function to handle checkout process
  Future<void> handleCheckout() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please select a delivery date")));
      return;
    }

    final url = Uri.parse("https://fakestoreapi.com/products");

    final orderData = {
      'cart': cartItems,
      'delivery_date': selectedDate!.toIso8601String(),
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );

      if (response.statusCode == 200) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const OrderConfirmationPage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to place the order")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9EDEE),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color(
            0xFF348489)),
      backgroundColor: const Color(0xFFD9EDEE),
        title: const Text("Checkout", style: TextStyle(color: Color(
            0xFF348489)),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cart Items
              const Text("Items in Cart:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(
                      0xFF348489))),
              ...cartItems.map((item) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Color(
                          0xFF348489),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: ListTile(
                    title: Text(item['title'],style: const TextStyle(color: Color(
                        0xFFFFFFFF)),maxLines: 1,overflow: TextOverflow.ellipsis,),
                    subtitle: Text(
                        "Quantity: ${item['count']} | Price: \$${item['price']}", style: const TextStyle(color: Color(
                        0xFFFFFFFF)),),
                    trailing: Image.network(item['image']),
                  ),
                );
              }).toList(),
              SizedBox(height: 20),
        
              // Total Price
              Center(
                child: Container(
                  width: 230,
                  height: 30,
                  padding: const EdgeInsets.all(5),
                  decoration:BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: Text("Total Price: \$${totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(
                          0xFF348489))),
                ),
              ),
        
              SizedBox(height: 20),
        
              // Delivery Date Picker
              Row(
                children: [
                  const Text("Select Delivery Date: ", style: TextStyle(fontSize: 16, color: Color(
                      0xFF348489))),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: pickDate,
                  ),
                  Text(
                      selectedDate == null
                          ? "No date selected"
                          : "${selectedDate!.toLocal()}".split(' ')[0],
                      style: TextStyle(fontSize: 16, color: Color(
                          0xFF348489))),
                ],
              ),
        
              const SizedBox(height: 20),
        
              // Checkout Button
              Center(
                child: Container(
                  width: 300,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(
                        0xFF348489),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: ElevatedButton(
                    onPressed: handleCheckout,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Color(
                          0xFF348489),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: Text("Proceed to Checkout (\$${totalPrice.toStringAsFixed(2)})",style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
