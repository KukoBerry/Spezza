// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_expense_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(goalExpenseModel)
const goalExpenseModelProvider = GoalExpenseModelProvider._();

final class GoalExpenseModelProvider
    extends
        $FunctionalProvider<
          GoalExpenseModel,
          GoalExpenseModel,
          GoalExpenseModel
        >
    with $Provider<GoalExpenseModel> {
  const GoalExpenseModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalExpenseModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalExpenseModelHash();

  @$internal
  @override
  $ProviderElement<GoalExpenseModel> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoalExpenseModel create(Ref ref) {
    return goalExpenseModel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoalExpenseModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoalExpenseModel>(value),
    );
  }
}

String _$goalExpenseModelHash() => r'2505bc80a549a34d14160c830d0827ae9f82a911';
