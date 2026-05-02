import 'package:flutter/material.dart';
import '../data/models/jar_model.dart';
import '../data/models/transaction_model.dart';

class JarProvider with ChangeNotifier {
  List<JarModel> _jars = [];
  List<JarModel> get jars => _jars;
  
  JarProvider() {
    _jars = [
      JarModel(
        id: '1',
        name: 'New Laptop',
        targetAmount: 2400,
        savedAmount: 1250,
        iconStyle: 'laptop',
        createdAt: DateTime.now(),
      ),
      JarModel(
        id: '2',
        name: 'Summer Trip',
        targetAmount: 3500,
        savedAmount: 3500,
        iconStyle: 'plane',
        createdAt: DateTime.now(),
      ),
    ];
  }

  void addJar(JarModel jar) {
    _jars.add(jar);
    notifyListeners();
  }
}
