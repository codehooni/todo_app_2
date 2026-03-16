import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_app_2/core/services/app_snack_bar.dart';
import 'package:todo_app_2/core/services/debounce_service.dart';
import 'package:todo_app_2/core/widgets/app_button.dart';
import 'package:todo_app_2/core/services/tag_dialog_service.dart';
import 'package:todo_app_2/core/widgets/app_header.dart';
import 'package:todo_app_2/features/todo/domain/models/todo.dart';
import 'package:todo_app_2/features/todo/presentation/providers/tag_list_provider.dart';
import 'package:todo_app_2/features/todo/presentation/providers/todo_list_provider.dart';
import 'package:todo_app_2/features/todo/presentation/providers/todo_repository_provider.dart';
import 'package:todo_app_2/features/todo/presentation/widgets/todo_tag.dart';
import 'package:todo_app_2/features/user/presentation/providers/user_provider.dart';
import 'package:velocity_x/velocity_x.dart';

class AddTodoScreen extends ConsumerStatefulWidget {
  const AddTodoScreen({super.key});

  @override
  ConsumerState<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends ConsumerState<AddTodoScreen> {
  late final TextEditingController _titleController;
  late final DebounceService _debounce;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _debounce = DebounceService(duration: const Duration(milliseconds: 1500));
    Future.microtask(() {
      ref.read(_selectedPhotoProvider.notifier).clear();
      ref.read(_selectedTagsProvider.notifier).setAll({});
      _loadDraft();
    });
    _titleController.addListener(_onTitleChanged);
  }

  Future<void> _loadDraft() async {
    final draft = await ref.read(todoRepositoryProvider).getDraft();
    if (!mounted) return;
    final title = draft?['title'] as String? ?? '';
    final photo = draft?['photo'] as String?;
    final tagIds = (draft?['tagIds'] as List?)?.cast<String>() ?? [];
    if (title.isEmpty && photo == null && tagIds.isEmpty) return;

    final resume = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _DraftDialog(),
    );

    if (!mounted) return;
    if (resume == true) {
      _titleController.text = title;

      if (photo != null) {
        ref.read(_selectedPhotoProvider.notifier).set(XFile(photo));
      }

      ref.read(_selectedTagsProvider.notifier).setAll(tagIds.toSet());
    } else {
      await ref.read(todoRepositoryProvider).clearDraft();
    }
  }

  void _onTitleChanged() {
    _debounce.run(_saveDraft);
  }

  Future<void> _saveDraft() async {
    final title = _titleController.text;
    final photo = ref.read(_selectedPhotoProvider);
    final tagIds = ref.read(_selectedTagsProvider).toList();
    await ref.read(todoRepositoryProvider).saveDraft({
      'title': title,
      if (photo != null) 'photo': photo.path,
      'tagIds': tagIds,
    });
    if (mounted) _showDraftSavedToast();
  }

  OverlayEntry? _toastEntry;

  void _showDraftSavedToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.greenAccent,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Autosaved to draft',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        width: 196,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final photo = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (photo != null) {
      ref.read(_selectedPhotoProvider.notifier).set(photo);
      _saveDraft();
    }
  }

  void _clearPhoto() {
    ref.read(_selectedPhotoProvider.notifier).clear();
    _saveDraft();
  }

  void _toggleTag(String id) {
    ref.read(_selectedTagsProvider.notifier).toggle(id);
    _saveDraft();
  }

  @override
  void dispose() {
    _toastEntry?.remove();
    _debounce.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selectedPhoto = ref.watch(_selectedPhotoProvider);
    final isSaving = ref.watch(_isSavingProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        actions: [
          if (isSaving)
            const CircularProgressIndicator(
              strokeWidth: 2,
            ).box.size(20, 20).make().px20().py(10)
          else
            'Save'.text.lg.bold
                .color(colors.onSecondary)
                .make()
                .px20()
                .py(10)
                .box
                .roundedLg
                .color(colors.primary)
                .make()
                .onTap(() => _save(context)),
        ],
      ),
      body: VStack([
        // Title
        TextField(
          controller: _titleController,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: '무슨 생각을 하고 있나요?',
            hintStyle: TextStyle(
              fontSize: 32,
              color: colors.onPrimaryContainer.withAlpha(180),
              fontWeight: FontWeight.w500,
            ),
            border: InputBorder.none,
          ),
        ),
        16.heightBox,

        // Add Photo
        _buildPhotoSection(context, colors, selectedPhoto),
        32.heightBox,

        // Tags
        _buildTagSection(context, colors),
      ]).px16().safeArea(),
    );
  }

  Future<void> _save(BuildContext context) async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      AppSnackBar.showError(context, '제목을 입력해 주세요');
      return;
    }

    ref.read(_isSavingProvider.notifier).start();
    try {
      String? imageUrl;
      final photo = ref.read(_selectedPhotoProvider);
      if (photo != null) {
        final id = DateTime.now().millisecondsSinceEpoch.toString();
        final storageRef = FirebaseStorage.instance.ref('todo_images/$id');
        await storageRef.putFile(File(photo.path));
        imageUrl = await storageRef.getDownloadURL();
      }

      final user = await ref.read(userProvider.future);
      if (user == null) {
        if (context.mounted) AppSnackBar.showError(context, '로그인이 필요합니다');
        return;
      }

      final now = DateTime.now();
      final todo = Todo(
        userId: user.id,
        id: now.millisecondsSinceEpoch.toString(),
        title: title,
        imageUrl: imageUrl,
        tagIds: ref.read(_selectedTagsProvider).toList(),
        createdAt: now,
        updatedAt: now,
        isCompleted: false,
      );

      await ref.read(todoListProvider.notifier).add(todo);
      await ref.read(todoRepositoryProvider).clearDraft();
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) AppSnackBar.showError(context, '저장에 실패했습니다');
    } finally {
      ref.read(_isSavingProvider.notifier).stop();
    }
  }

  Widget _buildPhotoSection(
    BuildContext context,
    ColorScheme colors,
    XFile? selectedPhoto,
  ) {
    if (selectedPhoto != null) return _buildSelectedPhoto(selectedPhoto);
    return _buildAddPhotoButton(context, colors);
  }

  Widget _buildAddPhotoButton(BuildContext context, ColorScheme colors) {
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        color: colors.secondary.withAlpha(120),
        radius: Radius.circular(16),
        dashPattern: [10, 5],
        strokeWidth: 2,
      ),
      child:
          VStack([
                Icon(Icons.add_a_photo, color: colors.primary, size: 36)
                    .centered()
                    .pOnly(top: 16, left: 16, right: 18, bottom: 18)
                    .box
                    .roundedFull
                    .color(colors.primary.withAlpha(40))
                    .make(),
                16.heightBox,
                AppHeader(
                  title: '사진 추가하기',
                  subtitle: '할 일에 사진을 추가해 보세요!',
                  titleStyle: TextStyle(color: colors.onSurface, fontSize: 22),
                  subtitleStyle: TextStyle(fontSize: 16),
                ).centered(),
              ])
              .centered()
              .wFull(context)
              .box
              .height(236)
              .withRounded(value: 16)
              .color(colors.secondaryContainer.withAlpha(120))
              .make(),
    ).onTap(_pickPhoto);
  }

  Widget _buildSelectedPhoto(XFile selectedPhoto) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(selectedPhoto.path),
            width: double.infinity,
            height: 240,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: const Icon(Icons.close, color: Colors.white, size: 20)
              .centered()
              .p8()
              .box
              .roundedFull
              .color(Colors.black54)
              .make()
              .onTap(_clearPhoto),
        ),
      ],
    );
  }

  Widget _buildTagSection(BuildContext context, ColorScheme colors) {
    final tagsAsync = ref.watch(tagListProvider);
    final selectedTagIds = ref.watch(_selectedTagsProvider);

    return VStack([
      HStack([
        'TAGS'.text.lg.bold.color(colors.onSecondaryContainer).make(),
        const Spacer(),
        HStack([
              Icon(Icons.add, size: 14, color: colors.primary),
              4.widthBox,
              '태그 추가'.text.sm.color(colors.primary).make(),
            ])
            .px8()
            .py4()
            .box
            .roundedLg
            .color(colors.primary.withAlpha(30))
            .make()
            .onTap(() => TagDialogService.showAddTagDialog(context, ref)),
      ]),
      12.heightBox,
      tagsAsync.when(
        data: (tags) => tags.isEmpty
            ? const SizedBox.shrink()
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) {
                  final isSelected = selectedTagIds.contains(tag.id);
                  return TodoTag(tag: tag)
                      .animate(target: isSelected ? 1.0 : 0.0)
                      .fadeIn(begin: 0.35, duration: 150.ms)
                      .onTap(() => _toggleTag(tag.id));
                }).toList(),
              ),
        loading: () => const CircularProgressIndicator().centered(),
        error: (e, _) => const SizedBox.shrink(),
      ),
    ]);
  }
}

