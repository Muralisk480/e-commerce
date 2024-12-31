import 'dart:convert';
import 'package:e_commerce/cart_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {

  runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
          home: MyApp() ,
      ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List products = [];
  String apiUrl = 'https://fakestoreapi.com/products';
  List<Map<String, dynamic>> cart = [];

  @override
  void initState() {
    super.initState();
    CartFetch();
  }
  Future<void> CartFetch() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body);
      });
    } else {
      print("Error happened");
    }
  }



  Future<void> saveToCart(Map<String, dynamic> product) async {
    final preferences = await SharedPreferences.getInstance();
    List<String> cart = preferences.getStringList('cart') ?? [];
    cart.add(json.encode(product));
    await preferences.setStringList('cart', cart);
    print("saved");
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFE1F3EF),
        appBar: AppBar(

          backgroundColor: const Color(0xFFE1F3F2),
          title: const Text(
            "Dashboard Page",
            style: TextStyle(
              color: Color(0xFF3B879F),
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF329498)),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                  onTap: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=> CartPage()));
                  },
                  child: Icon(Icons.shopping_cart, size: 20,)),
            )
          ],
        ),
        body: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.only(top: 8.0, left: 8, right: 7),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                var product = products[index];

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50)
                  ),
                  child: Card(
                    elevation: 2,
                    color: const Color(0xFF6BB2B2),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0, right: 0),
                      child: Column(
                        children: [
                          Container(
                            width: width,
                            height: height * 0.09,
                            color: Colors.white,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Image.network(
                                product['image'],
                                width: width,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 3.0, top: 3),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['title'],
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "\$${product['price']}",
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 90,
                                      height: 25,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          saveToCart(product);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          shadowColor: Colors.black,
                                        ),
                                        child: const Text(
                                          "Add cart",
                                          style: TextStyle(
                                            color: Color(0xFF15595B),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

