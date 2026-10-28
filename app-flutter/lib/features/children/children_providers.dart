/// Estado compartilhado da feature `children` (separado do barrel de domínio
/// porque depende de `auth_family`).
library;

export 'presentation/state/children_state.dart'
    show ChildSummary, childSummariesProvider, childrenProvider;
