import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker_web/image_picker_web.dart';
import '../../app/theme.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _fs = FirebaseFirestore.instance;
  String? _boutiqueId;
  List<QueryDocumentSnapshot> _products = [];
  bool _loading = true;
  bool _isGridView = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;
    final bq = await _fs.collection('boutiques').where('email', isEqualTo: email).limit(1).get();
    if (bq.docs.isEmpty) { setState(() => _loading = false); return; }
    _boutiqueId = bq.docs.first.id;
    final pq = await _fs.collection('boutique_products')
        .where('boutiqueId', isEqualTo: _boutiqueId)
        .orderBy('sortOrder')
        .get();
    setState(() { _products = pq.docs; _loading = false; });
  }

  void _showAddEditDialog({QueryDocumentSnapshot? doc}) {
    final data = doc?.data() as Map<String, dynamic>?;
    final nameCtrl = TextEditingController(text: data?['name'] ?? '');
    final descCtrl = TextEditingController(text: data?['description'] ?? '');
    final imageCtrl = TextEditingController(text: data?['imageUrl'] ?? '');
    final priceCtrl = TextEditingController(text: data?['price'] ?? '');
    final urlCtrl = TextEditingController(text: data?['purchaseUrl'] ?? '');
    bool uploading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(doc == null ? 'Ürün Ekle' : 'Ürünü Düzenle',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Ürün Adı')),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Ürün Açıklaması',
                      hintText: 'Ürün hakkında kısa bir açıklama...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Görsel: URL veya Yükleme
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: imageCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Görsel URL',
                            hintText: 'https://...',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: uploading ? null : () async {
                          setDialogState(() => uploading = true);
                          try {
                            final imageData = await ImagePickerWeb.getImageAsBytes();
                            if (imageData != null && _boutiqueId != null) {
                              final url = await _uploadImage(imageData);
                              if (url != null) {
                                imageCtrl.text = url;
                              }
                            }
                          } catch (_) {}
                          setDialogState(() => uploading = false);
                        },
                        icon: uploading
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.upload_file, size: 18),
                        label: Text(uploading ? 'Yükleniyor...' : 'Yükle'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                  // Görsel önizleme
                  if (imageCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageCtrl.text,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 60,
                          color: AdminTheme.border,
                          child: const Center(child: Icon(Icons.broken_image_outlined)),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Fiyat (örn: 249 TL)')),
                  const SizedBox(height: 12),
                  TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: 'Satın Alma Linki')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty || _boutiqueId == null) return;
                final payload = <String, dynamic>{
                  'boutiqueId': _boutiqueId,
                  'name': nameCtrl.text.trim(),
                  'description': descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                  'imageUrl': imageCtrl.text.trim(),
                  'price': priceCtrl.text.trim(),
                  'purchaseUrl': urlCtrl.text.trim(),
                  'isActive': true,
                  'sortOrder': _products.length,
                  'updatedAt': FieldValue.serverTimestamp(),
                };
                if (doc == null) {
                  payload['createdAt'] = FieldValue.serverTimestamp();
                  await _fs.collection('boutique_products').add(payload);
                } else {
                  await _fs.collection('boutique_products').doc(doc.id).update(payload);
                }
                if (mounted) { Navigator.pop(ctx); _load(); }
              },
              child: Text(doc == null ? 'Ekle' : 'Güncelle'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _uploadImage(Uint8List imageData) async {
    if (_boutiqueId == null) return null;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = FirebaseStorage.instance
        .ref()
        .child('boutique_products/$_boutiqueId/$timestamp.jpg');
    final uploadTask = await ref.putData(imageData, SettableMetadata(contentType: 'image/jpeg'));
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> _delete(String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ürünü Sil', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: const Text('Bu ürünü silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _fs.collection('boutique_products').doc(docId).delete();
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ürünler', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AdminTheme.textPrimary)),
                  Text('Butik ürün vitrinini yönetin', style: GoogleFonts.inter(fontSize: 14, color: AdminTheme.textSecondary)),
                ],
              )),
              // View toggle
              IconButton(
                onPressed: () => setState(() => _isGridView = !_isGridView),
                icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view, color: AdminTheme.textSecondary),
                tooltip: _isGridView ? 'Liste Görünümü' : 'Vitrin Görünümü',
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showAddEditDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ürün Ekle'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_loading)
            const Center(child: CircularProgressIndicator(color: AdminTheme.primary))
          else if (_products.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.all(60),
              child: Column(children: [
                const Icon(Icons.inventory_2_outlined, size: 64, color: AdminTheme.textSecondary),
                const SizedBox(height: 16),
                Text('Henüz ürün eklemedin', style: GoogleFonts.inter(color: AdminTheme.textSecondary, fontSize: 16)),
                const SizedBox(height: 8),
                Text('Vitrine ürün ekleyerek müşterilerine göster', style: GoogleFonts.inter(color: AdminTheme.textSecondary, fontSize: 13)),
              ]),
            ))
          else
            Expanded(
              child: _isGridView ? _buildGridView() : _buildListView(),
            ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        childAspectRatio: 0.68,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _products.length,
      itemBuilder: (_, i) {
        final doc = _products[i];
        final data = doc.data() as Map<String, dynamic>;
        final name = data['name'] as String? ?? '';
        final imageUrl = data['imageUrl'] as String? ?? '';
        final price = data['price'] as String? ?? '';
        final description = data['description'] as String? ?? '';

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: imageUrl.isNotEmpty
                      ? Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity,
                          errorBuilder: (_, __, ___) => Container(color: AdminTheme.border,
                              child: const Center(child: Icon(Icons.broken_image_outlined, color: AdminTheme.textSecondary))))
                      : Container(color: AdminTheme.border,
                          child: const Center(child: Icon(Icons.image_outlined, size: 40, color: AdminTheme.textSecondary))),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(description, style: GoogleFonts.inter(fontSize: 12, color: AdminTheme.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                      if (price.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(price, style: GoogleFonts.inter(fontSize: 13, color: AdminTheme.primary, fontWeight: FontWeight.w600)),
                      ],
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(child: OutlinedButton(
                            onPressed: () => _showAddEditDialog(doc: doc),
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 6)),
                            child: const Text('Düzenle', style: TextStyle(fontSize: 12)),
                          )),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _delete(doc.id),
                            icon: const Icon(Icons.delete_outline, size: 18, color: AdminTheme.error),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      itemCount: _products.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final doc = _products[i];
        final data = doc.data() as Map<String, dynamic>;
        final name = data['name'] as String? ?? '';
        final imageUrl = data['imageUrl'] as String? ?? '';
        final price = data['price'] as String? ?? '';
        final description = data['description'] as String? ?? '';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 56,
                height: 56,
                child: imageUrl.isNotEmpty
                    ? Image.network(imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: AdminTheme.border, child: const Icon(Icons.broken_image_outlined, size: 20)))
                    : Container(color: AdminTheme.border, child: const Icon(Icons.image_outlined, size: 20)),
              ),
            ),
            title: Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (description.isNotEmpty)
                  Text(description, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 12, color: AdminTheme.textSecondary)),
                if (price.isNotEmpty)
                  Text(price, style: GoogleFonts.inter(fontSize: 13, color: AdminTheme.primary, fontWeight: FontWeight.w600)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _showAddEditDialog(doc: doc),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                ),
                IconButton(
                  onPressed: () => _delete(doc.id),
                  icon: const Icon(Icons.delete_outline, size: 18, color: AdminTheme.error),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
