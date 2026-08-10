import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  final Map<String, dynamic> address;
  final List<dynamic> cartItems;
  final double totalHarga;
  final String Function(dynamic) formatPrice;
  final Future<void> Function() onCreateOrder;

  const CheckoutScreen({
    super.key,
    required this.address,
    required this.cartItems,
    required this.totalHarga,
    required this.formatPrice,
    required this.onCreateOrder,
  });

  String addressText() {
    final alamat =
        address['alamat_lengkap']?.toString() ?? '';

    final kota =
        address['kota']?.toString() ?? '';

    final kodepos =
        address['kodepos']?.toString() ?? '';

    return [
      alamat,
      kota,
      if (kodepos.isNotEmpty) kodepos,
    ].join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.only(
          bottom: 100,
        ),
        children: [
          // =========================
          // ALAMAT PENGIRIMAN
          // =========================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.red,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Alamat Pengiriman',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            address['label_alamat']
                                    ?.toString() ??
                                'Alamat',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            addressText(),
                            style: const TextStyle(
                              height: 1.4,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // =========================
          // PRODUK
          // =========================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Produk',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                ...cartItems.map(
                  (item) {
                    final nama =
                        item['nama_produk']
                                ?.toString() ??
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

                    final hargaDouble =
                        double.tryParse(
                              harga.toString(),
                            ) ??
                            0;

                    final subtotal =
                        hargaDouble * quantity;

                    return Container(
                      margin:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      padding:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      decoration:
                          const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFE5E5E5),
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration:
                                BoxDecoration(
                              color: const Color(
                                0xFFF1F1F1,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                8,
                              ),
                            ),
                            child: const Icon(
                              Icons
                                  .shopping_bag_outlined,
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nama,
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  '${formatPrice(harga)} × $quantity',
                                  style:
                                      const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          Text(
                            formatPrice(subtotal),
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // =========================
          // RINGKASAN PEMBAYARAN
          // =========================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Ringkasan Pembayaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Produk',
                    ),
                    Text(
                      formatPrice(totalHarga),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                const Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Biaya Pengiriman',
                    ),
                    Text(
                      'Rp 0',
                    ),
                  ],
                ),

                const Padding(
                  padding:
                      EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  child: Divider(
                    height: 1,
                  ),
                ),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formatPrice(totalHarga),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),

      // =========================
      // BOTTOM CHECKOUT
      // =========================
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                offset: Offset(0, -2),
                color: Colors.black12,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      formatPrice(totalHarga),
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: onCreateOrder,
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Buat Pesanan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
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
