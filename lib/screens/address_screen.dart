import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddressScreen extends StatefulWidget {
  final int userId;

  // false = halaman "Alamat Saya"
  // true  = halaman untuk memilih alamat saat checkout
  final bool pilihAlamat;

  const AddressScreen({
    super.key,
    required this.userId,
    this.pilihAlamat = false,
  });

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  List<dynamic> addresses = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });

    final data = await ApiService.getAddresses(widget.userId);

    if (!mounted) return;

    setState(() {
      addresses = data;
      loading = false;
    });
  }

  String addressText(Map<String, dynamic> address) {
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

  Future<void> showAddAddressDialog() async {
    final labelController = TextEditingController();
    final alamatController = TextEditingController();
    final kotaController = TextEditingController();
    final kodeposController = TextEditingController();

    bool alamatUtama = addresses.isEmpty;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Alamat'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: labelController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Label Alamat',
                        hintText: 'Contoh: Rumah',
                        prefixIcon: Icon(Icons.label_outline),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: alamatController,
                      maxLines: 3,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Alamat Lengkap',
                        prefixIcon: Icon(
                          Icons.location_on_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: kotaController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Kota',
                        prefixIcon: Icon(
                          Icons.location_city_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: kodeposController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Kode Pos',
                        prefixIcon: Icon(
                          Icons.markunread_mailbox_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Jadikan alamat utama',
                      ),
                      value: alamatUtama,
                      onChanged: saving
                          ? null
                          : (value) {
                              setDialogState(() {
                                alamatUtama = value ?? false;
                              });
                            },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Batal'),
                ),

                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final label =
                              labelController.text.trim();

                          final alamat =
                              alamatController.text.trim();

                          final kota =
                              kotaController.text.trim();

                          final kodepos =
                              kodeposController.text.trim();

                          if (label.isEmpty ||
                              alamat.isEmpty ||
                              kota.isEmpty) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Label, alamat, dan kota wajib diisi.',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            saving = true;
                          });

                          final result =
                              await ApiService.addAddress(
                            userId: widget.userId,
                            labelAlamat: label,
                            alamatLengkap: alamat,
                            kota: kota,
                            kodepos: kodepos,
                            isUtama: alamatUtama ? 1 : 0,
                          );

                          if (!mounted) return;

                          if (result['status'] == 'success') {
                            Navigator.pop(dialogContext);

                            await loadAddresses();

                            if (!mounted) return;

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Alamat berhasil ditambahkan.',
                                ),
                              ),
                            );
                          } else {
                            setDialogState(() {
                              saving = false;
                            });

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  result['message']
                                          ?.toString() ??
                                      'Gagal menambahkan alamat.',
                                ),
                              ),
                            );
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    labelController.dispose();
    alamatController.dispose();
    kotaController.dispose();
    kodeposController.dispose();
  }

  void pilihAlamat(Map<String, dynamic> address) {
    // Kembalikan data alamat ke halaman sebelumnya.
    Navigator.pop(context, address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pilihAlamat
              ? 'Pilih Alamat Pengiriman'
              : 'Alamat Saya',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loading ? null : loadAddresses,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      // Tombol tambah tetap tersedia di halaman
      // Alamat Saya.
      floatingActionButton: widget.pilihAlamat
          ? null
          : FloatingActionButton.extended(
              onPressed: showAddAddressDialog,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Alamat'),
            ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : addresses.isEmpty
              ? RefreshIndicator(
                  onRefresh: loadAddresses,
                  child: ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 160),
                      Icon(
                        Icons.location_on_outlined,
                        size: 70,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 15),
                      Center(
                        child: Text(
                          'Belum ada alamat.',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadAddresses,
                  child: ListView.builder(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      final address =
                          Map<String, dynamic>.from(
                        addresses[index],
                      );

                      final label =
                          address['label_alamat']
                                  ?.toString() ??
                              'Alamat';

                      final isUtama =
                          address['is_utama']?.toString() ==
                              '1';

                      final alamatLengkap =
                          addressText(address);

                      final isKantor =
                          label.toLowerCase() == 'kantor';

                      return Card(
                        margin:
                            const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: widget.pilihAlamat
                              ? () {
                                  pilihAlamat(address);
                                }
                              : null,
                          child: Padding(
                            padding:
                                const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      child: Icon(
                                        isKantor
                                            ? Icons.business
                                            : Icons.home,
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Text(
                                        label,
                                        style:
                                            const TextStyle(
                                          fontSize: 17,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    if (isUtama)
                                      Container(
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration:
                                            BoxDecoration(
                                          borderRadius:
                                              BorderRadius
                                                  .circular(12),
                                          color: Colors.green
                                              .withValues(
                                            alpha: 0.15,
                                          ),
                                        ),
                                        child: const Text(
                                          'UTAMA',
                                          style: TextStyle(
                                            color:
                                                Colors.green,
                                            fontSize: 11,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  alamatLengkap,
                                  style: const TextStyle(
                                    height: 1.4,
                                    fontSize: 15,
                                  ),
                                ),

                                // Tampilkan petunjuk ketika
                                // halaman sedang digunakan
                                // untuk memilih alamat.
                                if (widget.pilihAlamat) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.end,
                                    children: const [
                                      Icon(
                                        Icons.touch_app_outlined,
                                        size: 18,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'Pilih alamat ini',
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
