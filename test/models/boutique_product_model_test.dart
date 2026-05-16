import 'package:flutter_test/flutter_test.dart';
import 'package:hijapp/core/models/boutique_product_model.dart';

void main() {
  group('BoutiqueProductModel', () {
    test('default values are sane', () {
      final m = BoutiqueProductModel(
        id: 'p1',
        boutiqueId: 'b1',
        name: 'Bordo Sal',
        imageUrl: 'https://example.com/p.jpg',
      );
      expect(m.tryOnCount, 0);
      expect(m.last30DaysCount, 0);
      expect(m.category, 'esarp');
      expect(m.isActive, true);
      expect(m.sortOrder, 0);
    });

    test('toFirestore round-trips known fields', () {
      final m = BoutiqueProductModel(
        id: 'p1',
        boutiqueId: 'b1',
        name: 'Bordo Sal',
        imageUrl: 'https://example.com/p.jpg',
        category: 'sal',
        boutiqueWebsiteUrl: 'https://shop.example.com/sal',
        tryOnCount: 42,
        last30DaysCount: 7,
        sortOrder: 3,
      );
      final json = m.toFirestore();
      expect(json['boutiqueId'], 'b1');
      expect(json['category'], 'sal');
      expect(json['tryOnCount'], 42);
      expect(json['last30DaysCount'], 7);
      expect(json['boutiqueWebsiteUrl'], 'https://shop.example.com/sal');
      // Spec v2: price ve purchaseUrl artik yok
      expect(json.containsKey('price'), isFalse);
      expect(json.containsKey('purchaseUrl'), isFalse);
    });

    test('copyWith preserves id and updates fields', () {
      final m = BoutiqueProductModel(
        id: 'p1',
        boutiqueId: 'b1',
        name: 'Orig',
        imageUrl: 'u',
      );
      final n = m.copyWith(name: 'Updated', tryOnCount: 5);
      expect(n.id, 'p1');
      expect(n.boutiqueId, 'b1');
      expect(n.name, 'Updated');
      expect(n.tryOnCount, 5);
      expect(n.imageUrl, 'u');
    });
  });
}
