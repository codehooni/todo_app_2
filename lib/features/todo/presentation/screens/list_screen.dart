import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../../core/services/debounce_service.dart';
import '../../../../core/services/time_service.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/models/tag.dart';
import '../../domain/models/todo.dart';
import '../providers/tag_list_provider.dart';
import '../providers/todo_list_provider.dart';
import '../widgets/todo_check_box.dart';
import '../widgets/todo_tag.dart';
import 'add_todo_screen.dart';
import 'todo_detail_screen.dart';

import '../../../user/domain/models/user.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../../../user/presentation/screens/profile_edit_sheet.dart';
import '../../../../core/providers/theme_provider.dart';

class _SelectedTagNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String? tagId) => state = tagId;
}

final _selectedTagProvider = NotifierProvider<_SelectedTagNotifier, String?>(
  _SelectedTagNotifier.new,
);

class _SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String query) => state = query;
}

final _searchQueryProvider = NotifierProvider<_SearchQueryNotifier, String>(
  _SearchQueryNotifier.new,
);

enum CompletionFilter { all, active, completed }

class _CompletionFilterNotifier extends Notifier<CompletionFilter> {
  @override
  CompletionFilter build() => CompletionFilter.all;
  void set(CompletionFilter filter) => state = filter;
}

final _completionFilterProvider =
    NotifierProvider<_CompletionFilterNotifier, CompletionFilter>(
      _CompletionFilterNotifier.new,
    );

class ListScreen extends ConsumerStatefulWidget {
  const ListScreen({super.key});

