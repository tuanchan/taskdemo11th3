// app.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'logic.dart';

// ─── Font note ────────────────────────────────────────────────────────────────
// Using system default sans-serif (SF Pro on iOS, Roboto on Android).
// SF Pro is what Messenger uses on iOS — it's the system font, cannot be bundled,
// but Flutter defaults to it on iOS automatically. No extra font needed.
// We mimic Messenger's bold, tight header by using fontWeight w700+, letter spacing -0.5.

// ─── Theme ────────────────────────────────────────────────────────────────────
class AppTheme {
  static const _seed = Color(0xFF6C63FF);

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _seed,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1C1C1E),
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: null, // system (SF Pro on iOS)
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Color(0xFF1C1C1E),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F5F7),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide.none,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: _seed,
          unselectedItemColor: Color(0xFF8E8E93),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _seed,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1C1C1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C2C2E),
          foregroundColor: Color(0xFFF5F5F7),
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: null,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Color(0xFFF5F5F7),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: const Color(0xFF2C2C2E),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF3A3A3C),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide.none,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF2C2C2E),
          selectedItemColor: Color(0xFF6C63FF),
          unselectedItemColor: Color(0xFF8E8E93),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      );
}

// ─── Root App ─────────────────────────────────────────────────────────────────
class TaskFlowApp extends StatefulWidget {
  final AppState appState;
  const TaskFlowApp({super.key, required this.appState});

  @override
  State<TaskFlowApp> createState() => _TaskFlowAppState();
}

class _TaskFlowAppState extends State<TaskFlowApp> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'TaskFlow',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode:
              widget.appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: MainShell(appState: widget.appState),
        );
      },
    );
  }
}

// ─── Main Shell with bottom nav ───────────────────────────────────────────────
class MainShell extends StatefulWidget {
  final AppState appState;
  const MainShell({super.key, required this.appState});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(appState: widget.appState),
      KanbanScreen(appState: widget.appState),
      SearchScreen(appState: widget.appState),
      ArchiveScreen(appState: widget.appState),
    ];

    return Scaffold(
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.15))),
        ),
        child: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (i) => setState(() => _tab = i),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.house_fill), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.square_grid_2x2_fill),
                label: 'Board'),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.search), label: 'Search'),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.archivebox_fill), label: 'Archive'),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DASHBOARD SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class DashboardScreen extends StatelessWidget {
  final AppState appState;
  const DashboardScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final cs = Theme.of(context).colorScheme;
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                title: const Text('TaskFlow'),
                actions: [
                  IconButton(
                    icon: Icon(appState.isDarkMode
                        ? CupertinoIcons.sun_max_fill
                        : CupertinoIcons.moon_fill),
                    onPressed: appState.toggleDarkMode,
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _StatsGrid(appState: appState),
                    const SizedBox(height: 24),
                    _SectionHeader(
                      title: 'Recent Boards',
                      action: TextButton(
                        onPressed: () => _showBoardManager(context),
                        child: const Text('Manage'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _RecentBoards(appState: appState),
                    const SizedBox(height: 24),
                    _SectionHeader(
                      title: "Today's Tasks",
                      action: null,
                    ),
                    const SizedBox(height: 8),
                    _TodayTaskList(appState: appState),
                    const SizedBox(height: 24),
                    _SectionHeader(title: 'High Priority', action: null),
                    const SizedBox(height: 8),
                    _HighPriorityList(appState: appState),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBoardManager(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BoardManagerSheet(appState: appState),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final AppState appState;
  const _StatsGrid({required this.appState});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
            label: 'Total',
            value: appState.totalTasks,
            color: const Color(0xFF6C63FF),
            icon: CupertinoIcons.square_stack_3d_up_fill),
        _StatCard(
            label: 'Today',
            value: appState.todayTasks,
            color: const Color(0xFF00BFA5),
            icon: CupertinoIcons.calendar),
        _StatCard(
            label: 'Overdue',
            value: appState.overdueTasks,
            color: const Color(0xFFFF3B30),
            icon: CupertinoIcons.alarm_fill),
        _StatCard(
            label: 'Done',
            value: appState.doneTasks,
            color: const Color(0xFF34C759),
            icon: CupertinoIcons.checkmark_circle_fill),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$value',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: color,
                      height: 1)),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: color.withOpacity(0.8),
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;
  const _SectionHeader({required this.title, required this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3)),
        const Spacer(),
        if (action != null) action!,
      ],
    );
  }
}

class _RecentBoards extends StatelessWidget {
  final AppState appState;
  const _RecentBoards({required this.appState});

