import 'dart:convert';

enum Somatotype { ectomorph, mesomorph, endomorph }

class NutritionProfile {
  final double weight;
  final double height;
  final int age;
  final String gender; // 'male' or 'female'
  final double activityLevel; // 1.2, 1.375, 1.55, 1.725, 1.9
  final Somatotype somatotype;

  NutritionProfile({
    required this.weight,
    required this.height,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.somatotype,
  });

  // Cálculo de BMR usando Mifflin-St Jeor
  double get bmr {
    if (gender == 'male') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  // TDEE: Gasto Energético Diario Total
  double get tdee => bmr * activityLevel;

  // Ratios de Macronutrientes por Somatotipo
  // Retorna Map con {protein: %, carbs: %, fat: %}
  Map<String, double> get macroRatios {
    switch (somatotype) {
      case Somatotype.ectomorph:
        return {'carbs': 0.55, 'protein': 0.25, 'fat': 0.20};
      case Somatotype.mesomorph:
        return {'carbs': 0.40, 'protein': 0.30, 'fat': 0.30};
      case Somatotype.endomorph:
        return {'carbs': 0.25, 'protein': 0.35, 'fat': 0.40};
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'height': height,
      'age': age,
      'gender': gender,
      'activityLevel': activityLevel,
      'somatotype': somatotype.index,
    };
  }

  factory NutritionProfile.fromJson(Map<String, dynamic> json) {
    return NutritionProfile(
      weight: json['weight'],
      height: json['height'],
      age: json['age'],
      gender: json['gender'],
      activityLevel: json['activityLevel'],
      somatotype: Somatotype.values[json['somatotype']],
    );
  }
}

class MealLog {
  final String? id;
  final String date; // YYYY-MM-DD
  final String mealType; // Desayuno, Almuerzo, Cena, Snack
  final String foodName;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime timestamp;

  MealLog({
    this.id,
    required this.date,
    required this.mealType,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'mealType': mealType,
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MealLog.fromMap(Map<String, dynamic> map) {
    return MealLog(
      id: map['id'],
      date: map['date'],
      mealType: map['mealType'],
      foodName: map['foodName'],
      calories: map['calories'],
      protein: map['protein'],
      carbs: map['carbs'],
      fat: map['fat'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