  @override
  ConsumerState<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends ConsumerState<ListScreen> {
  late final TextEditingController _searchController;
  late final DebounceService _debounce;

  @override
  void initState() {
    super.initState();
    _debounce = DebounceService();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      _debounce.run(() {
        ref.read(_searchQueryProvider.notifier).update(_searchController.text);
      });
    });
  }

  @override
  void dispose() {
    _debounce.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final userAsync = ref.watch(userProvider);
    final selectedTagId = ref.watch(_selectedTagProvider);
    final completionFilter = ref.watch(_completionFilterProvider);

    return Scaffold(
      backgroundColor: colors.surface,
      body: VStack([
        // User Profile
        _buildUserProfile(colors, userAsync),
        24.heightBox,

        // Search Bar
        _buildSearchBar(context, colors, _searchController),
        16.heightBox,

        // Tag Filter
        _buildTagFilter(colors, selectedTagId),
        24.heightBox,

        // Tasks
        _buildTasks(context, colors, selectedTagId, completionFilter),
      ]).p16().safeArea().onTap(() => FocusScope.of(context).unfocus()),

      // Add Task
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddTodoScreen()),
        ),
        child: Icon(Icons.add, color: colors.onSecondary),
      ),
    );
  }

  Widget _buildTasks(
    BuildContext context,
    ColorScheme colors,
    String? selectedTagId,
    CompletionFilter completionFilter,
  ) {
    final todosAsync = ref.watch(todoListProvider);
    final tagsAsync = ref.watch(tagListProvider);

    final searchQuery = ref.watch(_searchQueryProvider).toLowerCase();

    return todosAsync.when(
      loading: () => const CircularProgressIndicator().centered(),
      error: (e, _) => 'Error'.text.makeCentered(),
      data: (todos) {
        final tags = tagsAsync.asData?.value ?? [];
        final filtered = todos.where((t) {
          final matchesTag =
              selectedTagId == null || t.tagIds.contains(selectedTagId);
          final matchesSearch =
              searchQuery.isEmpty ||
              t.title.toLowerCase().contains(searchQuery);
          final matchesCompletion = switch (completionFilter) {
            CompletionFilter.all => true,
            CompletionFilter.active => !t.isCompleted,
            CompletionFilter.completed => t.isCompleted,
          };
          return matchesTag && matchesSearch && matchesCompletion;
        }).toList();

        return VStack([
          '최근 할 일'.text.lg.bold.color(colors.onPrimaryContainer).make(),
          16.heightBox,
          if (filtered.isEmpty)
            '할 일이 없습니다'.text.base
                .color(colors.onSurface.withAlpha(120))
                .make()
                .py16(),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            itemBuilder: (_, i) => _buildTodoCard(
              context,
              colors,
              filtered[i],
              tags,
            ).pOnly(bottom: 12),
          ),
        ]);
      },
    );
  }

  Widget _buildTodoCard(
    BuildContext context,
    ColorScheme colors,
    Todo todo,
    List<Tag> tags,
  ) {
    Tag? findTag(String id) {
      for (final t in tags) {
        if (t.id == id) return t;
      }
      return null;
    }

    final todoTags = todo.tagIds.map(findTag).whereType<Tag>().toList();

    final card =
        HStack([
              // Check Box
              TodoCheckBox(
                colors: colors,
                isSelected: todo.isCompleted,
                onTap: () =>
                    ref.read(todoListProvider.notifier).toggleComplete(todo),
              ),
              14.widthBox,

              // Content
              VStack([
                HStack([
                  // Title
                  (todo.isCompleted
                          ? todo.title.text.xl.semiBold
                                .color(colors.onPrimary.withAlpha(240))
                                .lineThrough
                          : todo.title.text.xl.semiBold.color(
                              colors.onPrimary.withAlpha(240),
                            ))
                      .make()
                      .expand(),

                  // Time
                  TimeService.formatRelative(todo.updatedAt).text.sm
                      .color(colors.onTertiary)
                      .makeCentered()
                      .pOnly(top: 3)
                      .px8()
                      .box
                      .roundedSM
                      .color(colors.tertiary)
                      .make(),
                ]),
                if (todoTags.isNotEmpty) ...[
                  12.heightBox,
                  HStack([
                    for (int i = 0; i < todoTags.length; i++) ...[
                      if (i > 0) 6.widthBox,
                      TodoTag(tag: todoTags[i]),
                    ],
                  ]),
                ],
              ]).expand(),
            ], crossAlignment: CrossAxisAlignment.start)
            .p16()
            .box
            .rounded
            .color(
              colors.secondaryContainer.withAlpha(todo.isCompleted ? 80 : 255),
            )
            .border(color: colors.onSecondaryContainer.withAlpha(60))
            .make()
            .onTap(
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TodoDetailScreen(todoId: todo.id),
                ),
              ),
            );

    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => ref.read(todoListProvider.notifier).remove(todo.id),
      background: HStack([
        const Spacer(),
        Icon(Icons.delete_outline, color: colors.error, size: 24),
        12.widthBox,
      ]).pOnly(right: 16).box.rounded.color(Colors.transparent).make(),
      child: card,
    );
  }

  Widget _buildUserProfile(ColorScheme colors, AsyncValue<User?> userAsync) {
    final name = userAsync.when(
      data: (user) => user?.name ?? '...',
      loading: () => '...',
      error: (e, s) => '...',
    );
    final profileUrl = userAsync.whenOrNull(data: (user) => user?.profileUrl);

    return HStack([
      // 사진
      CircleAvatar(
        radius: 28,
        backgroundColor: colors.onPrimary,
        backgroundImage: profileUrl != null ? NetworkImage(profileUrl) : null,
        child: profileUrl == null
            ? Icon(Icons.person, color: colors.primary, size: 32)
            : null,
      ).onTap(() {
        final user = userAsync.asData?.value;
        if (user == null) return;
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => ProfileEditSheet(user: user),
        );
      }),
      12.widthBox,

      // 인사
      VStack([
        'Hello,'.text.xl.color(colors.onPrimaryContainer).make(),
        '$name 👋'.text.xl2.bold.color(colors.onPrimary).make(),
      ]).expand(),

      // 테마 토글
      Builder(
        builder: (context) {
          final themeMode = ref.watch(themeModeProvider);
          final isDark = themeMode == ThemeMode.dark;
          return Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: colors.onPrimaryContainer,
              )
              .p12()
              .box
              .roundedFull
              .color(colors.primaryContainer)
              .make()
              .onTap(() => ref.read(themeModeProvider.notifier).toggle());
        },
      ),
    ]);
  }

  Widget _buildSearchBar(
    BuildContext context,
    ColorScheme colors,
    TextEditingController controller,
  ) {
    return HStack([
      AppTextField(
        controller: controller,
        prefixIcon: Icon(Icons.search, color: colors.onSecondaryContainer),
        hintText: 'Search Tasks',
        borderRadius: 16,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
      ).expand(),
      8.widthBox,
      Icon(Icons.tune, color: colors.onSecondary, size: 24)
          .p12()
          .box
          .rounded
          .color(colors.primary)
          .make()
          .onTap(() => _showFilterSheet(context, colors)),
    ]);
  }

  void _showFilterSheet(BuildContext context, ColorScheme colors) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final current = ref.watch(_completionFilterProvider);

            Widget filterTile(
              String label,
              String subtitle,
              CompletionFilter value,
            ) {
              final selected = current == value;
              return ListTile(
                title: label.text.base.bold.make(),
                subtitle: subtitle.text.sm
                    .color(colors.onPrimaryContainer)
                    .make(),
                trailing: selected
                    ? Icon(Icons.check_circle, color: colors.primary)
                    : Icon(
                        Icons.circle_outlined,
                        color: colors.onPrimaryContainer,
                      ),
                onTap: () {
                  ref.read(_completionFilterProvider.notifier).set(value);
                  Navigator.pop(ctx);
                },
              );
            }

            return VStack([
              '필터'.text.xl.bold.make(),
              16.heightBox,
              filterTile('전체', '모든 할 일 표시', CompletionFilter.all),
              filterTile('진행 중', '완료되지 않은 할 일만 표시', CompletionFilter.active),
              filterTile('완료됨', '완료된 할 일만 표시', CompletionFilter.completed),
            ]).p24();
          },
        );
      },
    );
  }

  Widget _buildTagFilter(ColorScheme colors, String? selectedTagId) {
    final tags = ref.watch(tagListProvider).asData?.value ?? [];

    bool isSelected(String? tagId) => selectedTagId == tagId;

    ChoiceChip buildChip(String label, String? tagId) {
      final selected = isSelected(tagId);
      return ChoiceChip(
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        selected: selected,
        onSelected: (_) =>
            ref.read(_selectedTagProvider.notifier).select(tagId),
        backgroundColor: colors.primaryContainer,
        selectedColor: colors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        side: selected
            ? BorderSide(color: colors.primary)
            : BorderSide(color: colors.onSecondaryContainer.withAlpha(60)),
        labelStyle: TextStyle(
          color: selected ? colors.onSecondary : colors.onPrimaryContainer,
        ),
        showCheckmark: false,
      );
    }

    return HStack([
      buildChip('All', null),
      for (final tag in tags) ...[8.widthBox, buildChip(tag.title, tag.id)],
    ]).scrollHorizontal();
  }
}
