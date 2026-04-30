import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import 'cart_page.dart';

class ShopPage extends StatefulWidget {
  final bool isStatic;
  final int initialCategoryIndex;
  const ShopPage({super.key, this.isStatic = false, this.initialCategoryIndex = 0});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  late int _selectedCategoryIndex;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _selectedCategoryIndex = widget.initialCategoryIndex;
  }

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Semua', 'icon': Icons.grid_view_rounded},
    {'name': 'Sparepart', 'icon': Icons.settings_suggest_rounded},
    {'name': 'Sembako', 'icon': Icons.shopping_basket_rounded},
    {'name': 'Elektronik', 'icon': Icons.ev_station_rounded},
    {'name': 'ATK', 'icon': Icons.edit_note_rounded},
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Ban Motor Tubeless 90/90',
      'price': 255000.0,
      'image': 'assets/images/banmotor.jpg',
      'isPO': true,
      'progress': 0.3,
      'est': '12 Mei',
      'category': 'Sparepart',
      'desc': 'Ban kualitas tinggi untuk motor matic.',
    },
    {
      'name': 'Oli Mesin 1L Sintetik',
      'price': 65000.0,
      'image': 'assets/images/olimesin.jpg',
      'isPO': false,
      'category': 'Sparepart',
      'desc': 'Pelumas mesin teknologi terbaru.',
    },
    {
      'name': 'Aki Kering MF 12V',
      'price': 210000.0,
      'image': 'assets/images/akikering.jpg',
      'isPO': true,
      'progress': 0.15,
      'est': '15 Mei',
      'category': 'Sparepart',
      'desc': 'Aki bebas perawatan dengan daya tahan lama.',
    },
    {
      'name': 'Kampas Rem Depan',
      'price': 35000.0,
      'image': 'assets/images/kampasrem.jpg',
      'isPO': false,
      'category': 'Sparepart',
      'desc': 'Kampas rem pakem dan tahan panas.',
    },
    {
      'name': 'Beras Premium 5kg',
      'price': 75000.0,
      'image': 'assets/images/beraspremium.jpg',
      'isPO': false,
      'category': 'Sembako',
      'desc': 'Beras kualitas super, pulen dan bersih.',
    },
    {
      'name': 'Minyak Goreng 2L',
      'price': 35000.0,
      'image': 'assets/images/minyakgoreng.jpg',
      'isPO': false,
      'category': 'Sembako',
      'desc': 'Minyak nabati jernih, tahan panas.',
    },
    {
      'name': 'Smart TV 43 inch',
      'price': 4500000.0,
      'image': 'assets/images/smarttv.jpg',
      'isPO': true,
      'progress': 0.65,
      'est': '15 Mei',
      'category': 'Elektronik',
      'desc': 'TV LED 4K dengan fitur Smart Android.',
    },
    {
      'name': 'Kulkas 2 Pintu',
      'price': 3200000.0,
      'image': 'assets/images/kulkas2pintu.jpg',
      'isPO': true,
      'progress': 0.85,
      'est': '10 Mei',
      'category': 'Elektronik',
      'desc': 'Hemat listrik dengan teknologi inverter.',
    },
    {
      'name': 'Gula Pasir 1kg',
      'price': 15000.0,
      'image': 'assets/images/gulapasir.jpg',
      'isPO': false,
      'category': 'Sembako',
      'desc': 'Gula kristal putih murni.',
    },
    {
      'name': 'Mesin Cuci 8kg',
      'price': 2800000.0,
      'image': 'assets/images/mesincuci.jpg',
      'isPO': true,
      'progress': 0.45,
      'est': '20 Mei 2026',
      'category': 'Elektronik',
      'desc': 'Cucian bersih maksimal dengan turbo drum.',
    },
    {
      'name': 'Kopi Bubuk 250gr',
      'price': 28000.0,
      'image': 'assets/images/kopibubuk.jpg',
      'isPO': false,
      'category': 'Sembako',
      'desc': 'Kopi robusta asli dengan aroma nikmat.',
    },
    {
      'name': 'Air Purifier',
      'price': 1500000.0,
      'image': 'assets/images/airpurifier.jpg',
      'isPO': true,
      'progress': 0.92,
      'est': '05 Mei 2026',
      'category': 'Elektronik',
      'desc': 'Udara bersih bebas kuman di rumah Anda.',
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    String category = _categories[_selectedCategoryIndex]['name'];
    return _products.where((p) {
      bool matchCategory = category == 'Semua' || p['category'] == category;
      bool matchSearch = p['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  void _buyProduct(Map<String, dynamic> product) {
    final authProvider = context.read<AuthProvider>();
    int quantity = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final double totalPrice = product['price'] * quantity;
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(product['image'], width: 100, height: 100, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatCurrency(product['price']),
                            style: const TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                          const SizedBox(height: 4),
                          Text('Stok: 99+', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(product['name'], style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Jumlah', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: quantity > 1 ? () => setModalState(() => quantity--) : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: () => setModalState(() => quantity++),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Pembayaran', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text(_formatCurrency(totalPrice), style: const TextStyle(color: Color(0xFF14A96B), fontWeight: FontWeight.bold, fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            context.read<CartProvider>().addItem(
                              product['name'], // Gunakan nama sebagai ID untuk dummy
                              product['name'],
                              product['price'],
                              product['image'],
                              quantity,
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product['name']} ditambahkan ke keranjang'),
                                backgroundColor: const Color(0xFF0284C7),
                                duration: const Duration(seconds: 3),
                                action: SnackBarAction(
                                  label: 'LIHAT',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const CartPage()),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF0284C7)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Keranjang', style: TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            final success = authProvider.purchase(
                              totalPrice,
                              items: ['${product['name']} x$quantity'],
                              type: product['isPO'] ? 'OPEN PO METEMA' : 'BELANJA TOKO',
                            );
                            _showStatusDialog(success, product['name']);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text('Beli Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showStatusDialog(bool isSuccess, String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              color: isSuccess ? const Color(0xFF14A96B) : const Color(0xFFEF4444),
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              isSuccess ? 'Pembelian Berhasil!' : 'Pembelian Gagal',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              isSuccess
                  ? 'Selamat! $productName telah berhasil dibeli menggunakan limit Anda.'
                  : 'Maaf, limit belanja Anda tidak mencukupi untuk melakukan transaksi ini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSuccess ? const Color(0xFF14A96B) : const Color(0xFF0284C7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Tutup', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: !widget.isStatic,
        toolbarHeight: 70,
        title: _buildSearchHeader(),
        actions: [
          _buildCartBadge(),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryList(),
          _buildLimitInfo(user?.sisaLimit ?? 0),
          Expanded(
            child: _filteredProducts.isEmpty ? _buildEmptyState() : _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Cari barang di toko...',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildCartBadge() {
    return Center(
      child: Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF1E293B), size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
          ),
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              if (cart.itemCount == 0) return const SizedBox.shrink();
              return Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '${cart.itemCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(_categories[index]['name']),
              avatar: Icon(
                _categories[index]['icon'],
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedCategoryIndex = index),
              selectedColor: const Color(0xFF0284C7),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade200),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLimitInfo(double sisaLimit) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF84CC16), size: 20),
          const SizedBox(width: 12),
          const Text('Sisa Limit Anda:', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const Spacer(),
          Text(_formatCurrency(sisaLimit), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Produk tidak ditemukan', style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Coba cari dengan kata kunci lain', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) => _buildProductCard(_filteredProducts[index]),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    bool isPO = product['isPO'];
    return GestureDetector(
      onTap: () => _buyProduct(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.asset(
                        product['image'],
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade100,
                          child: Icon(Icons.image_not_supported_rounded, color: Colors.grey.shade400, size: 40),
                        ),
                      ),
                    ),
                  ),
                  if (isPO)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(8)),
                        child: const Text('PRE-ORDER', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product['category'], style: const TextStyle(color: Color(0xFF0284C7), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text(_formatCurrency(product['price']), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                  if (isPO) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(value: product['progress'], backgroundColor: Colors.grey.shade100, valueColor: const AlwaysStoppedAnimation(Color(0xFF84CC16)), minHeight: 4),
                    ),
                    const SizedBox(height: 4),
                    Text('Est. ${product['est']}', style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => _buyProduct(product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPO ? const Color(0xFFF1F5F9) : const Color(0xFF0284C7),
                        foregroundColor: isPO ? const Color(0xFF475569) : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(isPO ? 'Pesan PO' : 'Beli', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
