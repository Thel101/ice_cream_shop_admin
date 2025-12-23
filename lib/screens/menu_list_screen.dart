import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_item_screen.dart';
import 'login_screen.dart';
import 'add_topping_screen.dart';

class MenuListScreen extends StatelessWidget {
  const MenuListScreen({super.key});

  final Color _primaryColor = const Color(0xFFF04888);
  final Color _backgroundColor = const Color(0xFFF8F9FA);

  // Dummy Data
  final List<Map<String, dynamic>> _dummyMenu = const [
    {
      'name': 'Midnight Chocolate',
      'price': 4.50,
      'description': 'Deep, dark Dutch cocoa with fudge chunks.',
      'color': Colors.brown,
    },
    {
      'name': 'Vanilla Bean Dream',
      'price': 4.00,
      'description': 'Classic vanilla made with real Madagascar beans.',
      'color': Colors.amber,
    },
    {
      'name': 'Strawberry Basil',
      'price': 4.75,
      'description': 'Fresh strawberries blended with a hint of basil.',
      'color': Colors.pinkAccent,
    },
    {
      'name': 'Mango Chile Popsicle',
      'price': 3.50,
      'description': 'Sweet ripe mango with a spicy kick of Tajín.',
      'color': Colors.orange,
    },
    {
      'name': 'Blue Raspberry Ice',
      'price': 3.00,
      'description': 'Nostalgic blue raspberry flavor, strictly for fun.',
      'color': Colors.blue,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'Menu Items',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.grain),
            tooltip: 'Add Topping',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddToppingScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _dummyMenu.length,
        itemBuilder: (context, index) {
          final item = _dummyMenu[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(20),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  // Navigate to details or edit in future
                },
                child: Row(
                  children: [
                    // Image Placeholder
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withAlpha(50),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                      child: Icon(
                        Icons.icecream,
                        color: item['color'] as Color,
                        size: 40,
                      ),
                    ),
                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'] as String,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['description'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${(item['price'] as double).toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: _primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Arrow
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddItemScreen()),
          );
        },
        backgroundColor: _primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Item',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
