import 'dart:convert';
import 'package:e_commerce/checkout_page.dart';
import 'package:e_commerce/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  @override
  State<CartPage> createState() {
    return _CartPageState();
  }
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  void loadCart() async {
    final preferences = await SharedPreferences.getInstance();
    List<String> cartData = preferences.getStringList('cart') ?? [];
    List<Map<String, dynamic>> loadedCart = cartData.map((item) {
      var product = json.decode(item) as Map<String, dynamic>;
      if (product['count'] == null) {
        product['count'] = 1;
      }
      return product;
    }).toList();

    consolidateCart(loadedCart);

    setState(() {
      products = loadedCart;
    });
  }

  void consolidateCart(List<Map<String, dynamic>> items) {
    final Map<int, Map<String, dynamic>> uniqueItems = {};

    for (var item in items) {
      int id = item['id'];
      if (uniqueItems.containsKey(id)) {
        uniqueItems[id]?['count'] += item['count'];
      } else {
        uniqueItems[id] = item;
      }
    }

    items.clear();
    items.addAll(uniqueItems.values);
  }

  void saveToCart() async {
    final preferences = await SharedPreferences.getInstance();
    List<String> cartData = products.map((item) => json.encode(item)).toList();
    await preferences.setStringList('cart', cartData);
  }

  void addToCart(Map<String, dynamic> product) {
    setState(() {
      int existingProductIndex = products.indexWhere((item) => item['id'] == product['id']);

      if (existingProductIndex != -1) {
        products[existingProductIndex]['count'] += 1;
      } else {
        product['count'] = 1;
        products.add(product);
      }
      saveToCart();
    });
  }

  void updateQuantity(int productId, int change) {
    setState(() {
      int productIndex = products.indexWhere((item) => item['id'] == productId);
      if (productIndex != -1) {
        products[productIndex]['count'] += change;

        if (products[productIndex]['count'] <= 0) {
          products.removeAt(productIndex);
        }
      }
      saveToCart();
    });
  }


  @override
  Widget build(BuildContext context) {
    double totalPrice = products.fold(0.0, (total, item) => total + (item['count'] ?? 1) * item['price']);
    String checkoutLabel =  "Checkout (\$${totalPrice.toStringAsFixed(2)})";

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        appBar: AppBar(
            backgroundColor: Color(0xFFFFFFFF),
            automaticallyImplyLeading: false,
            leading: IconButton(
              alignment: Alignment.center,
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => MyApp()));
              },
              icon:
                  Icon(Icons.chevron_left, size: 30, color: Color(0xFF338D95)),
              color: Color(0xFFF5F0E6),
            ),
            title: const Text(
              "Cart",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF338D95)),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                  icon: Icon(
                    Icons.checklist_outlined,
                    size: 25,
                    color: Color(0xFF338D95),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CheckoutPage()));
                  })
            ]),

        //   body
        body: Column(
          children: [
            products.isEmpty
                ?  Expanded(
                child: Center(
                    child: Text("No items in cart",
                      style: TextStyle(
                          color: Colors.black),)))
                : Expanded(
                    child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        var product = products[index];
                        return Padding(
                          padding: const EdgeInsets.only(top: 15.0, left: 15, right: 10),
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFF6BB2B2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                leading: Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Image.network(
                                    product['image'],
                                    width: 80,
                                    height: 90,
                                  ),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['title'],
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color:  Color(
                                          0xFFFFFFFF),),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      product['description'],
                                      style: const TextStyle(fontSize: 12, color: const Color(
                                          0xFFFFFFFF),),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "\$${product['price'] * product['count'] ?? 0}",
                                          style: const TextStyle(fontSize: 15, color: Color(
                                              0xFFFEFEFF),),
                                        ),
                                        Container(
                                          height: 35,
                                          width: 70,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.white,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: Row(

                                              children: [
                                                InkWell(
                                                  onTap: () => updateQuantity(product['id'], -1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Container(
                                                    color: Colors.white,
                                                    child: const Icon(
                                                      Icons.remove,
                                                      size: 13,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 8,),
                                                Text(
                                                  product['count'].toString(),
                                                  style:
                                                      TextStyle(fontSize: 13),
                                                ),
                                                SizedBox(width: 10,),
                                                InkWell(
                                                  onTap: () => updateQuantity(product['id'], 1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Container(
                                                    color: Colors.white,
                                                    child: const Icon(
                                                      Icons.add,
                                                      size: 13,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                        ),
                                        ),
                                              IconButton(onPressed: () => updateQuantity(
                                                  product['id'], -product['count']), icon: Icon(Icons.delete, size: 15,color: const Color(0xFFF50808),))
                                      ],
                                    )
                                  ],
                                ),
                              
                            ),
                          ),
                          ),
                        );
                      }),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 260,
                  height: 40,
                  child: FloatingActionButton.extended(
                    backgroundColor: Color(0xFF509A91),
                    elevation: 3,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CheckoutPage()));
                    },
                    label: const Text(
                      "Checkout ",
                        style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Ensure contrast
                        ),
                  ),
                ),
              ),
            ))
          ],
        ));
  }
}
