import '../../../../core/storage/device_settings.dart';
import '../../domain/entities/family_plan.dart';
import '../../domain/repositories/plan_store.dart';

/// Guarda o direito no `device.json`, pelo `DeviceSettings` — escrita por
/// junção, então não mexe no PIN nem na introdução.
class PlanStoreImpl implements PlanStore {
  PlanStoreImpl(this._settings);

  final DeviceSettings _settings;

  static const _key = 'familyPlan';

  @override
  Future<FamilyPlan> read() async {
    final json = (await _settings.read())[_key];
    if (json is! Map) return const FamilyPlan.none();
    return FamilyPlan.fromJson(json.cast<String, Object?>());
  }

  @override
  Future<void> save(FamilyPlan plan) => _settings.merge({_key: plan.toJson()});
}
