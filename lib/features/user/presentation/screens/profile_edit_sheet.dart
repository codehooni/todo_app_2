import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../core/services/app_snack_bar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_repository_provider.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../data/datasources/user_datasource_firebase.dart';
import '../../domain/models/user.dart';
import '../../../todo/presentation/providers/draft_provider.dart';
import '../providers/user_provider.dart';

class ProfileEditSheet extends ConsumerStatefulWidget {
  const ProfileEditSheet({super.key, required this.user});

  final User user;

  @override
  ConsumerState<ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends ConsumerState<ProfileEditSheet> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    Future.microtask(() {
      ref.read(_selectedImageProvider.notifier).update(null);
      ref.read(_isLoadingProvider.notifier).update(false);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      ref.read(_selectedImageProvider.notifier).update(File(picked.path));
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: VStack([
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: '갤러리에서 선택'.text.make(),
            onTap: () {
              Navigator.pop(ctx);
              _pickImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: '카메라로 촬영'.text.make(),
            onTap: () {
              Navigator.pop(ctx);
              _pickImage(ImageSource.camera);
            },
          ),
        ], axisSize: MainAxisSize.min),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      AppSnackBar.show(context, '이름을 입력해주세요.');
      return;
    }

    ref.read(_isLoadingProvider.notifier).update(true);
    try {
      final uid = await ref.read(authStateProvider.future);
      if (uid == null) return;

      final selectedImage = ref.read(_selectedImageProvider);
      String? newUrl;
      if (selectedImage != null) {
        final ds = UserDatasourceFirebase();
        newUrl = await ds.uploadProfileImage(uid, selectedImage);
      }

      await ref
          .read(userProvider.notifier)
          .save(
            User(
              id: uid,
              name: name,
              profileUrl: newUrl ?? widget.user.profileUrl,
            ),
          );

      if (mounted) {
        Navigator.pop(context);
        AppSnackBar.show(context, '저장되었습니다.');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, '저장 실패: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        ref.read(_isLoadingProvider.notifier).update(false);
      }
    }
  }

  Future<void> _logout() async {
    Navigator.pop(context);
    await ref.read(draftProvider.notifier).clear();
    await ref.read(authRepositoryProvider).signOut();
    // authStateProvider가 null 방출 → app.dart가 자동으로 LoginScreen으로 이동
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selectedImage = ref.watch(_selectedImageProvider);
    final isLoading = ref.watch(_isLoadingProvider);

    final profileImage = selectedImage != null
        ? FileImage(selectedImage) as ImageProvider
        : widget.user.profileUrl != null
        ? NetworkImage(widget.user.profileUrl!) as ImageProvider
        : null;

    return SafeArea(
      child: VStack([
        GestureDetector(
          onTap: _showImageSourceSheet,
          child: CircleAvatar(
            radius: 48,
            backgroundColor: colors.primaryContainer,
            backgroundImage: profileImage,
            child: profileImage == null
                ? Icon(Icons.person, size: 48, color: colors.primary)
                : null,
          ),
        ).centered(),
        16.heightBox,

        AppTextField(
          label: '이름',
          controller: _nameController,
          hintText: '이름을 입력해주세요',
          textInputAction: TextInputAction.done,
        ),
        24.heightBox,

        AppButton(label: '저장', onPressed: _save, isLoading: isLoading),
        16.heightBox,

        '로그아웃'.text.xl.color(colors.error).bold.makeCentered().onTap(_logout),
      ]).p24(),
    );
  }
}

class _SelectedImageNotifier extends Notifier<File?> {
  @override
  File? build() => null;
  void update(File? image) => state = image;
}

final _selectedImageProvider = NotifierProvider<_SelectedImageNotifier, File?>(
  _SelectedImageNotifier.new,
);

class _IsLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void update(bool value) => state = value;
}

final _isLoadingProvider = NotifierProvider<_IsLoadingNotifier, bool>(
  _IsLoadingNotifier.new,
);
