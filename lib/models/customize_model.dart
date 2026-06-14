class CustomizeModel {

  final int servings;
  final List<String> allergys;
  final List<String> availableTools;

  CustomizeModel({required this.servings, required this.allergys, required this.availableTools});

  CustomizeModel copyWith({int? servings, List<String>? allergys, List<String>? availableTools}) {
    return CustomizeModel(
      servings: servings ?? this.servings,
      allergys: allergys ?? this.allergys,
      availableTools: availableTools?? this.availableTools,
    );
  }
}