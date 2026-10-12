/// En fazla [maxSize] kayıt tutan basit LRU önbellek.
///
/// Dart `Map` ekleme sırasını koruduğu için ilk anahtar en eski kayıttır.
/// Sınırsız büyümeyi engeller.
///
/// Kullanım: `ApiService`'in günlük/aylık vakit önbelleği.
class LruCache<K, V> {
  final int maxSize;
  final Map<K, V> _map = {};

  LruCache(this.maxSize);

  /// Anahtarı bulur ve en yeniye taşır; yoksa null döner.
  V? get(K key) {
    final value = _map.remove(key);
    if (value != null) {
      _map[key] = value;
    }
    return value;
  }

  bool containsKey(K key) => _map.containsKey(key);

  void put(K key, V value) {
    _map.remove(key);
    _map[key] = value;
    while (_map.length > maxSize) {
      _map.remove(_map.keys.first);
    }
  }

  int get length => _map.length;

  void clear() => _map.clear();
}
