import 'package:flutter_test/flutter_test.dart';
import 'package:hijapp/core/models/referral_code_model.dart';

ReferralCodeModel _make({
  bool isActive = true,
  int maxRedemptions = 0,
  int currentRedemptions = 0,
  DateTime? expiresAt,
}) {
  return ReferralCodeModel(
    id: 'c1',
    code: 'TEST',
    boutiqueId: 'b1',
    creditsPerRedemption: 5,
    isActive: isActive,
    maxRedemptions: maxRedemptions,
    currentRedemptions: currentRedemptions,
    expiresAt: expiresAt,
  );
}

void main() {
  group('ReferralCodeModel.isValid', () {
    test('active code with no caps is valid', () {
      expect(_make().isValid, isTrue);
    });

    test('inactive code is invalid', () {
      expect(_make(isActive: false).isValid, isFalse);
    });

    test('expired code is invalid', () {
      final past = DateTime.now().subtract(const Duration(days: 1));
      expect(_make(expiresAt: past).isValid, isFalse);
    });

    test('future expiry is valid', () {
      final future = DateTime.now().add(const Duration(days: 1));
      expect(_make(expiresAt: future).isValid, isTrue);
    });

    test('exhausted code (current >= max) is invalid', () {
      expect(_make(maxRedemptions: 5, currentRedemptions: 5).isValid, isFalse);
      expect(_make(maxRedemptions: 5, currentRedemptions: 6).isValid, isFalse);
    });

    test('under-cap code is valid', () {
      expect(_make(maxRedemptions: 5, currentRedemptions: 4).isValid, isTrue);
    });

    test('maxRedemptions = 0 means sinirsiz', () {
      expect(_make(maxRedemptions: 0, currentRedemptions: 9999).isValid, isTrue);
    });
  });

  test('toFirestore includes spec v2 extra fields', () {
    final m = ReferralCodeModel(
      id: 'c1',
      code: 'INSTA10',
      boutiqueId: 'b1',
      creditsPerRedemption: 5,
      totalCreditsGranted: 50,
      redeemedByUsers: const ['u1', 'u2'],
      campaignTag: 'instagram',
    );
    final json = m.toFirestore();
    expect(json['totalCreditsGranted'], 50);
    expect(json['redeemedByUsers'], ['u1', 'u2']);
    expect(json['campaignTag'], 'instagram');
  });
}