  @override
  Widget build(BuildContext context) {
    final boards = appState.recentBoards;
    if (boards.isEmpty) {
      return const _EmptyHint(text: 'No boards yet');
    }
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: boards.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          if (i == boards.length) {
            return _AddBoardCard(onTap: () => _showCreateBoard(context));
          }
          final b = boards[i];
          final color = Color(b.colorValue);
          final count = appState.tasks
              .where((t) => t.boardId == b.id && !t.isArchived)
              .length;
          return GestureDetector(
            onTap: () => appState.selectBoard(b.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 140,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: appState.currentBoardId == b.id
                    ? color
                    : color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: appState.currentBoardId == b.id
                    ? null
                    : Border.all(color: color.withOpacity(0.3), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: appState.currentBoardId == b.id
                              ? Colors.white
                              : color)),
                  const SizedBox(height: 4),
                  Text('$count tasks',
                      style: TextStyle(
                          fontSize: 12,
                          color: appState.currentBoardId == b.id
                              ? Colors.white70
                              : color.withOpacity(0.7))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreateBoard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateBoardSheet(appState: appState),
    );
  }
}

class _AddBoardCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddBoardCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.add_circled,
                color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(height: 4),
            Text('New',
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _TodayTaskList extends StatelessWidget {
  final AppState appState;
  const _TodayTaskList({required this.appState});

  @override
  Widget build(BuildContext context) {
    final tasks =
        appState.tasks.where((t) => t.isDueToday && !t.isArchived).toList();
    if (tasks.isEmpty) return const _EmptyHint(text: 'No tasks due today 🎉');
    return Column(
        children: tasks
            .map((t) => _MiniTaskTile(task: t, appState: appState))
            .toList());
  }
}

class _HighPriorityList extends StatelessWidget {
  final AppState appState;
  const _HighPriorityList({required this.appState});

  @override
  Widget build(BuildContext context) {
    final tasks = appState.tasks
        .where((t) => t.priority == Priority.high && !t.isDone && !t.isArchived)
        .take(5)
        .toList();
    if (tasks.isEmpty) return const _EmptyHint(text: 'No high priority tasks');
    return Column(
        children: tasks
            .map((t) => _MiniTaskTile(task: t, appState: appState))
            .toList());
  }
}

class _MiniTaskTile extends StatelessWidget {
  final Task task;
  final AppState appState;
  const _MiniTaskTile({required this.task, required this.appState});

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(task.priority);
    return GestureDetector(
      onTap: () => _openTaskDetail(context, task, appState),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => appState.toggleDone(task.id),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  task.isDone
                      ? CupertinoIcons.checkmark_circle_fill
                      : CupertinoIcons.circle,
                  key: ValueKey(task.isDone),
                  color: task.isDone ? const Color(0xFF34C759) : Colors.grey,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        decoration:
                            task.isDone ? TextDecoration.lineThrough : null,
                        color: task.isDone ? Colors.grey : null,
                      )),
                  if (task.dueDate != null)
                    Text(
                      appState.formatDate(task.dueDate),
                      style: TextStyle(
                          fontSize: 12,
                          color: task.isOverdue
                              ? const Color(0xFFFF3B30)
                              : Colors.grey),
                    ),
                ],
              ),
            ),
            Container(
              width: 6,
              height: 6,
              decoration:
                  BoxDecoration(color: priorityColor, shape: BoxShape.circle),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
          child: Text(text,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14))),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// KANBAN SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class KanbanScreen extends StatefulWidget {
  final AppState appState;
  const KanbanScreen({super.key, required this.appState});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final board = widget.appState.currentBoard;
        return Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              onTap: () => _pickBoard(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (board != null)
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                          color: Color(board.colorValue),
                          shape: BoxShape.circle),
                    ),
                  Text(board?.name ?? 'Select Board'),
                  const SizedBox(width: 4),
                  const Icon(CupertinoIcons.chevron_down, size: 14),
                ],
              ),
            ),
            actions: [
              if (board != null)
                IconButton(
                  icon: const Icon(CupertinoIcons.plus_circle_fill),
                  onPressed: () => _addColumn(context, board.id),
                ),
              IconButton(
                icon: const Icon(CupertinoIcons.ellipsis_circle),
                onPressed: () => _showBoardOptions(context),
              ),
            ],
          ),
          body: board == null
              ? _EmptyBoardState(onCreateBoard: () => _showCreateBoard(context))
              : _KanbanBoard(appState: widget.appState, board: board),
          floatingActionButton: board == null
              ? null
              : FloatingActionButton(
                  onPressed: () => _createTask(context, board),
                  child: const Icon(CupertinoIcons.plus),
                ),
        );
      },
    );
  }

  void _pickBoard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BoardManagerSheet(appState: widget.appState),
    );
  }

  void _showBoardOptions(BuildContext context) {
    final board = widget.appState.currentBoard;
    if (board == null) return;
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: Text(board.name),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _editBoard(context, board);
            },
            child: const Text('Edit Board'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _deleteBoard(context, board);
            },
            child: const Text('Delete Board'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _addColumn(BuildContext context, String boardId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          CreateColumnSheet(appState: widget.appState, boardId: boardId),
    );
  }

  void _createTask(BuildContext context, Board board) {
    final cols = widget.appState.columnsForBoard(board.id);
    if (cols.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskFormSheet(
          appState: widget.appState,
          boardId: board.id,
          columnId: cols.first.id),
    );
  }

  void _editBoard(BuildContext context, Board board) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditBoardSheet(appState: widget.appState, board: board),
    );
  }

  void _deleteBoard(BuildContext context, Board board) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Delete Board?'),
        content: Text('This will delete "${board.name}" and all its tasks.'),
        actions: [
          CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context)),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              widget.appState.deleteBoard(board.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCreateBoard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateBoardSheet(appState: widget.appState),
    );
  }
}

class _EmptyBoardState extends StatelessWidget {
  final VoidCallback onCreateBoard;
  const _EmptyBoardState({required this.onCreateBoard});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.square_grid_2x2,
              size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No boards yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Create a board to get started',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          CupertinoButton.filled(
              onPressed: onCreateBoard, child: const Text('Create Board')),
        ],
      ),
    );
  }
}

class _KanbanBoard extends StatelessWidget {
  final AppState appState;
  final Board board;
  const _KanbanBoard({required this.appState, required this.board});

  @override
  Widget build(BuildContext context) {
    final cols = appState.columnsForBoard(board.id);
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: cols.length,
      itemBuilder: (context, i) => _KanbanColumnWidget(
        appState: appState,
        column: cols[i],
        board: board,
        colIndex: i,
        totalCols: cols.length,
      ),
    );
  }
}

class _KanbanColumnWidget extends StatefulWidget {
  final AppState appState;
  final KanbanColumn column;
  final Board board;
  final int colIndex;
  final int totalCols;

  const _KanbanColumnWidget({
    required this.appState,
    required this.column,
    required this.board,
    required this.colIndex,
    required this.totalCols,
  });

  @override
  State<_KanbanColumnWidget> createState() => _KanbanColumnWidgetState();
}

class _KanbanColumnWidgetState extends State<_KanbanColumnWidget> {
  bool _isDragTarget = false;

