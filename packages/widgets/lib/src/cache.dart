
typedef CacheControl<T> = ({
  T Function() get,
  void Function() invalidate,
});

CacheControl<T> createCache<T>(
  T Function() calculate,
) {
  bool hasValue = false;
  late T cachedValue;
  return (
    get: () {
      if (!hasValue) {
        cachedValue = calculate();
      }
      return cachedValue;
    },
    invalidate: () {
      hasValue = false;
    }
  );
}


