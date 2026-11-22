import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_ai/core/currency.dart';
import 'package:ledger_ai/core/split_calculator.dart';
import 'package:ledger_ai/core/split_models.dart';

SplitExpense expense({
  required String id,
  required String payerId,
  required int amountMinor,
  required Map<String, int> shares,
  int? baseAmountMinor,
  AppCurrency currency = AppCurrency.cny,
  double fxRate = 1,
}) {
  return SplitExpense(
    id: id,
    groupId: 'g1',
    payerId: payerId,
    amountMinor: amountMinor,
    currency: currency,
    fxRate: fxRate,
    baseAmountMinor: baseAmountMinor ?? amountMinor,
    baseCurrency: AppCurrency.cny,
    shares: shares,
    date: DateTime(2026, 11, 22),
    createdBy: payerId,
    updatedAt: DateTime(2026, 11, 22),
  );
}

void main() {
  const calc = SplitCalculator();

  test('equal shares distribute the remainder deterministically', () {
    final shares = SplitExpense.equalShares(
      participantIds: ['a', 'b', 'c'],
      amountMinor: 10000,
    );
    expect(shares, {'a': 3334, 'b': 3333, 'c': 3333});
    expect(shares.values.reduce((a, b) => a + b), 10000);
  });

  test('payer is owed the other participants shares', () {
    final result = calc.settle(
      expenses: [
        expense(
          id: 'e1',
          payerId: 'a',
          amountMinor: 10000,
          shares: {'a': 3334, 'b': 3333, 'c': 3333},
        ),
      ],
      participantIds: ['a', 'b', 'c'],
      currency: AppCurrency.cny,
    );
    expect(result.totalMinor, 10000);
    final net = {
      for (final b in result.balances) b.participantId: b.netMinor
    };
    expect(net['a'], 6666);
    expect(net['b'], -3333);
    expect(net['c'], -3333);
    expect(result.transfers, hasLength(2));
    expect(
      result.transfers.fold<int>(0, (s, t) => s + t.amountMinor),
      6666,
    );
  });

  test('multiple expenses net out correctly', () {
    final result = calc.settle(
      expenses: [
        expense(id: 'e1', payerId: 'a', amountMinor: 9000, shares: {
          'a': 3000,
          'b': 3000,
          'c': 3000,
        }),
        expense(id: 'e2', payerId: 'b', amountMinor: 6000, shares: {
          'a': 2000,
          'b': 2000,
          'c': 2000,
        }),
      ],
      participantIds: ['a', 'b', 'c'],
      currency: AppCurrency.cny,
    );
    final net = {
      for (final b in result.balances) b.participantId: b.netMinor
    };
    expect(net['a'], 4000);
    expect(net['b'], 1000);
    expect(net['c'], -5000);
    expect(result.transfers, hasLength(2));
  });

  test('foreign currency expense uses baseAmountMinor for settlement', () {
    final result = calc.settle(
      expenses: [
        expense(
          id: 'usd',
          payerId: 'a',
          amountMinor: 4200,
          baseAmountMinor: 30240,
          currency: AppCurrency.usd,
          fxRate: 7.2,
          shares: {'a': 1400, 'b': 1400, 'c': 1400},
        ),
      ],
      participantIds: ['a', 'b', 'c'],
      currency: AppCurrency.cny,
    );
    final net = {
      for (final b in result.balances) b.participantId: b.netMinor
    };
    expect(net['a'], 20160);
    expect(net['b'], -10080);
    expect(net['c'], -10080);
  });

  test('invalid shares are rejected', () {
    expect(
      () => calc.settle(
        expenses: [
          expense(id: 'bad', payerId: 'a', amountMinor: 100, shares: {
            'a': 1,
            'b': 2,
          }),
        ],
        participantIds: ['a', 'b'],
        currency: AppCurrency.cny,
      ),
      throwsArgumentError,
    );
  });

  test('unknown participant is rejected', () {
    expect(
      () => calc.settle(
        expenses: [
          expense(id: 'bad', payerId: 'a', amountMinor: 100, shares: {
            'a': 50,
            'c': 50,
          }),
        ],
        participantIds: ['a', 'b'],
        currency: AppCurrency.cny,
      ),
      throwsArgumentError,
    );
  });
}