  @override
  Widget build(BuildContext context) {
    final tasks = widget.appState.tasksForColumn(widget.column.id);
    final colColor = Color(widget.column.colorValue);

    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) {
        final data = details.data;
        setState(() => _isDragTarget = data['columnId'] != widget.column.id);
        return true;
      },
      onLeave: (_) => setState(() => _isDragTarget = false),
      onAcceptWithDetails: (details) {
        setState(() => _isDragTarget = false);
        final data = details.data;
        widget.appState
            .moveTask(data['taskId'] as String, widget.column.id, tasks.length);
      },
      builder: (context, candidates, rejected) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 280,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: _isDragTarget
                ? colColor.withOpacity(0.08)
                : Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            border:
                _isDragTarget ? Border.all(color: colColor, width: 2) : null,
          ),
          child: Column(
            children: [
              // Column header
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 8, 8),
                child: Row(
                  children: [
                    Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: colColor, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(widget.column.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                    Text('${tasks.length}',
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(width: 4),
                    PopupMenuButton<String>(
                      icon: const Icon(CupertinoIcons.ellipsis,
                          size: 18, color: Colors.grey),
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                            value: 'add', child: Text('Add Task')),
                        const PopupMenuItem(
                            value: 'rename', child: Text('Rename')),
                        const PopupMenuItem(
                            value: 'color', child: Text('Change Color')),
                        if (widget.totalCols > 1)
                          const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete Column',
                                  style: TextStyle(color: Colors.red))),
                      ],
                      onSelected: (v) => _handleColumnAction(context, v),
                    ),
                  ],
                ),
              ),
              // Task list
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  buildDefaultDragHandles: false,
                  itemCount: tasks.length,
                  onReorder: (oldI, newI) => widget.appState
                      .reorderTaskInColumn(widget.column.id, oldI, newI),
                  itemBuilder: (context, idx) {
                    final task = tasks[idx];
                    return _TaskCard(
                      key: ValueKey(task.id),
                      task: task,
                      appState: widget.appState,
                      dragIndex: idx,
                      columnId: widget.column.id,
                    );
                  },
                ),
              ),
              // Add task button
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 14),
                child: GestureDetector(
                  onTap: () => _addTask(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: colColor.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colColor.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.plus, size: 16, color: colColor),
                        const SizedBox(width: 6),
                        Text('Add Task',
                            style: TextStyle(
                                fontSize: 13,
                                color: colColor,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleColumnAction(BuildContext context, String action) {
    switch (action) {
      case 'add':
        _addTask(context);
        break;
      case 'rename':
        _renameColumn(context);
        break;
      case 'color':
        _changeColumnColor(context);
        break;
      case 'delete':
        _deleteColumn(context);
        break;
    }
  }

  void _addTask(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskFormSheet(
        appState: widget.appState,
        boardId: widget.board.id,
        columnId: widget.column.id,
      ),
    );
  }

  void _renameColumn(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _RenameColumnSheet(appState: widget.appState, column: widget.column),
    );
  }

  void _changeColumnColor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ColorPickerSheet(
        initialColor: Color(widget.column.colorValue),
        onColorSelected: (c) =>
            widget.appState.updateColumn(widget.column.id, colorValue: c.value),
      ),
    );
  }

  void _deleteColumn(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Delete Column?'),
        content: Text('All tasks in "${widget.column.name}" will be deleted.'),
        actions: [
          CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context)),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              widget.appState.deleteColumn(widget.column.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─── Task Card ─────────────────────────────────────────────────────────────────
class _TaskCard extends StatelessWidget {
  final Task task;
  final AppState appState;
  final int dragIndex;
  final String columnId;

  const _TaskCard({
    super.key,
    required this.task,
    required this.appState,
    required this.dragIndex,
    required this.columnId,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(task.priority);
    return LongPressDraggable<Map<String, dynamic>>(
      data: {'taskId': task.id, 'columnId': columnId},
      delay: const Duration(milliseconds: 300),
      feedback: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 240,
          child: _TaskCardContent(
              task: task,
              appState: appState,
              priorityColor: priorityColor,
              isGhost: false),
        ),
      ),
      childWhenDragging: Opacity(
          opacity: 0.3,
          child: _TaskCardContent(
              task: task,
              appState: appState,
              priorityColor: priorityColor,
              isGhost: true)),
      child: ReorderableDragStartListener(
        index: dragIndex,
        child: GestureDetector(
          onTap: () => _openTaskDetail(context, task, appState),
          child: _TaskCardContent(
              task: task,
              appState: appState,
              priorityColor: priorityColor,
              isGhost: false),
        ),
      ),
    );
  }
}

class _TaskCardContent extends StatelessWidget {
  final Task task;
  final AppState appState;
  final Color priorityColor;
  final bool isGhost;

