import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_app_2/core/widgets/app_header.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../core/services/app_snack_bar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../data/datasources/user_datasource_firebase.dart';
import '../../domain/models/user.dart';
import '../providers/user_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
      String? profileUrl;
      if (selectedImage != null) {
        final ds = UserDatasourceFirebase();
        profileUrl = await ds.uploadProfileImage(uid, selectedImage);
      }

      await ref
          .read(userProvider.notifier)
          .save(User(id: uid, name: name, profileUrl: profileUrl));
      // userProvider now has data → app.dart routes to ListScreen automatically
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selectedImage = ref.watch(_selectedImageProvider);
    final isLoading = ref.watch(_isLoadingProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: '프로필 설정'.text.xl2.bold.color(colors.onPrimary).make(),
      ),
      body: VStack(
        [
          GestureDetector(
            onTap: _showImageSourceSheet,
            child: CircleAvatar(
              radius: 56,
              backgroundImage: selectedImage != null
                  ? FileImage(selectedImage)
                  : null,
              child: selectedImage == null
                  ? const Icon(Icons.add_a_photo, size: 32)
                  : null,
            ),
          ).centered(),
          16.heightBox,

          AppHeader(
            title: '사진 업로드',
            subtitle: '프로필 사진을 업로드해주세요.',
            alignment: CrossAxisAlignment.center,
            titleStyle: TextStyle(color: colors.onPrimary),
          ).centered(),
          24.heightBox,

          AppTextField(
            label: '이름',
            controller: _nameController,
            hintText: '이름을 입력해주세요',
            textInputAction: TextInputAction.done,
          ),
          32.heightBox,
          AppButton(label: '시작하기', onPressed: _save, isLoading: isLoading),
        ],
        alignment: MainAxisAlignment.center,
        axisSize: MainAxisSize.max,
      ).p24(),
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
