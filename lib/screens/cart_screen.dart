import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulasi data keranjang (Nanti bisa diganti dengan state management seperti Provider/GetX)
    final List<Map<String, dynamic>> cartItems = [
      {'nama': 'Produk Contoh 1', 'harga': 50000},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang Belanja')),
      body: cartItems.isEmpty
          ? const Center(child: Text('Keranjang Anda kosong.'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        title: Text(item['nama']),
                        subtitle: Text('Rp ${item['harga']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Tambahkan logika hapus item di sini
                          },
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Checkout Berhasil!')),
                      );
                    },
                    child: const Text('Checkout Sekarang'),
                  ),
                ),
              ],
            ),
    );
  }
}

