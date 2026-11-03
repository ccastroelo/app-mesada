/// Estado compartilhado da feature `ledger` (separado do barrel de domínio
/// porque depende de `auth_family`).
library;

export 'presentation/state/ledger_state.dart'
    show LedgerActions, entriesProvider, ledgerActionsProvider;
