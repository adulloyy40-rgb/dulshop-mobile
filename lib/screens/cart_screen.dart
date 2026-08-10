import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CartScreen extends StatefulWidget {
  final int userId;

  const CartScreen({
    super.key,
    required this.userId,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> cartItems = [];
  double totalHarga = 0;
  bool loading = true;
  bool checkoutLoading = false;

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });

    final result = await ApiService.getCart(widget.userId);

    if (!mounted) return;

    if (result['status'] == 'success') {
      final data = result['data'];

      setState(() {
        cartItems = data?['items'] ?? [];

        totalHarga =
            double.tryParse(
              data?['total_harga']?.toString() ?? '0',
            ) ??
            0;

        loading = false;
      });
    } else {
      setState(() {
        cartItems = [];
        totalHarga = 0;
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ??
                'Gagal mengambil keranjang.',
          ),
        ),
      );
    }
  }

  String formatPrice(dynamic price) {
    final value = double.tryParse(price.toString()) ?? 0;

    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
        )}';
  }

  Future<void> checkout() async {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang masih kosong.'),
        ),
      );
      return;
    }

    setState(() {
      checkoutLoading = true;
    });

    final result = await ApiService.createOrder(
      userId: widget.userId,
      alamatPengiriman: 'Alamat default',
      biayaPengiriman: 0,
    );

    if (!mounted) return;

    setState(() {
      checkoutLoading = false;
    });

    if (result['status'] == 'success') {
      final data = result['data'] ?? {};

      final invoice =
          data['kode_invoice']?.toString() ?? '-';

      final total =
          data['total_harga'] ?? totalHarga;

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Checkout Berhasil'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(
                    Icons.check_circle,
                    size: 70,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Invoice: $invoice',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: ${formatPrice(total)}',
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pesanan berhasil dibuat.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      await loadCart();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ??
                'Checkout gagal.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Keranjang Belanja',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: loading ? null : loadCart,
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : cartItems.isEmpty
              ? RefreshIndicator(
                  onRefresh: loadCart,
                  child: ListView(
                    children: const [
                      SizedBox(height: 180),
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 70,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 15),
                            Text(
                              'Keranjang Anda kosong.',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: loadCart,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];

                            final nama =
                                item['nama_produk']?.toString() ??
                                    'Produk';

                            final harga =
                                item['harga'] ?? 0;

                            final quantity =
                                int.tryParse(
                                      item['quantity']
                                              ?.toString() ??
                                          '1',
                                    ) ??
                                    1;

                            final subtotal =
                                (double.tryParse(
                                          harga.toString(),
                                        ) ??
                                        0) *
                                    quantity;

                            return Card(
                              margin: const EdgeInsets.only(
                                bottom: 12,
                              ),
                              child: ListTile(
                                contentPadding:
                                    const EdgeInsets.all(12),
                                leading: const CircleAvatar(
                                  child: Icon(
                                    Icons.shopping_bag,
                                  ),
                                ),
                                title: Text(
                                  nama,
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    top: 8,
                                  ),
                                  child: Text(
                                    '${formatPrice(harga)} × $quantity',
                                  ),
                                ),
                                trailing: Text(
                                  formatPrice(subtotal),
                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surface,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                const Text(
                                  'Total Harga',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  formatPrice(totalHarga),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    checkoutLoading
                                        ? null
                                        : checkout,
                                child: checkoutLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Checkout Sekarang',
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