  const _TaskCardContent(
      {required this.task,
      required this.appState,
      required this.priorityColor,
      required this.isGhost});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isGhost
            ? []
            : [
                BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
        border: Border(left: BorderSide(color: priorityColor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      decoration:
                          task.isDone ? TextDecoration.lineThrough : null,
                      color: task.isDone ? Colors.grey : null,
                    )),
              ),
              if (task.isFavorite)
                const Icon(CupertinoIcons.heart_fill,
                    size: 14, color: Color(0xFFFF3B30)),
              if (task.isPinned) ...[
                const SizedBox(width: 4),
                const Icon(CupertinoIcons.pin_fill,
                    size: 14, color: Color(0xFFFF9500)),
              ],
            ],
          ),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
          if (task.subtasks.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(CupertinoIcons.checkmark_square,
                    size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${task.subtasks.where((s) => s.isDone).length}/${task.subtasks.length}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: task.subtasks.isEmpty
                          ? 0
                          : task.subtasks.where((s) => s.isDone).length /
                              task.subtasks.length,
                      minHeight: 4,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      color: const Color(0xFF34C759),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (task.progress > 0 && task.subtasks.isEmpty) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: task.progress / 100,
                minHeight: 4,
                backgroundColor: Colors.grey.withOpacity(0.2),
                color: priorityColor,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              if (task.dueDate != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: task.isOverdue
                        ? const Color(0xFFFF3B30).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.calendar,
                          size: 10,
                          color: task.isOverdue
                              ? const Color(0xFFFF3B30)
                              : Colors.grey),
                      const SizedBox(width: 3),
                      Text(appState.formatDate(task.dueDate),
                          style: TextStyle(
                            fontSize: 10,
                            color: task.isOverdue
                                ? const Color(0xFFFF3B30)
                                : Colors.grey,
                            fontWeight: FontWeight.w500,
                          )),
                    ],
                  ),
                ),
              const Spacer(),
              if (task.tags.isNotEmpty)
                Text('#${task.tags.first}',
                    style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic)),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SEARCH SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class SearchScreen extends StatefulWidget {
  final AppState appState;
  const SearchScreen({super.key, required this.appState});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final results = widget.appState.filteredTasks;
        return Scaffold(
          appBar: AppBar(title: const Text('Search')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _ctrl,
                  onChanged: (v) => widget.appState.searchQuery = v,
                  decoration: InputDecoration(
                    hintText: 'Search tasks…',
                    prefixIcon: const Icon(CupertinoIcons.search, size: 20),
                    suffixIcon: _ctrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(CupertinoIcons.clear_circled_solid,
                                size: 18),
                            onPressed: () {
                              _ctrl.clear();
                              widget.appState.searchQuery = '';
                              widget.appState.notifyListeners();
                            },
                          )
                        : null,
                  ),
                ),
              ),
              // Filter chips row
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _FilterChip(
                      label: 'Filters',
                      icon: CupertinoIcons.slider_horizontal_3,
                      selected: _showFilters,
                      onTap: () => setState(() => _showFilters = !_showFilters),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Today',
                      selected: widget.appState.filterOptions.onlyToday,
                      onTap: () {
                        widget.appState.filterOptions =
                            widget.appState.filterOptions.copyWith(
                                onlyToday:
                                    !widget.appState.filterOptions.onlyToday);
                        widget.appState.notifyListeners();
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Overdue',
                      selected: widget.appState.filterOptions.onlyOverdue,
                      onTap: () {
                        widget.appState.filterOptions =
                            widget.appState.filterOptions.copyWith(
                                onlyOverdue:
                                    !widget.appState.filterOptions.onlyOverdue);
                        widget.appState.notifyListeners();
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Favorites',
                      selected: widget.appState.filterOptions.onlyFavorite,
                      onTap: () {
                        widget.appState.filterOptions =
                            widget.appState.filterOptions.copyWith(
                                onlyFavorite: !widget
                                    .appState.filterOptions.onlyFavorite);
                        widget.appState.notifyListeners();
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: '🔴 High',
                      selected: widget.appState.filterOptions.priority ==
                          Priority.high,
                      onTap: () {
                        final cur = widget.appState.filterOptions.priority;
                        widget.appState.filterOptions =
                            widget.appState.filterOptions.copyWith(
                                priority: cur == Priority.high
                                    ? null
                                    : Priority.high);
                        widget.appState.notifyListeners();
                      },
                    ),
                  ],
                ),
              ),
              if (_showFilters) _FilterPanel(appState: widget.appState),
              const SizedBox(height: 8),
              Expanded(
                child: results.isEmpty
                    ? const Center(
                        child: Text('No results',
                            style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: results.length,
                        itemBuilder: (context, i) => _SearchResultTile(
                          task: results[i],
                          appState: widget.appState,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  const _FilterChip(
      {required this.label,
      required this.selected,
      required this.onTap,
      this.icon});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: selected ? Colors.white : color),
              const SizedBox(width: 4)
            ],
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: selected ? Colors.white : color,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  final AppState appState;
  const _FilterPanel({required this.appState});

  @override
  Widget build(BuildContext context) {
    final fo = appState.filterOptions;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sort by',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: SortBy.values.map((s) {
              final labels = {
                SortBy.manual: 'Manual',
                SortBy.deadline: 'Deadline',
                SortBy.createdAt: 'Created',
                SortBy.priority: 'Priority'
              };
              return GestureDetector(
                onTap: () {
                  appState.filterOptions = fo.copyWith(sortBy: s);
                  appState.notifyListeners();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: fo.sortBy == s
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(labels[s]!,
                      style: TextStyle(
                          fontSize: 12,
                          color: fo.sortBy == s ? Colors.white : null,
                          fontWeight: FontWeight.w500)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          const Text('Status',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: FilterStatus.values.map((s) {
              final labels = {
                FilterStatus.all: 'All',
                FilterStatus.active: 'Active',
                FilterStatus.done: 'Done',
                FilterStatus.archived: 'Archived'
              };
              return GestureDetector(
                onTap: () {
                  appState.filterOptions = fo.copyWith(status: s);
                  appState.notifyListeners();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: fo.status == s
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(labels[s]!,
                      style: TextStyle(
                          fontSize: 12,
                          color: fo.status == s ? Colors.white : null,
                          fontWeight: FontWeight.w500)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final Task task;
  final AppState appState;
  const _SearchResultTile({required this.task, required this.appState});

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(task.priority);
    return GestureDetector(
      onTap: () => _openTaskDetail(context, task, appState),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: priorityColor, width: 3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          decoration:
                              task.isDone ? TextDecoration.lineThrough : null)),
                  if (task.description.isNotEmpty)
                    Text(task.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (task.dueDate != null)
                        Text(appState.formatDate(task.dueDate),
                            style: TextStyle(
                                fontSize: 11,
                                color: task.isOverdue
                                    ? const Color(0xFFFF3B30)
                                    : Colors.grey)),
                      const SizedBox(width: 8),
                      ...task.tags.take(2).map((tag) => Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text('#$tag',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                          )),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => appState.toggleDone(task.id),
              child: Icon(
                task.isDone
                    ? CupertinoIcons.checkmark_circle_fill
                    : CupertinoIcons.circle,
                color: task.isDone ? const Color(0xFF34C759) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ARCHIVE SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class ArchiveScreen extends StatelessWidget {
  final AppState appState;
  const ArchiveScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final archived = appState.tasks.where((t) => t.isArchived).toList();
        return Scaffold(
          appBar: AppBar(title: const Text('Archive')),
          body: archived.isEmpty
              ? const Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.archivebox,
                        size: 60, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('Archive is empty',
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: archived.length,
                  itemBuilder: (context, i) {
                    final task = archived[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(task.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey)),
                                Text('Archived',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade400)),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => appState.restoreTask(task.id),
                            child: const Text('Restore'),
                          ),
                          IconButton(
                            icon: const Icon(CupertinoIcons.trash,
                                color: Colors.red, size: 18),
                            onPressed: () => _confirmDelete(context, task),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Task task) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Delete permanently?'),
        actions: [
          CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context)),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              appState.deleteTask(task.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TASK DETAIL / EDIT
// ═══════════════════════════════════════════════════════════════════════════════
void _openTaskDetail(BuildContext context, Task task, AppState appState) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TaskDetailSheet(task: task, appState: appState),
  );
}

class TaskDetailSheet extends StatefulWidget {
  final Task task;
  final AppState appState;
  const TaskDetailSheet(
      {super.key, required this.task, required this.appState});

  @override
  State<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<TaskDetailSheet> {
  late Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  void _refresh() {
    final updated = widget.appState.tasks
        .firstWhere((t) => t.id == _task.id, orElse: () => _task);
    setState(() => _task = updated);
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(_task.priority);
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scroll) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2))),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
              child: Row(
                children: [
                  Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                          color: priorityColor, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(_task.title,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3)),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.pencil),
                    onPressed: () async {
                      Navigator.pop(context);
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => TaskFormSheet(
                            appState: widget.appState, existingTask: _task),
                      );
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(CupertinoIcons.ellipsis),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                          value: 'done', child: Text('Toggle Done')),
                      const PopupMenuItem(
                          value: 'fav', child: Text('Toggle Favorite')),
                      const PopupMenuItem(
                          value: 'pin', child: Text('Toggle Pin')),
                      const PopupMenuItem(
                          value: 'dup', child: Text('Duplicate')),
                      const PopupMenuItem(
                          value: 'archive', child: Text('Archive')),
                      const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete',
                              style: TextStyle(color: Colors.red))),
                    ],
                    onSelected: (v) => _handleAction(context, v),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.all(20),
                children: [
                  if (_task.description.isNotEmpty) ...[
                    _DetailSection(
                        label: 'Description', child: Text(_task.description)),
                    const SizedBox(height: 16),
                  ],
                  if (_task.note.isNotEmpty) ...[
                    _DetailSection(
                        label: 'Note',
                        child: Text(_task.note,
                            style: const TextStyle(color: Colors.grey))),
                    const SizedBox(height: 16),
                  ],
                  // Meta info grid
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (_task.dueDate != null)
                        _MetaChip(
                          icon: CupertinoIcons.calendar,
                          label: widget.appState.formatDate(_task.dueDate),
                          color:
                              _task.isOverdue ? const Color(0xFFFF3B30) : null,
                        ),
                      if (_task.dueTime != null)
                        _MetaChip(
                            icon: CupertinoIcons.clock,
                            label: widget.appState.formatTime(_task.dueTime)),
                      _MetaChip(
                        icon: CupertinoIcons.flag_fill,
                        label: _task.priority.name.capitalize(),
                        color: priorityColor,
                      ),
                      if (_task.estimatedMinutes > 0)
                        _MetaChip(
                            icon: CupertinoIcons.stopwatch,
                            label: '${_task.estimatedMinutes} min est.'),
                      if (_task.actualMinutes > 0)
                        _MetaChip(
                            icon: CupertinoIcons.checkmark_circle,
                            label: '${_task.actualMinutes} min actual'),
                      if (_task.reminderAt != null)
                        _MetaChip(
                            icon: CupertinoIcons.bell_fill,
                            label:
                                'Reminder: ${widget.appState.formatDateTime(_task.reminderAt)}',
                            color: const Color(0xFF6C63FF)),
                    ],
                  ),
                  if (_task.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 6,
                      children: _task.tags
                          .map((t) => Chip(
                                label: Text('#$t',
                                    style: const TextStyle(fontSize: 12)),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList(),
                    ),
                  ],
                  if (_task.progress > 0) ...[
                    const SizedBox(height: 16),
                    _DetailSection(
                      label: 'Progress ${_task.progress}%',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: _task.progress / 100,
                          minHeight: 8,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          color: priorityColor,
                        ),
                      ),
                    ),
                  ],
                  if (_task.subtasks.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _DetailSection(
                      label:
                          'Checklist ${_task.subtasks.where((s) => s.isDone).length}/${_task.subtasks.length}',
                      child: Column(
                        children: _task.subtasks
                            .map((s) => CheckboxListTile(
                                  value: s.isDone,
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(s.title,
                                      style: TextStyle(
                                        decoration: s.isDone
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: s.isDone ? Colors.grey : null,
                                        fontSize: 14,
                                      )),
                                  onChanged: (v) {
                                    final updated = _task.copyWith(
                                      subtasks: _task.subtasks
                                          .map((st) => st.id == s.id
                                              ? st.copyWith(isDone: v ?? false)
                                              : st)
                                          .toList(),
                                    );
                                    widget.appState
                                        .updateTask(_task.id, updated);
                                    _refresh();
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Created ${widget.appState.formatDateTime(_task.createdAt)}\nUpdated ${widget.appState.formatDateTime(_task.updatedAt)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'done':
        widget.appState.toggleDone(_task.id);
        _refresh();
        break;
      case 'fav':
        widget.appState.toggleFavorite(_task.id);
        _refresh();
        break;
      case 'pin':
        widget.appState.togglePin(_task.id);
        _refresh();
        break;
      case 'dup':
        widget.appState.duplicateTask(_task.id);
        Navigator.pop(context);
        break;
      case 'archive':
        widget.appState.archiveTask(_task.id);
        Navigator.pop(context);
        break;
      case 'delete':
        showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: const Text('Delete task?'),
            actions: [
              CupertinoDialogAction(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context)),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context);
                  widget.appState.deleteTask(_task.id);
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        break;
    }
  }
}

class _DetailSection extends StatelessWidget {
  final String label;
  final Widget child;
  const _DetailSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _MetaChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: c),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: c, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TASK FORM SHEET (create / edit)
// ═══════════════════════════════════════════════════════════════════════════════
class TaskFormSheet extends StatefulWidget {
  final AppState appState;
  final String? boardId;
  final String? columnId;
  final Task? existingTask;

  const TaskFormSheet({
    super.key,
    required this.appState,
    this.boardId,
    this.columnId,
    this.existingTask,
  });

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _progressCtrl = TextEditingController();
  final _estCtrl = TextEditingController();
  final _actCtrl = TextEditingController();
  final _subtaskCtrl = TextEditingController();

  Priority _priority = Priority.medium;
  bool _isFavorite = false;
  bool _isPinned = false;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  DateTime? _reminderAt;
  List<String> _tags = [];
  int _progress = 0;
  int _estimatedMinutes = 0;
  int _actualMinutes = 0;
  List<SubTask> _subtasks = [];
  String? _selectedColumnId;

  bool get _isEdit => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final t = widget.existingTask!;
      _titleCtrl.text = t.title;
      _descCtrl.text = t.description;
      _noteCtrl.text = t.note;
      _priority = t.priority;
      _isFavorite = t.isFavorite;
      _isPinned = t.isPinned;
      _dueDate = t.dueDate;
      _dueTime = t.dueTime;
      _reminderAt = t.reminderAt;
      _tags = List.from(t.tags);
      _tagsCtrl.text = t.tags.join(', ');
      _progress = t.progress;
      _progressCtrl.text = t.progress.toString();
      _estimatedMinutes = t.estimatedMinutes;
      _estCtrl.text =
          t.estimatedMinutes > 0 ? t.estimatedMinutes.toString() : '';
      _actualMinutes = t.actualMinutes;
      _actCtrl.text = t.actualMinutes > 0 ? t.actualMinutes.toString() : '';
      _subtasks = List.from(t.subtasks);
      _selectedColumnId = t.columnId;
    } else {
      _selectedColumnId = widget.columnId;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _noteCtrl.dispose();
    _tagsCtrl.dispose();
    _progressCtrl.dispose();
    _estCtrl.dispose();
    _actCtrl.dispose();
    _subtaskCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) return;
    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final progress = int.tryParse(_progressCtrl.text) ?? _progress;
    final est = int.tryParse(_estCtrl.text) ?? 0;
    final act = int.tryParse(_actCtrl.text) ?? 0;

    if (_isEdit) {
      final updated = widget.existingTask!.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        note: _noteCtrl.text.trim(),
        priority: _priority,
        isFavorite: _isFavorite,
        isPinned: _isPinned,
        dueDate: _dueDate,
        dueTime: _dueTime,
        reminderAt: _reminderAt,
        tags: tags,
        progress: progress.clamp(0, 100),
        estimatedMinutes: est,
        actualMinutes: act,
        subtasks: _subtasks,
        columnId: _selectedColumnId ?? widget.existingTask!.columnId,
      );
      widget.appState.updateTask(widget.existingTask!.id, updated);
    } else {
      widget.appState.createTask(
        boardId: widget.boardId!,
        columnId: _selectedColumnId ?? widget.columnId!,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        note: _noteCtrl.text.trim(),
        priority: _priority,
        isFavorite: _isFavorite,
        isPinned: _isPinned,
        dueDate: _dueDate,
        dueTime: _dueTime,
        reminderAt: _reminderAt,
        tags: tags,
        progress: progress.clamp(0, 100),
        estimatedMinutes: est,
        actualMinutes: act,
        subtasks: _subtasks,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.97,
      minChildSize: 0.5,
      builder: (context, scroll) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 8, 0),
              child: Row(
                children: [
                  Text(_isEdit ? 'Edit Task' : 'New Task',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3)),
                  const Spacer(),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  const SizedBox(width: 4),
                  CupertinoButton(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: _save,
                    child: const Text('Save',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.all(20),
                children: [
                  // Title
                  TextField(
                    controller: _titleCtrl,
                    autofocus: !_isEdit,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(hintText: 'Task title…'),
                  ),
                  const SizedBox(height: 12),
                  // Description
                  TextField(
                    controller: _descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        hintText: 'Description (optional)'),
                  ),
                  const SizedBox(height: 12),
                  // Note
                  TextField(
                    controller: _noteCtrl,
                    maxLines: 2,
                    decoration:
                        const InputDecoration(hintText: 'Note (optional)'),
                  ),
                  const SizedBox(height: 16),
                  // Priority
                  _FormLabel('Priority'),
                  const SizedBox(height: 8),
                  Row(
                    children: Priority.values.map((p) {
                      final color = _priorityColor(p);
                      final selected = _priority == p;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _priority = p),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color:
                                    selected ? color : color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(p.name.capitalize(),
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            selected ? Colors.white : color)),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Flags
                  Row(
                    children: [
                      _ToggleChip(
                          label: 'Favorite',
                          icon: CupertinoIcons.heart_fill,
                          active: _isFavorite,
                          color: const Color(0xFFFF3B30),
                          onTap: () =>
                              setState(() => _isFavorite = !_isFavorite)),
                      const SizedBox(width: 8),
                      _ToggleChip(
                          label: 'Pin',
                          icon: CupertinoIcons.pin_fill,
                          active: _isPinned,
                          color: const Color(0xFFFF9500),
                          onTap: () => setState(() => _isPinned = !_isPinned)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Due date
                  _FormLabel('Due Date'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .inputDecorationTheme
                                  .fillColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(CupertinoIcons.calendar,
                                    size: 18, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                    _dueDate != null
                                        ? widget.appState.formatDate(_dueDate)
                                        : 'No date',
                                    style: TextStyle(
                                        color: _dueDate != null
                                            ? null
                                            : Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickTime(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .inputDecorationTheme
                                  .fillColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(CupertinoIcons.clock,
                                    size: 18, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                    _dueTime != null
                                        ? widget.appState.formatTime(_dueTime)
                                        : 'No time',
                                    style: TextStyle(
                                        color: _dueTime != null
                                            ? null
                                            : Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Reminder
                  _FormLabel('Reminder'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _pickReminder(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).inputDecorationTheme.fillColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.bell,
                              size: 18, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _reminderAt != null
                                  ? widget.appState.formatDateTime(_reminderAt)
                                  : 'No reminder set',
                              style: TextStyle(
                                  color: _reminderAt != null
                                      ? const Color(0xFF6C63FF)
                                      : Colors.grey),
                            ),
                          ),
                          if (_reminderAt != null)
                            GestureDetector(
                              onTap: () => setState(() => _reminderAt = null),
                              child: const Icon(
                                  CupertinoIcons.clear_circled_solid,
                                  size: 16,
                                  color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Progress
                  _FormLabel('Progress %'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _progress.toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 20,
                          onChanged: (v) {
                            setState(() => _progress = v.round());
                            _progressCtrl.text = _progress.toString();
                          },
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        child: TextField(
                          controller: _progressCtrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13),
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8)),
                          onChanged: (v) => setState(() =>
                              _progress = (int.tryParse(v) ?? 0).clamp(0, 100)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Time estimates
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FormLabel('Est. min'),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _estCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(hintText: '0'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FormLabel('Actual min'),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _actCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(hintText: '0'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tags
                  _FormLabel('Tags'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _tagsCtrl,
                    decoration: const InputDecoration(
                        hintText: 'work, health, personal…'),
                  ),
                  const SizedBox(height: 16),
                  // Subtasks
                  _FormLabel('Checklist'),
                  const SizedBox(height: 8),
                  ..._subtasks.map((s) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: Checkbox(
                          value: s.isDone,
                          onChanged: (v) => setState(() {
                            final i =
                                _subtasks.indexWhere((st) => st.id == s.id);
                            _subtasks[i] = s.copyWith(isDone: v ?? false);
                          }),
                        ),
                        title: Text(s.title,
                            style: TextStyle(
                                decoration: s.isDone
                                    ? TextDecoration.lineThrough
                                    : null)),
                        trailing: IconButton(
                          icon: const Icon(CupertinoIcons.minus_circle,
                              color: Colors.red, size: 18),
                          onPressed: () => setState(() =>
                              _subtasks.removeWhere((st) => st.id == s.id)),
                        ),
                      )),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _subtaskCtrl,
                          decoration: const InputDecoration(
                              hintText: 'Add checklist item…'),
                          onSubmitted: _addSubtask,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.plus_circle_fill),
                        onPressed: () => _addSubtask(_subtaskCtrl.text),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addSubtask(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _subtasks.add(SubTask(id: newId(), title: text.trim()));
      _subtaskCtrl.clear();
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
        context: context, initialTime: _dueTime ?? TimeOfDay.now());
    if (picked != null) setState(() => _dueTime = picked);
  }

  Future<void> _pickReminder(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderAt ?? DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_reminderAt ?? DateTime.now()));
    if (time == null) return;
    setState(() {
      _reminderAt =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
            letterSpacing: 0.5));
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  const _ToggleChip(
      {required this.label,
      required this.icon,
      required this.active,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:
              active ? color.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: active ? Border.all(color: color.withOpacity(0.4)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: active ? color : Colors.grey),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: active ? color : Colors.grey,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BOARD MANAGER SHEET
// ═══════════════════════════════════════════════════════════════════════════════
class BoardManagerSheet extends StatelessWidget {
  final AppState appState;
  const BoardManagerSheet({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scroll) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 8, 0),
                child: Row(
                  children: [
                    const Text('Boards',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    TextButton.icon(
                      icon: const Icon(CupertinoIcons.plus, size: 16),
                      label: const Text('New'),
                      onPressed: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => CreateBoardSheet(appState: appState),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scroll,
                  padding: const EdgeInsets.all(16),
                  itemCount: appState.boards.length,
                  itemBuilder: (context, i) {
                    final board = appState.boards[i];
                    final color = Color(board.colorValue);
                    final count = appState.tasks
                        .where((t) => t.boardId == board.id && !t.isArchived)
                        .length;
                    return GestureDetector(
                      onTap: () {
                        appState.selectBoard(board.id);
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: appState.currentBoardId == board.id
                              ? color.withOpacity(0.15)
                              : Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          border: appState.currentBoardId == board.id
                              ? Border.all(color: color, width: 1.5)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Icon(CupertinoIcons.square_grid_2x2_fill,
                                  color: color, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(board.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15)),
                                  Text('$count tasks',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            if (appState.currentBoardId == board.id)
                              Icon(CupertinoIcons.checkmark_circle_fill,
                                  color: color),
                            PopupMenuButton<String>(
                              icon: const Icon(CupertinoIcons.ellipsis,
                                  size: 18, color: Colors.grey),
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                    value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete',
                                        style: TextStyle(color: Colors.red))),
                              ],
                              onSelected: (v) {
                                if (v == 'edit') {
                                  Navigator.pop(context);
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => EditBoardSheet(
                                        appState: appState, board: board),
                                  );
                                } else {
                                  _confirmDeleteBoard(context, board);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteBoard(BuildContext context, Board board) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Delete Board?'),
        content: Text('This will delete "${board.name}" and all its tasks.'),
        actions: [
          CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context)),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              appState.deleteBoard(board.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─── Create / Edit Board Sheet ────────────────────────────────────────────────
class CreateBoardSheet extends StatefulWidget {
  final AppState appState;
  const CreateBoardSheet({super.key, required this.appState});

  @override
  State<CreateBoardSheet> createState() => _CreateBoardSheetState();
}

class _CreateBoardSheetState extends State<CreateBoardSheet> {
  final _ctrl = TextEditingController();
  Color _selectedColor = const Color(0xFF6C63FF);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BoardFormContent(
      title: 'New Board',
      nameController: _ctrl,
      selectedColor: _selectedColor,
      onColorSelected: (c) => setState(() => _selectedColor = c),
      onSave: () {
        if (_ctrl.text.trim().isEmpty) return;
        widget.appState.createBoard(_ctrl.text.trim(), _selectedColor.value);
        Navigator.pop(context);
      },
    );
  }
}

class EditBoardSheet extends StatefulWidget {
  final AppState appState;
  final Board board;
  const EditBoardSheet(
      {super.key, required this.appState, required this.board});

  @override
  State<EditBoardSheet> createState() => _EditBoardSheetState();
}

class _EditBoardSheetState extends State<EditBoardSheet> {
  late final TextEditingController _ctrl;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.board.name);
    _selectedColor = Color(widget.board.colorValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BoardFormContent(
      title: 'Edit Board',
      nameController: _ctrl,
      selectedColor: _selectedColor,
      onColorSelected: (c) => setState(() => _selectedColor = c),
      onSave: () {
        if (_ctrl.text.trim().isEmpty) return;
        widget.appState.updateBoard(widget.board.id,
            name: _ctrl.text.trim(), colorValue: _selectedColor.value);
        Navigator.pop(context);
      },
    );
  }
}

class _BoardFormContent extends StatelessWidget {
  final String title;
  final TextEditingController nameController;
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;
  final VoidCallback onSave;

  const _BoardFormContent({
    required this.title,
    required this.nameController,
    required this.selectedColor,
    required this.onColorSelected,
    required this.onSave,
  });

  static const _colors = [
    Color(0xFF6C63FF),
    Color(0xFF00BFA5),
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFF9500),
    Color(0xFF34C759),
    Color(0xFF2196F3),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFFFF5722),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700)),
                const Spacer(),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Board name…'),
            ),
            const SizedBox(height: 16),
            const Text('COLOR',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey,
                    letterSpacing: 0.5)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _colors
                  .map((c) => GestureDetector(
                        onTap: () => onColorSelected(c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: selectedColor.value == c.value
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                            boxShadow: selectedColor.value == c.value
                                ? [
                                    BoxShadow(
                                        color: c.withOpacity(0.5),
                                        blurRadius: 8)
                                  ]
                                : null,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: selectedColor,
                borderRadius: BorderRadius.circular(14),
                onPressed: onSave,
                child: const Text('Save',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Create Column Sheet ──────────────────────────────────────────────────────
class CreateColumnSheet extends StatefulWidget {
  final AppState appState;
  final String boardId;
  const CreateColumnSheet(
      {super.key, required this.appState, required this.boardId});

  @override
  State<CreateColumnSheet> createState() => _CreateColumnSheetState();
}

class _CreateColumnSheetState extends State<CreateColumnSheet> {
  final _ctrl = TextEditingController();
  Color _color = const Color(0xFF6C63FF);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New Column',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
                controller: _ctrl,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Column name…')),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              children: [
                const Color(0xFF6C63FF),
                const Color(0xFFFF9800),
                const Color(0xFF4CAF50),
                const Color(0xFF2196F3),
                const Color(0xFFFF3B30),
                const Color(0xFF00BFA5),
              ]
                  .map((c) => GestureDetector(
                        onTap: () => setState(() => _color = c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: _color.value == c.value
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: _color,
                borderRadius: BorderRadius.circular(14),
                onPressed: () {
                  if (_ctrl.text.trim().isEmpty) return;
                  widget.appState.createColumn(
                      widget.boardId, _ctrl.text.trim(), _color.value);
                  Navigator.pop(context);
                },
                child: const Text('Create Column',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Rename Column Sheet ──────────────────────────────────────────────────────
class _RenameColumnSheet extends StatefulWidget {
  final AppState appState;
  final KanbanColumn column;
  const _RenameColumnSheet({required this.appState, required this.column});

  @override
  State<_RenameColumnSheet> createState() => _RenameColumnSheetState();
}

class _RenameColumnSheetState extends State<_RenameColumnSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.column.name);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Rename Column',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
                controller: _ctrl,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Column name…')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: Color(widget.column.colorValue),
                borderRadius: BorderRadius.circular(14),
                onPressed: () {
                  if (_ctrl.text.trim().isEmpty) return;
                  widget.appState
                      .updateColumn(widget.column.id, name: _ctrl.text.trim());
                  Navigator.pop(context);
                },
                child: const Text('Save',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Color Picker Sheet ───────────────────────────────────────────────────────
class _ColorPickerSheet extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorSelected;
  const _ColorPickerSheet(
      {required this.initialColor, required this.onColorSelected});

  @override
  State<_ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<_ColorPickerSheet> {
  late Color _selected;

  static const _colors = [
    Color(0xFF6C63FF),
    Color(0xFF00BFA5),
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFF9500),
    Color(0xFF34C759),
    Color(0xFF2196F3),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFFFF5722),
    Color(0xFF607D8B),
    Color(0xFF795548),
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Pick Color',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _colors
                .map((c) => GestureDetector(
                      onTap: () {
                        setState(() => _selected = c);
                        widget.onColorSelected(c);
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: _selected.value == c.value
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: _selected.value == c.value
                              ? [
                                  BoxShadow(
                                      color: c.withOpacity(0.5), blurRadius: 10)
                                ]
                              : null,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
Color _priorityColor(Priority p) {
  switch (p) {
    case Priority.low:
      return const Color(0xFF34C759);
    case Priority.medium:
      return const Color(0xFFFF9500);
    case Priority.high:
      return const Color(0xFFFF3B30);
  }
}

extension StringExt on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
