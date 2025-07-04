import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:class_2025_b/models/customize_model.dart';
import 'package:class_2025_b/services/kv_service.dart';

part 'custom_state.g.dart';


@riverpod
class CustomizeNotifier extends _$CustomizeNotifier {

  @override
  Future<CustomizeModel> build() async {
    final kvService = KVService();
    final servingsStr = await kvService.getValueFromKeyType(KeyType.servings);
    final cleanedStr = servingsStr.replaceAll(RegExp(r'[^0-9]'), '');
    final servings = cleanedStr.isEmpty ? 1 : int.parse(cleanedStr); // デフォルトは1人前
    final allergys = await kvService.getValuesFromKeyType(KeyType.allergys);
    final tools = await kvService.getValuesFromKeyType(KeyType.tools);
    return CustomizeModel(
      servings: servings,
      allergys: allergys,
      availableTools : tools,
    );
  }

  void setServings(int servings) {
    if(state.value == null) return;
    state = AsyncData(state.value!.copyWith(servings: servings));
  }

  void toggleAllergy(String allergy) {

    // 取得が完了していなければreturn
    if(state.value == null) return;

    // 現在のアレルギーリストをコピー
    final list = List<String>.from(state.value!.allergys);
    if (list.contains(allergy)) {
      list.remove(allergy);
    } else {
      list.add(allergy);
    }
    state = AsyncData(state.value!.copyWith(allergys: list));
  }

  void toggleTool(String tool) {

    // 取得が完了していなければreturn
    if(state.value == null) return;

    final list = List<String>.from(state.value!.availableTools);

    if (list.contains(tool)) {
      list.remove(tool);
    } else {
      list.add(tool);
    }

    state = AsyncData(state.value!.copyWith(availableTools: list));
  }

  Future<void> saveSettings() async {

    // 取得が完了していなければreturn
    if(state.value == null) return;

    debugPrint("保存: 分量=${state.value!.servings}, アレルギー=${state.value!.allergys}, 調理器具=${state.value!.availableTools}");

    final kvService = KVService();
    await kvService.saveValueForKeyType(KeyType.servings, state.value!.servings.toString());
    await kvService.saveValuesForKeyType(KeyType.allergys, state.value!.allergys);
    await kvService.saveValuesForKeyType(KeyType.tools, state.value!.availableTools);
  }

}

