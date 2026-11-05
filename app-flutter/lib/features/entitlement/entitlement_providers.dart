/// Estado e widgets da feature `entitlement` que outras features usam: o
/// acesso ao app (teste, comprado, só leitura), a guarda das escritas e a
/// faixa que explica a situação (ADR-0021).
library;

export 'presentation/state/entitlement_state.dart'
    show
        PurchaseActions,
        accessProvider,
        canWriteNow,
        canWriteProvider,
        entitlementProvider,
        purchaseActionsProvider,
        purchasesProvider,
        sharingActiveProvider,
        sharingLapsedProvider,
        validatedProductsProvider,
        storeOfferProvider;
export 'presentation/widgets/access_banner.dart';
