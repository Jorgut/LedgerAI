import 'split_models.dart';

/// Pure settlement logic for local split groups.
///
/// All calculations are integer minor units. A positive net balance means the
/// participant is owed money; a negative one means they owe money.
class SplitCalculator {
  const SplitCalculator();

  SplitSettlement settle({
    required List<SplitExpense> expenses,
    required List<String> participantIds,
    required dynamic currency,
  }) {
    if (participantIds.isEmpty) {
      throw ArgumentError('split requires participants');
    }
    final ids = participantIds.toSet();
    final paid = <String, int>{for (final id in participantIds) id: 0};
    final share = <String, int>{for (final id in participantIds) id: 0};

    for (final expense in expenses) {
      if (!ids.contains(expense.payerId)) {
        throw ArgumentError('payer ${expense.payerId} is not a participant');
      }
      if (expense.shares.isEmpty) {
        throw ArgumentError('expense ${expense.id} has no shares');
      }
      final shareTotal =
          expense.shares.values.fold<int>(0, (sum, value) => sum + value);
      if (shareTotal != expense.amountMinor) {
        throw ArgumentError(
            'expense ${expense.id} shares $shareTotal != ${expense.amountMinor}');
      }
      if (expense.baseAmountMinor < 0) {
        throw ArgumentError('negative expense');
      }
      paid[expense.payerId] = paid[expense.payerId]! + expense.baseAmountMinor;
      for (final entry in expense.shares.entries) {
        if (!ids.contains(entry.key)) {
          throw ArgumentError('unknown participant ${entry.key}');
        }
        // Convert the original-currency share to base minor units
        // proportionally; the last participant absorbs integer rounding.
        final amount = expense.amountMinor;
        final baseShare = amount == 0
            ? 0
            : (entry.value * expense.baseAmountMinor / amount).round();
        share[entry.key] = share[entry.key]! + baseShare;
      }
    }

    final balances = <SplitBalance>[];
    var totalPaid = 0;
    for (final id in participantIds) {
      final p = paid[id]!;
      final s = share[id]!;
      totalPaid += p;
      balances.add(SplitBalance(
        participantId: id,
        paidMinor: p,
        shareMinor: s,
        netMinor: p - s,
      ));
    }

    // Rounding can leave a few minor units on one side; absorb the difference
    // into the payer with the largest positive balance so the result is exact.
    final netTotal = balances.fold<int>(0, (sum, b) => sum + b.netMinor);
    if (netTotal != 0 && balances.isNotEmpty) {
      final target = balances.reduce((a, b) => a.netMinor >= b.netMinor ? a : b);
      final index = balances.indexOf(target);
      balances[index] = SplitBalance(
        participantId: target.participantId,
        paidMinor: target.paidMinor,
        shareMinor: target.shareMinor - netTotal,
        netMinor: target.netMinor - netTotal,
      );
    }

    final transfers = _minimizeTransfers(balances);
    return SplitSettlement(
      balances: balances,
      transfers: transfers,
      currency: currency,
      totalMinor: totalPaid,
    );
  }

  List<SplitTransfer> _minimizeTransfers(List<SplitBalance> balances) {
    final debtors = balances.where((b) => b.netMinor < 0).toList()
      ..sort((a, b) => a.netMinor.compareTo(b.netMinor));
    final creditors = balances.where((b) => b.netMinor > 0).toList()
      ..sort((a, b) => b.netMinor.compareTo(a.netMinor));
    final transfers = <SplitTransfer>[];
    var d = 0, c = 0;
    while (d < debtors.length && c < creditors.length) {
      final debt = -debtors[d].netMinor;
      final credit = creditors[c].netMinor;
      final amount = debt < credit ? debt : credit;
      if (amount > 0) {
        transfers.add(SplitTransfer(
          fromId: debtors[d].participantId,
          toId: creditors[c].participantId,
          amountMinor: amount,
        ));
        debtors[d] = SplitBalance(
          participantId: debtors[d].participantId,
          paidMinor: debtors[d].paidMinor,
          shareMinor: debtors[d].shareMinor,
          netMinor: debtors[d].netMinor + amount,
        );
        creditors[c] = SplitBalance(
          participantId: creditors[c].participantId,
          paidMinor: creditors[c].paidMinor,
          shareMinor: creditors[c].shareMinor,
          netMinor: creditors[c].netMinor - amount,
        );
      }
      if (debtors[d].netMinor == 0) d++;
      if (creditors[c].netMinor == 0) c++;
    }
    return transfers;
  }
}
