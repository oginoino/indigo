import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../model/create/content_type.dart';
import '../../model/create/post_draft.dart';
import '../../provider/create/create_post_provider.dart';
import '../../util/const/app/app_strings.dart';
import '../../util/const/ui/ui_constants.dart';
import '../components/app_bottom_navigation_bar.dart';
import '../components/create/content_type_grid.dart';
import '../components/create/create_post_editor.dart';

/// Tela de criação de conteúdo.
///
/// Fluxo em duas etapas:
/// 1. **Seleção** — grade com todos os [ContentType] disponíveis.
/// 2. **Edição** — editor adaptado ao tipo selecionado com toolbar de ações.
///
/// O [CreatePostProvider] é injetado aqui e descartado ao sair da tela.
class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final p = CreatePostProvider();
        // Inicializa o provedor com as 2 opções de enquete padrão.
        p.draft.pollOptions
          ..add(DraftPollOption())
          ..add(DraftPollOption());
        return p;
      },
      child: const _CreatePageContent(),
    );
  }
}

class _CreatePageContent extends StatefulWidget {
  const _CreatePageContent();

  @override
  State<_CreatePageContent> createState() => _CreatePageContentState();
}

class _CreatePageContentState extends State<_CreatePageContent>
    with SingleTickerProviderStateMixin {
  /// `true` = mostrando o editor; `false` = mostrando a grade de seleção.
  bool _inEditor = false;

  late final AnimationController _slideController = AnimationController(
    vsync: this,
    duration: UIConstants.bottomNavigationAnimationDuration,
  );

  late final Animation<Offset> _slideAnimation = Tween<Offset>(
    begin: const Offset(1, 0),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
  );

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _openEditor() {
    setState(() => _inEditor = true);
    _slideController.forward(from: 0);
  }

  Future<void> _closeEditor(CreatePostProvider provider) async {
    if (provider.draft.hasContent) {
      final discard = await _confirmDiscard(context);
      if (!discard) return;
    }
    provider.reset();
    _slideController.reverse();
    setState(() => _inEditor = false);
  }

  Future<bool> _confirmDiscard(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.createEditorDiscard),
        content: const Text(AppStrings.createEditorDiscardConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.createEditorDiscardConfirmNo),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(AppStrings.createEditorDiscardConfirmYes),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _onPublished() {
    _slideController.reverse();
    setState(() => _inEditor = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreatePostProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          extendBody: true,
          appBar: _buildAppBar(context, provider),
          body: _inEditor
              ? SlideTransition(
                  position: _slideAnimation,
                  child: const CreatePostEditor(),
                )
              : _SelectionBody(onTypeConfirmed: _openEditor),
          bottomNavigationBar: _inEditor
              ? _PublishToolbar(provider: provider)
              : const AppBottomNavigationBar(),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, CreatePostProvider provider) {
    return AppBar(
      title: Text(
        _inEditor ? provider.draft.type.label : AppStrings.createPageTitle,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      leading: _inEditor
          ? IconButton(
              tooltip: AppStrings.createEditorDiscard,
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _closeEditor(provider),
            )
          : null,
      actions: _inEditor
          ? [
              _PublishButton(
                provider: provider,
                onPublished: _onPublished,
              ),
            ]
          : null,
      bottom: _inEditor
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(
                height: 1,
                thickness: 0.5,
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            )
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Corpo de seleção de tipo
// ---------------------------------------------------------------------------

class _SelectionBody extends StatelessWidget {
  const _SelectionBody({required this.onTypeConfirmed});

  final VoidCallback onTypeConfirmed;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CreatePostProvider>();

    return Consumer<CreatePostProvider>(
      builder: (context, p, _) => CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ContentTypeGrid(
              selected: p.draft.type,
              onSelect: (type) {
                provider.selectType(type);
                onTypeConfirmed();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Botão publicar (AppBar)
// ---------------------------------------------------------------------------

class _PublishButton extends StatelessWidget {
  const _PublishButton({
    required this.provider,
    required this.onPublished,
  });

  final CreatePostProvider provider;
  final VoidCallback onPublished;

  @override
  Widget build(BuildContext context) {
    final canPublish = provider.draft.hasContent && !provider.isPublishing;

    return Padding(
      padding: const EdgeInsets.only(right: UIConstants.spaceSm),
      child: AnimatedSwitcher(
        duration: UIConstants.engagementColorDuration,
        child: provider.isPublishing
            ? const SizedBox(
                key: ValueKey('loading'),
                width: UIConstants.createEditorAvatarSize,
                height: UIConstants.createEditorAvatarSize,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : FilledButton(
                key: const ValueKey('publish'),
                onPressed: canPublish
                    ? () => _publish(context, provider)
                    : null,
                child: const Text(AppStrings.createEditorPublish),
              ),
      ),
    );
  }

  Future<void> _publish(
    BuildContext context,
    CreatePostProvider provider,
  ) async {
    final success = await provider.publish();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? AppStrings.createPublishSuccess
              : AppStrings.createPublishFailed,
        ),
        behavior: SnackBarBehavior.floating,
        duration: UIConstants.createPublishFeedback,
      ),
    );

    if (success) {
      // Volta para a grade de seleção após publicar com sucesso.
      onPublished();
    }
  }
}

// ---------------------------------------------------------------------------
// Toolbar inferior (apenas no modo editor — teclado recolhido)
// ---------------------------------------------------------------------------

class _PublishToolbar extends StatelessWidget {
  const _PublishToolbar({required this.provider});

  final CreatePostProvider provider;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final type = provider.draft.type;

    // Ações contextuais por tipo de conteúdo.
    final actions = <_ToolbarAction>[
      if (type == ContentType.photo || type == ContentType.video)
        _ToolbarAction(
          icon: Icons.add_photo_alternate_outlined,
          tooltip: AppStrings.createEditorAddMedia,
          onTap: provider.addMedia,
        ),
      if (type == ContentType.poll)
        _ToolbarAction(
          icon: Icons.add_circle_outline,
          tooltip: AppStrings.createEditorAddPollOption,
          onTap: provider.addPollOption,
        ),
      _ToolbarAction(
        icon: type.icon,
        tooltip: type.label,
        onTap: null,
        isLabel: true,
      ),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: UIConstants.createEditorToolbarHeight,
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(
              color: colors.outlineVariant.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            for (final action in actions)
              if (action.isLabel)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.spaceSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        action.icon,
                        size: 18,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: UIConstants.space2xs),
                      Text(
                        action.tooltip,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              else
                IconButton(
                  tooltip: action.tooltip,
                  icon: Icon(action.icon),
                  onPressed: action.onTap,
                ),
            const Spacer(),
            // Contador de caracteres (apenas para posts e stories).
            if (type == ContentType.post || type == ContentType.story)
              Padding(
                padding: const EdgeInsets.only(right: UIConstants.spaceMd),
                child: _CharCounter(body: provider.draft.body),
              ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarAction {
  const _ToolbarAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isLabel = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool isLabel;
}

// ---------------------------------------------------------------------------
// Contador de caracteres
// ---------------------------------------------------------------------------

class _CharCounter extends StatelessWidget {
  const _CharCounter({required this.body});

  final String body;

  static const int _softLimit = 240;
  static const int _hardLimit = 500;

  @override
  Widget build(BuildContext context) {
    final count = body.length;
    final colors = Theme.of(context).colorScheme;

    final color = switch (count) {
      > _hardLimit => colors.error,
      > _softLimit => colors.tertiary,
      _ => colors.onSurfaceVariant,
    };

    return Text(
      '$count / $_hardLimit',
      style: Theme.of(
        context,
      ).textTheme.labelSmall?.copyWith(color: color),
    );
  }
}
