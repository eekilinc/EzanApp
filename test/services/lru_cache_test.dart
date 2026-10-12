import 'package:flutter_test/flutter_test.dart';
import 'package:ezan_app/services/lru_cache.dart';

void main() {
  group('_LruCache', () {
    test('temizlenmişse get null döner', () {
      final c = LruCache<String, int>(3);
      expect(c.get('a'), isNull);
      expect(c.containsKey('a'), isFalse);
      expect(c.length, 0);
    });

    test('put sonrası get değeri döndürür', () {
      final c = LruCache<String, int>(3);
      c.put('a', 1);
      expect(c.get('a'), 1);
      expect(c.containsKey('a'), isTrue);
      expect(c.length, 1);
    });

    test('sınırı aşan kayıtlar en eskiden atılır', () {
      final c = LruCache<String, int>(2);
      c.put('a', 1);
      c.put('b', 2);
      c.put('c', 3); // 'a' en eski -> atılmalı
      expect(c.length, 2);
      expect(c.get('a'), isNull);
      expect(c.get('b'), 2);
      expect(c.get('c'), 3);
    });

    test('get çağrısı kaydı tazeler (LRU semantiği)', () {
      final c = LruCache<String, int>(2);
      c.put('a', 1);
      c.put('b', 2);
      c.get('a'); // 'a' artık en yeni
      c.put('c', 3); // 'b' atılmalı
      expect(c.get('b'), isNull);
      expect(c.get('a'), 1);
      expect(c.get('c'), 3);
    });

    test('aynı anahtar tekrar put edilirse boyut artmaz', () {
      final c = LruCache<String, int>(3);
      c.put('a', 1);
      c.put('a', 2);
      expect(c.length, 1);
      expect(c.get('a'), 2);
    });

    test('sınır 1 ise yalnızca son kayıt kalır', () {
      final c = LruCache<String, int>(1);
      c.put('a', 1);
      c.put('b', 2);
      expect(c.length, 1);
      expect(c.get('a'), isNull);
      expect(c.get('b'), 2);
    });

    test('null değer depolamak get\'i null yapar ama anahtarı tutar', () {
      // PrayerTimes asla null olmaz; yine de beklenen davranış sabitlensin.
      final c = LruCache<String, int?>(2);
      c.put('a', null);
      expect(c.containsKey('a'), isTrue);
      expect(c.get('a'), isNull);
    });
  });
}