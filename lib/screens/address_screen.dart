import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddressScreen extends StatefulWidget {
  final int userId;
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Text(
                'Tambah Alamat',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: labelController,
                      textInputAction:
                          TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Label Alamat',
                        hintText: 'Contoh: Rumah',
                        prefixIcon: const Icon(
                          Icons.label_outline_rounded,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: alamatController,
                      maxLines: 3,
                      textInputAction:
                          TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Alamat Lengkap',
                        prefixIcon: const Icon(
                          Icons.location_on_outlined,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: kotaController,
                      textInputAction:
                          TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Kota',
                        prefixIcon: const Icon(
                          Icons.location_city_outlined,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: kodeposController,
                      keyboardType:
                          TextInputType.number,
                      textInputAction:
                          TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Kode Pos',
                        prefixIcon: const Icon(
                          Icons.markunread_mailbox_outlined,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Jadikan alamat utama',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      value: alamatUtama,
                      onChanged: saving
                          ? null
                          : (value) {
                              setDialogState(() {
                                alamatUtama =
                                    value ?? false;
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
                          Navigator.pop(
                            dialogContext,
                          );
                        },
                  child: const Text('Batal'),
                ),

                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final label =
                              labelController.text
                                  .trim();

                          final alamat =
                              alamatController.text
                                  .trim();

                          final kota =
                              kotaController.text
                                  .trim();

                          final kodepos =
                              kodeposController.text
                                  .trim();

                          if (label.isEmpty ||
                              alamat.isEmpty ||
                              kota.isEmpty) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
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
                            isUtama:
                                alamatUtama ? 1 : 0,
                          );

                          if (!mounted) return;

                          if (result['status'] ==
                              'success') {
                            Navigator.pop(
                              dialogContext,
                            );

                            await loadAddresses();

                            if (!mounted) return;

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
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

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
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
                      : const Text(
                          'Simpan',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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

  void pilihAlamat(
    Map<String, dynamic> address,
  ) {
    Navigator.pop(context, address);
  }

  Widget buildAddressCard(
    BuildContext context,
    Map<String, dynamic> address,
  ) {
    final theme = Theme.of(context);

    final label =
        address['label_alamat']?.toString() ??
            'Alamat';

    final isUtama =
        address['is_utama']?.toString() == '1';

    final isKantor =
        label.toLowerCase() == 'kantor';

    final detail = addressText(address);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUtama
              ? theme.colorScheme.primary
              : Colors.grey.shade200,
          width: isUtama ? 1.7 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: widget.pilihAlamat
            ? () => pilihAlamat(address)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: theme
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.10),
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                    child: Icon(
                      isKantor
                          ? Icons.business_rounded
                          : Icons.home_rounded,
                      color:
                          theme.colorScheme.primary,
                      size: 27,
                    ),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            label,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ),

                        if (isUtama) ...[
                          const SizedBox(width: 8),

                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.green.shade50,
                              borderRadius:
                                  BorderRadius.circular(
                                20,
                              ),
                            ),
                            child: Text(
                              'UTAMA',
                              style: TextStyle(
                                color:
                                    Colors.green.shade700,
                                fontSize: 10,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (widget.pilihAlamat)
                    Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isUtama
                              ? Colors.green
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                        color: isUtama
                            ? Colors.green
                            : Colors.transparent,
                      ),
                      child: isUtama
                          ? const Icon(
                              Icons.check,
                              size: 15,
                              color: Colors.white,
                            )
                          : null,
                    ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 21,
                    color: Colors.grey.shade600,
                  ),

                  const SizedBox(width: 9),

                  Expanded(
                    child: Text(
                      detail,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color:
                            Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),

              if (widget.pilihAlamat) ...[
                const SizedBox(height: 17),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        pilihAlamat(address),
                    icon: const Icon(
                      Icons
                          .local_shipping_outlined,
                      size: 20,
                    ),
                    label: const Text(
                      'Pilih Alamat Ini',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
@override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            const Color(0xFFF8F7FB),
        surfaceTintColor:
            Colors.transparent,

        title: Text(
          widget.pilihAlamat
              ? 'Pilih Alamat Pengiriman'
              : 'Alamat Saya',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 21,
          ),
        ),

        actions: [
          IconButton(
            onPressed:
                loading ? null : loadAddresses,
            tooltip: 'Refresh',
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),

      body: loading
          ? Center(
              child:
                  CircularProgressIndicator(
                color:
                    theme.colorScheme.primary,
              ),
            )
          : RefreshIndicator(
              onRefresh: loadAddresses,

              child: addresses.isEmpty
                  ? ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding:
                          const EdgeInsets.all(20),
                      children: [
                        const SizedBox(height: 90),

                        Center(
                          child: Container(
                            width: 105,
                            height: 105,
                            decoration:
                                BoxDecoration(
                              color: theme
                                  .colorScheme
                                  .primary
                                  .withValues(
                                alpha: 0.10,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons
                                  .location_on_outlined,
                              size: 52,
                              color: theme
                                  .colorScheme
                                  .primary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        const Center(
                          child: Text(
                            'Belum ada alamat',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Center(
                          child: Text(
                            'Tambahkan alamat pengiriman\n'
                            'agar proses checkout lebih mudah.',
                            textAlign:
                                TextAlign.center,
                            style: TextStyle(
                              color:
                                  Colors.grey.shade600,
                              height: 1.5,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          height: 52,
                          child:
                              ElevatedButton.icon(
                            onPressed:
                                showAddAddressDialog,
                            icon: const Icon(
                              Icons.add_rounded,
                            ),
                            label: const Text(
                              'Tambah Alamat Baru',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                            style:
                                ElevatedButton.styleFrom(
                              elevation: 0,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics:
                          const AlwaysScrollableScrollPhysics(),

                      padding:
                          const EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        110,
                      ),

                      itemCount:
                          addresses.length + 1,

                      itemBuilder:
                          (context, index) {
                        if (index == 0) {
                          return Container(
                            margin:
                                const EdgeInsets.only(
                              bottom: 16,
                            ),
                            padding:
                                const EdgeInsets.all(16),
                            decoration:
                                BoxDecoration(
                              color:
                                  theme
                                      .colorScheme
                                      .primary
                                      .withValues(
                                alpha: 0.07,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                16,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons
                                      .local_shipping_outlined,
                                  color:
                                      theme
                                          .colorScheme
                                          .primary,
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Text(
                                    widget.pilihAlamat
                                        ? 'Pilih alamat yang akan digunakan untuk pengiriman pesanan.'
                                        : 'Kelola alamat pengiriman Anda di sini.',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      height: 1.4,
                                      color:
                                          Colors
                                              .grey
                                              .shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final address =
                            Map<String, dynamic>.from(
                          addresses[index - 1],
                        );

                        return buildAddressCard(
                          context,
                          address,
                        );
                      },
                    ),
            ),

      floatingActionButton:
          widget.pilihAlamat
              ? null
              : FloatingActionButton.extended(
                  onPressed:
                      showAddAddressDialog,
                  elevation: 3,
                  icon: const Icon(
                    Icons.add_rounded,
                  ),
                  label: const Text(
                    'Tambah Alamat',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
    );
  }
}
