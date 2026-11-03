/// Estado do bloqueio por PIN, para o roteador e para Ajustes.
library;

export 'presentation/state/app_lock_state.dart'
    show
        AppLockController,
        LockClosed,
        LockLoading,
        LockOff,
        LockOpen,
        LockState,
        appLockProvider,
        awayLimit,
        clockProvider;
