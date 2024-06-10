import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final List<Map<String, dynamic>> _cart = [];
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newItem = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (newItem != null) {
      _addToCart(newItem['imageUrl'], newItem['price']);
    }
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cart = prefs.getStringList('cart') ?? [];
    setState(() {
      for (var item in cart) {
        final parts = item.split(',');
        _cart.add({'imageUrl': parts[0], 'price': double.parse(parts[1])});
      }
      _updateTotalPrice(); // Update total price after loading cart items
    });
  }

  Future<void> _addToCart(String imageUrl, double price) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cart.add({'imageUrl': imageUrl, 'price': price});
      _totalPrice += price;
    });
    prefs.setStringList('cart', _cart.map((item) => '${item['imageUrl']},${item['price']}').toList());
    _updateTotalPrice(); // Update total price after adding item
  }

  Future<void> _deleteCartItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalPrice -= _cart[index]['price'];
      _cart.removeAt(index);
    });
    prefs.setStringList('cart', _cart.map((item) => '${item['imageUrl']},${item['price']}').toList());
    _updateTotalPrice(); // Update total price after deleting item
  }

  void _updateTotalPrice() {
    setState(() {
      _totalPrice = _cart.fold(0.0, (sum, item) => sum + item['price']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cart',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.teal, Colors.tealAccent],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _cart.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            child: Image.network(
                              _cart[index]['imageUrl'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          _cart[index]['imageUrl'],
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(
                      'Dog Image ${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('\$${_cart[index]['price']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteCartItem(index),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\₹$_totalPrice',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Buy functionality not implemented yet.'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black87, backgroundColor: Colors.amberAccent,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text(
              'Buy Now',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 2),
    );
  }
}
