import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../core/widgets/money_field.dart';
import '../../../../core/widgets/page_body.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/providers.dart';
import '../../domain/entities/child.dart';
import '../state/children_state.dart';
import '../widgets/child_avatar.dart';

/// Teto da mesada: 999.999,99 (as regras do Firestore aceitam até 99.999.999
/// centavos).
const maxAllowanceCents = 99999999;

/// Cria (childId == null) ou edita um filho.
class ChildEditPage extends ConsumerStatefulWidget {
  const ChildEditPage({super.key, this.childId});

  final String? childId;

  @override
  ConsumerState<ChildEditPage> createState() => _ChildEditPageState();
}

class _ChildEditPageState extends ConsumerState<ChildEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _allowance = TextEditingController();
  bool _filled = false;

  /// Foto escolhida agora (ainda não gravada) e pedido de remover a atual.
  String? _pickedPath;
  bool _removePhoto = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _allowance.dispose();
    super.dispose();
  }

  void _fill(Child? child) {
    final locale = Localizations.localeOf(context).toString();
    _name.text = child?.name ?? '';
    _email.text = child?.email ?? '';
    _allowance.text = formatCentsPlain(
      child?.allowanceCents ?? 0,
      locale: locale,
    );
    _filled = true;
  }

  bool _isEmail(String value) =>
      RegExp(r'^\S+@\S+\.\S+$').hasMatch(value.trim());

  Future<void> _pickPhoto() async {
    final path = await ref.read(photoPickerProvider).pickFromGallery();
    if (path != null && mounted) {
      setState(() {
        _pickedPath = path;
        _removePhoto = false;
      });
    }
  }

  Future<void> _save(Child? existing) async {
    if (!_formKey.currentState!.validate()) return;
    final actions = ref.read(childrenActionsProvider.notifier);
    final allowanceCents = centsFromMaskedText(_allowance.text);
    final ok = existing == null
        ? await actions.add(
            name: _name.text,
            email: _email.text,
            allowanceCents: allowanceCents,
            photoPath: _pickedPath,
          )
        : await actions.edit(
            existing.copyWith(
              name: _name.text,
              email: _email.text,
              allowanceCents: allowanceCents,
            ),
            newPhotoPath: _pickedPath,
            removePhoto: _removePhoto,
          );
    if (ok && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final action = ref.watch(childrenActionsProvider);
    final editing = widget.childId != null;
    final children = ref.watch(childrenProvider);

    Child? existing;
    if (editing) {
      if (!children.hasValue) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.editChildTitle)),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      existing = children.value!
          .where((c) => c.id == widget.childId)
          .firstOrNull;
      if (existing == null) {
        // Outro responsável apagou este filho enquanto a tela estava aberta.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.pop();
        });
        return const Scaffold(body: SizedBox.shrink());
      }
    }
    if (!_filled) _fill(existing);

    final hasStoredPhoto =
        existing != null &&
        ref.watch(childPhotoPathProvider(existing.id)).value != null;
    final showsPhoto = _pickedPath != null || (hasStoredPhoto && !_removePhoto);

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? l10n.editChildTitle : l10n.newChildTitle),
      ),
      body: PageBody(
        children: [
          Center(
            child: ListenableBuilder(
              listenable: _name,
              builder: (context, _) => _PhotoPreview(
                pickedPath: _pickedPath,
                child: existing,
                name: _name.text,
                showStored: !_removePhoto,
              ),
            ),
          ),
          const SizedBox(height: Space.sm),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: Space.sm,
            children: [
              TextButton.icon(
                onPressed: _pickPhoto,
                icon: const Icon(Icons.photo_outlined),
                label: Text(l10n.childPhotoAction),
              ),
              if (showsPhoto)
                TextButton(
                  onPressed: () => setState(() {
                    _pickedPath = null;
                    _removePhoto = true;
                  }),
                  child: Text(l10n.childPhotoRemove),
                ),
            ],
          ),
          const SizedBox(height: Space.md),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  autofocus: !editing,
                  maxLength: 60,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: l10n.childNameLabel),
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? l10n.childNameRequired
                      : null,
                ),
                const SizedBox(height: Space.md),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  maxLength: 120,
                  decoration: InputDecoration(labelText: l10n.childEmailLabel),
                  validator: (value) {
                    final text = (value ?? '').trim();
                    return text.isEmpty || _isEmail(text)
                        ? null
                        : l10n.childEmailInvalid;
                  },
                ),
                const SizedBox(height: Space.md),
                MoneyField(
                  controller: _allowance,
                  label: l10n.childAllowanceLabel,
                  maxCents: maxAllowanceCents,
                  onSubmitted: (_) => _save(existing),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.lg),
          FilledButton(
            onPressed: action.loading ? null : () => _save(existing),
            child: Text(l10n.saveAction),
          ),
          if (action.loading)
            const Padding(
              padding: EdgeInsets.only(top: Space.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
          FailureText(action.failure),
        ],
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({
    required this.pickedPath,
    required this.child,
    required this.name,
    required this.showStored,
  });

  final String? pickedPath;
  final Child? child;
  final String name;
  final bool showStored;

  @override
  Widget build(BuildContext context) {
    const radius = 48.0;
    final picked = pickedPath;
    if (picked != null) {
      return ExcludeSemantics(
        child: CircleAvatar(
          radius: radius,
          backgroundImage: FileImage(File(picked)),
        ),
      );
    }
    final existing = child;
    if (existing != null && showStored) {
      return ChildAvatar(childId: existing.id, name: name, radius: radius);
    }
    return ExcludeSemantics(
      child: InitialAvatar(
        seed: existing?.id ?? 'novo',
        name: name,
        radius: radius,
      ),
    );
  }
}
