/// State holder for temporary app state
library state_holder;

import 'package:flutter/material.dart';

/// Single-value state holder
class StateHolder<T> extends ChangeNotifier {
  T _value;

  StateHolder(this._value);

  /// Get current value
  T get value => _value;

  /// Set new value
  void setValue(T newValue) {
    if (_value != newValue) {
      _value = newValue;
      notifyListeners();
    }
  }

  /// Reset to initial value
  void reset(T initial) {
    _value = initial;
    notifyListeners();
  }
}

/// List state holder
class ListStateHolder<T> extends ChangeNotifier {
  List<T> _items = [];

  ListStateHolder([List<T>? initial]) {
    if (initial != null) _items = List.from(initial);
  }

  /// Get items
  List<T> get items => List.unmodifiable(_items);

  /// Add item
  void add(T item) {
    _items.add(item);
    notifyListeners();
  }

  /// Remove item
  void remove(T item) {
    _items.remove(item);
    notifyListeners();
  }

  /// Replace all items
  void setAll(List<T> items) {
    _items = List.from(items);
    notifyListeners();
  }

  /// Clear all items
  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Get count
  int get length => _items.length;

  /// Check if empty
  bool get isEmpty => _items.isEmpty;

  /// Check if not empty
  bool get isNotEmpty => _items.isNotEmpty;
}
