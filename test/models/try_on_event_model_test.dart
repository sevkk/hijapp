import 'package:flutter_test/flutter_test.dart';
import 'package:hijapp/core/models/try_on_event_model.dart';

void main() {
  group('TryOnUserTypeX', () {
    test('wire round-trips enum values', () {
      for (final v in TryOnUserType.values) {
        expect(TryOnUserTypeX.fromWire(v.wire), v);
      }
    });

    test('fromWire unknown returns free (default)', () {
      expect(TryOnUserTypeX.fromWire('garbage'), TryOnUserType.free);
      expect(TryOnUserTypeX.fromWire(null), TryOnUserType.free);
    });
  });

  group('TryOnEventModel', () {
    test('toFirestore serializes user type via wire', () {
      final m = TryOnEventModel(
        id: 'e1',
        boutiqueId: 'b1',
        productId: 'p1',
        userId: 'u1',
        userType: TryOnUserType.referral,
        referralCodeId: 'c1',
        succeeded: true,
        costUsd: 0.01,
      );
      final json = m.toFirestore();
      expect(json['boutiqueId'], 'b1');
      expect(json['productId'], 'p1');
      expect(json['userType'], 'referral');
      expect(json['succeeded'], true);
      expect(json['costUsd'], 0.01);
      expect(json['errorMessage'], isNull);
    });

    test('errorMessage included when failed', () {
      final m = TryOnEventModel(
        id: 'e1',
        boutiqueId: 'b1',
        productId: 'p1',
        succeeded: false,
        errorMessage: 'Replicate timeout',
      );
      final json = m.toFirestore();
      expect(json['succeeded'], false);
      expect(json['errorMessage'], 'Replicate timeout');
    });
  });
}
