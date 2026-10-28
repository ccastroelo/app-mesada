# Continuidade entre computadores

> Este arquivo é lido no início de toda sessão. **Atualize-o ao fim de cada sessão** (estado, próximo passo, pendências) e commite junto com o trabalho. Sem caminhos absolutos nem comandos exclusivos de um sistema.

## Estado atual (atualizado em 2026-10-28)

- Modo: **reescrita**. Design **aprovado** (ADR-0009). Marco **M0 parcial**: tema, rotas das 3 abas, `Result/Failure`, dinheiro em centavos, l10n (4 idiomas), lints e 6 testes. `analyze` limpo. Nunca rodou em aparelho/emulador.
- Falta do M0: inicialização do Firebase, CI (`analyze` + `test`) e ícone.
- Tag `legacy/1.2` marca o app iOS antigo (commit `a61a69e`).
- Telas são só casca (título na AppBar). Nenhuma regra de negócio implementada ainda.

## Como retomar em outro computador

Pré-requisitos: Git, Flutter **3.44.4** stable (Dart 3.12.2) e Android SDK. Build/execução de iOS exige macOS com Xcode (no Windows/Linux, testar via Android e `flutter test`).

```bash
git clone https://github.com/ccastroelo/mesada.git
cd mesada
git fetch --tags
cd app-flutter
flutter pub get
flutter analyze
flutter test
```

Já tendo o clone: `git pull --tags` na raiz e depois `flutter pub get`. Os arquivos de localização gerados (`app-flutter/lib/l10n/app_localizations*.dart`) são versionados; rode `flutter gen-l10n` só depois de editar um `.arb`.

Resultado esperado: `analyze` sem problemas e 6 testes passando. Se divergir, registre o baseline em `flutter.md` antes de mexer.

## Próximos passos (ordem)

1. **P0** (do usuário): criar o projeto Firebase (Auth com e-mail/senha, Google e Apple; Firestore) e decidir versão/build de release (> 1.2, build > 9). Revogar a chave/secret do Dropbox e a do Flurry do app antigo (estão no histórico do git; ver `behavior-inventory.md` §5).
2. **Sem depender do Firebase** (pode começar já): domínio de `rules`, `children` e `ledger` em Dart puro — entidades, saldo (`allowanceCents + Σ quantity × valueCents`), regras de ativar/desativar por filho, zerar com desfazer — com testes. Segue `target-architecture.md` e o modelo do `migration-plan.md`.
3. **M0 restante**: Firebase init (config fora do repositório quando for segredo; ver `working-agreement.md`), CI mínima, ícone.
4. **M1** — fatia-piloto `auth_family` (login, criar família, convite por código). Ao terminá-lo, criar `docs/agents/architecture.md` com o fluxo real e importá-lo no `CLAUDE.md`.
5. M2–M7 conforme `migration-plan.md`. M8 (corte) é decisão do usuário.

## Cuidados

- `mesada/` (app iOS antigo) é só leitura. Não copie para lugar nenhum as chaves hardcoded de `mesada/mesada/imAppDelegate.m:28` e `:50`.
- Antes de qualquer tela nova, releia os itens do inventário (`behavior-inventory.md` §1–2) e o `design.md`.
- Pergunte antes de: Firebase/regras do Firestore, `applicationId`, versão/build, assinatura, commit/tag/push, apagar o legado.
- Dinheiro sempre em centavos inteiros; foto do filho só local (ADR-0006).

## Prompt para iniciar a sessão em casa

> Continue a reescrita do Mesada. Leia `CLAUDE.md` e `docs/agents/continuidade.md`, confira `git status`, rode `flutter analyze` e `flutter test` em `app-flutter/` para o baseline e me diga o estado e o próximo passo antes de editar.
