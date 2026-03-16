import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_app_2/core/services/app_snack_bar.dart';
import 'package:todo_app_2/core/services/tag_dialog_service.dart';
import 'package:todo_app_2/core/widgets/app_header.dart';
import 'package:todo_app_2/features/todo/domain/models/tag.dart';
import 'package:todo_app_2/features/todo/domain/models/todo.dart';
import 'package:todo_app_2/features/todo/presentation/providers/tag_list_provider.dart';
import 'package:todo_app_2/features/todo/presentation/providers/todo_list_provider.dart';
import 'package:todo_app_2/features/todo/presentation/widgets/todo_tag.dart';
import 'package:velocity_x/velocity_x.dart';

class EditTodoScreen extends ConsumerStatefulWidget {
  const EditTodoScreen({super.key, required this.todo});

  final Todo todo;

  @override
  ConsumerState<EditTodoScreen> createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends ConsumerState<EditTodoScreen> {
  late final TextEditingController _titleController;
  // null = 기존 imageUrl 유지, XFile = 새 사진 선택, _photoCleared = 삭제
  XFile? _newPhoto;
  bool _photoCleared = false;
  late Set<String> _selectedTagIds;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _selectedTagIds = widget.todo.tagIds.toSet();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String? get _currentImageUrl =>
      _photoCleared || _newPhoto != null ? null : widget.todo.imageUrl;

  Future<void> _pickPhoto() async {
    final photo = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (photo != null) {
      setState(() {
        _newPhoto = photo;
        _photoCleared = false;
      });
    }
  }

  void _clearPhoto() {
    setState(() {
      _newPhoto = null;
      _photoCleared = true;
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      AppSnackBar.showError(context, '제목을 입력해 주세요');
      return;
    }

    setState(() => _isSaving = true);
    try {
      String? imageUrl = _currentImageUrl;
      if (_newPhoto != null) {
        final id = DateTime.now().millisecondsSinceEpoch.toString();
        final storageRef = FirebaseStorage.instance.ref('todo_images/$id');
        await storageRef.putFile(File(_newPhoto!.path));
        imageUrl = await storageRef.getDownloadURL();
      }

      final updated = Todo(
        userId: widget.todo.userId,
        id: widget.todo.id,
        title: title,
        imageUrl: imageUrl,
        tagIds: _selectedTagIds.toList(),
        createdAt: widget.todo.createdAt,
        updatedAt: DateTime.now(),
        isCompleted: widget.todo.isCompleted,
      );

      await ref.read(todoListProvider.notifier).edit(updated);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, '수정에 실패했습니다');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tagsAsync = ref.watch(tagListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        actions: [
          if (_isSaving)
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
                .onTap(_save),
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

        // Photo
        _buildPhotoSection(context, colors),
        32.heightBox,

        // Tags
        _buildTagSection(context, colors, tagsAsync),
      ]).px16().safeArea(),
    );
  }

  Widget _buildPhotoSection(BuildContext context, ColorScheme colors) {
    // 새로 선택한 사진
    if (_newPhoto != null) {
      return _buildSelectedLocalPhoto(_newPhoto!);
    }
    // 기존 사진 (삭제 안 된 경우)
    if (!_photoCleared && widget.todo.imageUrl != null) {
      return _buildSelectedNetworkPhoto(widget.todo.imageUrl!);
    }
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

  Widget _buildSelectedLocalPhoto(XFile photo) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(photo.path),
            width: double.infinity,
            height: 240,
            fit: BoxFit.cover,
          ),
        ),
        _closeButton(),
      ],
    );
  }

  Widget _buildSelectedNetworkPhoto(String url) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            url,
            width: double.infinity,
            height: 240,
            fit: BoxFit.cover,
          ),
        ),
        _closeButton(),
      ],
    );
  }

  Widget _closeButton() {
    return Positioned(
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
    );
  }

  Widget _buildTagSection(
    BuildContext context,
    ColorScheme colors,
    AsyncValue<List<Tag>> tagsAsync,
  ) {
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
                  final isSelected = _selectedTagIds.contains(tag.id);
                  return TodoTag(tag: tag)
                      .animate(target: isSelected ? 1.0 : 0.0)
                      .fadeIn(begin: 0.35, duration: 150.ms)
                      .onTap(
                        () => setState(
                          () => isSelected
                              ? _selectedTagIds.remove(tag.id)
                              : _selectedTagIds.add(tag.id),
                        ),
                      );
                }).toList(),
              ),
        loading: () => const CircularProgressIndicator().centered(),
        error: (e, _) => const SizedBox.shrink(),
      ),
    ]);
  }
}