// ── Draft Dialog ───────────────────────────────────────────────────────────
class _DraftDialog extends StatelessWidget {
  const _DraftDialog();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: VStack([
        Icon(Icons.insert_drive_file, color: colors.primary, size: 28)
            .centered()
            .p(14)
            .box
            .roundedFull
            .color(colors.primary.withAlpha(40))
            .make(),
        16.heightBox,
        AppHeader(
          title: '계속 작성할까요?',
          subtitle: '이전에 작성하던 내용이 있습니다.\n계속 작성하시겠어요?',
          titleStyle: TextStyle(fontSize: 24),
          subtitleStyle: const TextStyle(fontSize: 16),
          alignment: CrossAxisAlignment.center,
        ).centered(),
        24.heightBox,
        AppButton(label: '계속하기', onPressed: () => Navigator.pop(context, true)),
        12.heightBox,
        AppButton(
          label: '새로 만들기',
          backgroundColor: colors.secondaryContainer,
          textColor: colors.onPrimary,
          onPressed: () => Navigator.pop(context, false),
        ),
      ]).p24(),
    );
  }
}

// ── Saving ─────────────────────────────────────────────────────────────────
final _isSavingProvider = NotifierProvider<_IsSavingNotifier, bool>(
  _IsSavingNotifier.new,
);

class _IsSavingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void start() => state = true;
  void stop() => state = false;
}

// ── Photo ──────────────────────────────────────────────────────────────────
final _selectedPhotoProvider = NotifierProvider<_SelectedPhotoNotifier, XFile?>(
  _SelectedPhotoNotifier.new,
);

class _SelectedPhotoNotifier extends Notifier<XFile?> {
  @override
  XFile? build() => null;
  void set(XFile photo) => state = photo;
  void clear() => state = null;
}

// ── Tags ───────────────────────────────────────────────────────────────────
final _selectedTagsProvider =
    NotifierProvider<_SelectedTagsNotifier, Set<String>>(
      _SelectedTagsNotifier.new,
    );

class _SelectedTagsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};
  void toggle(String id) => state = state.contains(id)
      ? (Set.from(state)..remove(id))
      : {...state, id};
  void setAll(Set<String> ids) => state = ids;
}
