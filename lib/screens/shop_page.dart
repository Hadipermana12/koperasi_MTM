import 'package:flutter/material.dart';

class ShopPage extends StatefulWidget {
  final bool isStatic; // true if used in BottomNav, false if pushed as new page
  const ShopPage({super.key, this.isStatic = false});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int _selectedCategoryIndex = 2; // Default to 'Elektronik' as per screenshot

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Semua', 'icon': null},
    {'label': 'Sembako', 'icon': null},
    {'label': 'Elektronik', 'icon': null},
    {'label': 'Open PO', 'icon': Icons.auto_awesome},
    {'label': 'Pabrik', 'icon': null},
    {'label': 'ATK', 'icon': null},
    {'label': 'Kesehatan', 'icon': null},
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Beras Premium 5kg',
      'price': 75000,
      'image': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&q=80&w=400',
      'isPreOrder': false,
      'category': 'Sembako',
    },
    {
      'name': 'Laptop Asus VivoBook',
      'price': 8500000,
      'image': 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?auto=format&fit=crop&q=80&w=400',
      'isPreOrder': true,
      'progress': 0.75,
      'progressLabel': '75% Terpenuhi',
      'estReady': '15 Mei 2026',
      'category': 'Elektronik',
    },
    {
      'name': 'Minyak Goreng 2L',
      'price': 40000,
      'image': 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&q=80&w=400',
      'isPreOrder': false,
      'category': 'Sembako',
    },
    {
      'name': 'Smartphone Samsung A54',
      'price': 5200000,
      'image': 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?auto=format&fit=crop&q=80&w=400',
      'isPreOrder': true,
      'progress': 0.60,
      'progressLabel': '60% Terpenuhi',
      'estReady': '20 Mei 2026',
      'category': 'Elektronik',
    },
    {
      'name': 'Mie Instan Paket 10pcs',
      'price': 25000,
      'image': 'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?auto=format&fit=crop&q=80&w=400',
      'isPreOrder': false,
      'category': 'Sembako',
    },
    {
      'name': 'Headphone Sony WH-1000XM4',
      'price': 3200000,
      'image': 'https://images.unsplash.com/photo-1613040809024-b4ef7ba99bc3?auto=format&fit=crop&q=80&w=400',
      'isPreOrder': true,
      'progress': 0.85,
      'progressLabel': '85% Terpenuhi',
      'estReady': '10 Mei 2026',
      'category': 'Elektronik',
    },
    {
      'name': 'Air Fryer Digital 5L',
      'price': 1250000,
      'image': 'https://images.unsplash.com/photo-1626074353765-517a681e40be?auto=format&fit=crop&q=80&w=400',
      'isPreOrder': true,
      'progress': 0.45,
      'progressLabel': '45% Terpenuhi',
      'estReady': '25 Mei 2026',
      'category': 'Elektronik',
    },
    {
      'name': 'Blender Philips HR2157',
      'price': 450000,
      'image': 'https://images.unsplash.com/photo-1570222094114-d054a817e56b?auto=format&fit=crop&q=80&w=400',
      'isPreOrder': false,
      'category': 'Elektronik',
    },
  ];

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: !widget.isStatic,
        title: _buildSearchHeader(),
        actions: [
          _buildCartBadge(),
          const SizedBox(width: 20),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildCategoryList(),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Expanded(
            child: _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari produk...',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCartBadge() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.shopping_cart_outlined, color: Colors.grey.shade800, size: 28),
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF14A96B),
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: const Text(
                '3',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategoryIndex == index;
          final isOutline = cat['label'] == 'Open PO';

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => setState(() => _selectedCategoryIndex = index),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isOutline 
                      ? Colors.transparent 
                      : (isSelected ? const Color(0xFF14A96B) : const Color(0xFFF5F5F5)),
                  borderRadius: BorderRadius.circular(10),
                  border: isOutline 
                      ? Border.all(color: const Color(0xFFF59E0B), width: 1.5) 
                      : null,
                ),
                child: Row(
                  children: [
                    if (cat['icon'] != null) ...[
                      Icon(
                        cat['icon'], 
                        size: 16, 
                        color: isOutline ? const Color(0xFFF59E0B) : Colors.white
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      cat['label'],
                      style: TextStyle(
                        color: isOutline 
                            ? const Color(0xFFF59E0B) 
                            : (isSelected ? Colors.white : Colors.black87),
                        fontWeight: isSelected || isOutline ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    String selectedLabel = _categories[_selectedCategoryIndex]['label'];
    
    List<Map<String, dynamic>> filteredProducts = _products.where((p) {
      if (selectedLabel == 'Semua') return true;
      if (selectedLabel == 'Open PO') return p['isPreOrder'] == true;
      return p['category'] == selectedLabel;
    }).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return _buildProductCard(filteredProducts[index]);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    bool isPO = product['isPreOrder'] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPO ? const Color(0xFFD1FAE5) : const Color(0xFFF3F4F6),
          width: isPO ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    product['image'],
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (isPO)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'PRE-ORDER',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                if (isPO) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product['progressLabel'],
                        style: const TextStyle(fontSize: 10, color: Color(0xFFF97316), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: product['progress'],
                      backgroundColor: const Color(0xFFFFEDD5),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF97316)),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Est. Ready: ${product['estReady']}',
                    style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _formatCurrency(product['price']),
                        style: const TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold, 
                          color: Color(0xFF14A96B)
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14A96B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
