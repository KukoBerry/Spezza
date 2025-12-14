// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(expenseModel)
const expenseModelProvider = ExpenseModelProvider._();

final class ExpenseModelProvider
    extends $FunctionalProvider<ExpenseModel, ExpenseModel, ExpenseModel>
    with $Provider<ExpenseModel> {
  const ExpenseModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseModelHash();

  @$internal
  @override
  $ProviderElement<ExpenseModel> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExpenseModel create(Ref ref) {
    return expenseModel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExpenseModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExpenseModel>(value),
    );
  }
}

String _$expenseModelHash() => r'fa6902270319fc70eb2bc7f704bec5ed4afc987c';
