import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'cart_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;

  const HomeScreen({
    super.key,
    required this.userId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }

    final data = await ApiService.getProducts();

    if (!mounted) return;

    setState(() {
      products = data;
      loading = false;
    });
  }

  String formatPrice(dynamic price) {
    final value = double.tryParse(price.toString()) ?? 0;

    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
        )}';
  }

  Future<void> addProductToCart(
    Map<String, dynamic> product,
  ) async {
    final productId = int.tryParse(
      product['id']?.toString() ?? '',
    );

    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID produk tidak valid.'),
        ),
      );
      return;
    }

    final stok = int.tryParse(
          product['stok']?.toString() ?? '0',
        ) ??
        0;

    if (stok <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stok produk habis.'),
        ),
      );
      return;
    }

    final result = await ApiService.addToCart(
      userId: widget.userId,
      productId: productId,
      quantity: 1,
    );

    if (!mounted) return;

    final success = result['status'] == 'success';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message']?.toString() ??
              (success
                  ? 'Produk berhasil ditambahkan ke keranjang.'
                  : 'Gagal menambahkan produk.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dulshop',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: loadProducts,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Pengaturan',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );

              loadProducts();
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
            ),
            tooltip: 'Keranjang',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(
                    userId: widget.userId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadProducts,
        child: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : products.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 150),
                      Center(
                        child: Text(
                          'Belum ada produk.',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];

                      final nama =
                          product['nama_produk']?.toString() ??
                              'Produk';

                      final harga = product['harga'] ?? 0;

                      final gambar =
                          product['url_gambar']?.toString() ?? '';

                      final stok =
                          product['stok']?.toString() ?? '0';

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: 2,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: gambar.isNotEmpty
                                  ? Image.network(
                                      gambar,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                          ),
                                        );
                                      },
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.image,
                                        size: 50,
                                      ),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nama,
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    formatPrice(harga),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Stok: $stok',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        addProductToCart(product);
                                      },
                                      icon: const Icon(
                                        Icons.add_shopping_cart,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'Tambah',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
