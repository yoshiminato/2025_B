class CustomizeModel {

  final int servings;
  final List<String> allergys;

  CustomizeModel({required this.servings, required this.allergys});

  CustomizeModel copyWith({int? servings, List<String>? allergys}) {
    return CustomizeModel(
      servings: servings ?? this.servings,
      allergys: allergys ?? this.allergys,
    );
  }
}