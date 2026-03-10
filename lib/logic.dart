import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

// ─── UUID helper ──────────────────────────────────────────────────────────────
const _uuid = Uuid();
String newId() => _uuid.v4();

// ─── Enums ────────────────────────────────────────────────────────────────────
enum Priority { low, medium, high }

// ─── Sentinel for copyWith nullable fields ────────────────────────────────────
const _sentinel = Object();

// ─── SubTask ──────────────────────────────────────────────────────────────────
class SubTask {
  String id;
  String title;
  bool isDone;

  SubTask({required this.id, required this.title, this.isDone = false});

  SubTask copyWith({String? id, String? title, bool? isDone}) => SubTask(
        id: id ?? this.id,
        title: title ?? this.title,
        isDone: isDone ?? this.isDone,
      );

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'isDone': isDone};

  factory SubTask.fromJson(Map<String, dynamic> j) =>
      SubTask(id: j['id'] ?? newId(), title: j['title'] ?? '', isDone: j['isDone'] ?? false);
}

// ─── Task ─────────────────────────────────────────────────────────────────────
class Task {
  String id;
  String boardId;
  String columnId;
  String title;
  String description;
  String note;
  Priority priority;
  bool isFavorite;
  bool isPinned;
  bool isArchived;
  bool isDone;
  DateTime? dueDate;
  TimeOfDay? dueTime;
  DateTime? reminderAt; // Ready for local_notifications hook — stored in model
  List<String> tags;
  int progress; // 0-100
  int estimatedMinutes;
  int actualMinutes;
  List<SubTask> subtasks;
  DateTime createdAt;
  DateTime updatedAt;
  int order;

  Task({
    required this.id,
    required this.boardId,
    required this.columnId,
    required this.title,
    this.description = '',
    this.note = '',
    this.priority = Priority.medium,
    this.isFavorite = false,
    this.isPinned = false,
    this.isArchived = false,
    this.isDone = false,
    this.dueDate,
    this.dueTime,
    this.reminderAt,
    List<String>? tags,
    this.progress = 0,
    this.estimatedMinutes = 0,
    this.actualMinutes = 0,
    List<SubTask>? subtasks,
    required this.createdAt,
    required this.updatedAt,
    this.order = 0,
  })  : tags = tags ?? [],
        subtasks = subtasks ?? [];

  Task copyWith({
    String? id,
    String? boardId,
    String? columnId,
    String? title,
    String? description,
    String? note,
    Priority? priority,
    bool? isFavorite,
    bool? isPinned,
    bool? isArchived,
    bool? isDone,
    Object? dueDate = _sentinel,
    Object? dueTime = _sentinel,
    Object? reminderAt = _sentinel,
    List<String>? tags,
    int? progress,
    int? estimatedMinutes,
    int? actualMinutes,
    List<SubTask>? subtasks,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? order,
  }) =>
      Task(
        id: id ?? this.id,
        boardId: boardId ?? this.boardId,
        columnId: columnId ?? this.columnId,
        title: title ?? this.title,
        description: description ?? this.description,
        note: note ?? this.note,
        priority: priority ?? this.priority,
        isFavorite: isFavorite ?? this.isFavorite,
        isPinned: isPinned ?? this.isPinned,
        isArchived: isArchived ?? this.isArchived,
        isDone: isDone ?? this.isDone,
        dueDate: dueDate == _sentinel ? this.dueDate : dueDate as DateTime?,
        dueTime: dueTime == _sentinel ? this.dueTime : dueTime as TimeOfDay?,
        reminderAt: reminderAt == _sentinel ? this.reminderAt : reminderAt as DateTime?,
        tags: tags ?? List.from(this.tags),
        progress: progress ?? this.progress,
        estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
        actualMinutes: actualMinutes ?? this.actualMinutes,
        subtasks: subtasks ?? List.from(this.subtasks),
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        order: order ?? this.order,
      );

  bool get isOverdue {
    if (isDone || dueDate == null) return false;
    final now = DateTime.now();
    final due = dueDate!;
    if (dueTime != null) {
      final fullDue = DateTime(due.year, due.month, due.day, dueTime!.hour, dueTime!.minute);
      return fullDue.isBefore(now);
    }
    return DateTime(due.year, due.month, due.day)
        .isBefore(DateTime(now.year, now.month, now.day));
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'boardId': boardId,
        'columnId': columnId,
        'title': title,
        'description': description,
        'note': note,
        'priority': priority.index,
        'isFavorite': isFavorite,
        'isPinned': isPinned,
        'isArchived': isArchived,
        'isDone': isDone,
        'dueDate': dueDate?.toIso8601String(),
        'dueTimeH': dueTime?.hour,
        'dueTimeM': dueTime?.minute,
        'reminderAt': reminderAt?.toIso8601String(),
        'tags': tags,
        'progress': progress,
        'estimatedMinutes': estimatedMinutes,
        'actualMinutes': actualMinutes,
        'subtasks': subtasks.map((s) => s.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'order': order,
      };

  factory Task.fromJson(Map<String, dynamic> j) {
    TimeOfDay? dueTime;
    if (j['dueTimeH'] != null && j['dueTimeM'] != null) {
      dueTime = TimeOfDay(hour: j['dueTimeH'], minute: j['dueTimeM']);
    }
    return Task(
      id: j['id'] ?? newId(),
      boardId: j['boardId'] ?? '',
      columnId: j['columnId'] ?? '',
      title: j['title'] ?? '',
      description: j['description'] ?? '',
      note: j['note'] ?? '',
      priority: Priority.values[j['priority'] ?? 1],
      isFavorite: j['isFavorite'] ?? false,
      isPinned: j['isPinned'] ?? false,
      isArchived: j['isArchived'] ?? false,
      isDone: j['isDone'] ?? false,
      dueDate: j['dueDate'] != null ? DateTime.parse(j['dueDate']) : null,
      dueTime: dueTime,
      reminderAt: j['reminderAt'] != null ? DateTime.parse(j['reminderAt']) : null,
      tags: List<String>.from(j['tags'] ?? []),
      progress: j['progress'] ?? 0,
      estimatedMinutes: j['estimatedMinutes'] ?? 0,
      actualMinutes: j['actualMinutes'] ?? 0,
      subtasks: (j['subtasks'] as List<dynamic>? ?? [])
          .map((s) => SubTask.fromJson(s))
          .toList(),
      createdAt: j['createdAt'] != null ? DateTime.parse(j['createdAt']) : DateTime.now(),
      updatedAt: j['updatedAt'] != null ? DateTime.parse(j['updatedAt']) : DateTime.now(),
      order: j['order'] ?? 0,
    );
  }
}

// ─── KanbanColumn ─────────────────────────────────────────────────────────────
class KanbanColumn {
  String id;
  String boardId;
  String name;
  int order;
  int colorValue;

  KanbanColumn({
    required this.id,
    required this.boardId,
    required this.name,
    required this.order,
    this.colorValue = 0xFF6C63FF,
  });

  KanbanColumn copyWith(
          {String? id, String? boardId, String? name, int? order, int? colorValue}) =>
      KanbanColumn(
        id: id ?? this.id,
        boardId: boardId ?? this.boardId,
        name: name ?? this.name,
        order: order ?? this.order,
        colorValue: colorValue ?? this.colorValue,
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'boardId': boardId, 'name': name, 'order': order, 'colorValue': colorValue};

  factory KanbanColumn.fromJson(Map<String, dynamic> j) => KanbanColumn(
        id: j['id'] ?? newId(),
        boardId: j['boardId'] ?? '',
        name: j['name'] ?? '',
        order: j['order'] ?? 0,
        colorValue: j['colorValue'] ?? 0xFF6C63FF,
      );
}

// ─── Board ────────────────────────────────────────────────────────────────────
class Board {
  String id;
  String name;
  int colorValue;
  DateTime createdAt;
  DateTime updatedAt;

  Board({
    required this.id,
    required this.name,
    this.colorValue = 0xFF6C63FF,
    required this.createdAt,
    required this.updatedAt,
  });

  Board copyWith(
          {String? id,
          String? name,
          int? colorValue,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Board(
        id: id ?? this.id,
        name: name ?? this.name,
        colorValue: colorValue ?? this.colorValue,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Board.fromJson(Map<String, dynamic> j) => Board(
        id: j['id'] ?? newId(),
        name: j['name'] ?? '',
        colorValue: j['colorValue'] ?? 0xFF6C63FF,
        createdAt: j['createdAt'] != null ? DateTime.parse(j['createdAt']) : DateTime.now(),
        updatedAt: j['updatedAt'] != null ? DateTime.parse(j['updatedAt']) : DateTime.now(),
      );
}

// ─── Filter / Sort ────────────────────────────────────────────────────────────
enum SortBy { manual, deadline, createdAt, priority }

enum FilterStatus { all, active, done, archived }

class FilterOptions {
  FilterStatus status;
  Priority? priority;
  bool onlyOverdue;
  bool onlyToday;
  bool onlyFavorite;
  String? boardId;
  SortBy sortBy;
  bool sortDesc;

  FilterOptions({
    this.status = FilterStatus.all,
    this.priority,
    this.onlyOverdue = false,
    this.onlyToday = false,
    this.onlyFavorite = false,
    this.boardId,
    this.sortBy = SortBy.manual,
    this.sortDesc = false,
  });

  FilterOptions copyWith({
    FilterStatus? status,
    Object? priority = _sentinel,
    bool? onlyOverdue,
    bool? onlyToday,
    bool? onlyFavorite,
    Object? boardId = _sentinel,
    SortBy? sortBy,
    bool? sortDesc,
  }) =>
      FilterOptions(
        status: status ?? this.status,
        priority: priority == _sentinel ? this.priority : priority as Priority?,
        onlyOverdue: onlyOverdue ?? this.onlyOverdue,
        onlyToday: onlyToday ?? this.onlyToday,
        onlyFavorite: onlyFavorite ?? this.onlyFavorite,
        boardId: boardId == _sentinel ? this.boardId : boardId as String?,
        sortBy: sortBy ?? this.sortBy,
        sortDesc: sortDesc ?? this.sortDesc,
      );
}

// ─── AppState ─────────────────────────────────────────────────────────────────
class AppState extends ChangeNotifier {
  List<Board> boards = [];
  List<KanbanColumn> columns = [];
  List<Task> tasks = [];
  String? currentBoardId;
  bool isDarkMode = false;
  FilterOptions filterOptions = FilterOptions();
  String searchQuery = '';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _load();
    if (boards.isEmpty) _seedSampleData();
  }

  // ── persistence ───────────────────────────────────────────────────────────
  void _load() {
    try {
      final bStr = _prefs.getString('boards');
      final cStr = _prefs.getString('columns');
      final tStr = _prefs.getString('tasks');
      isDarkMode = _prefs.getBool('darkMode') ?? false;
      currentBoardId = _prefs.getString('currentBoardId');
      if (bStr != null) {
        boards = (jsonDecode(bStr) as List).map((e) => Board.fromJson(e)).toList();
      }
      if (cStr != null) {
        columns = (jsonDecode(cStr) as List).map((e) => KanbanColumn.fromJson(e)).toList();
      }
      if (tStr != null) {
        tasks = (jsonDecode(tStr) as List).map((e) => Task.fromJson(e)).toList();
      }
    } catch (_) {
      boards = [];
      columns = [];
      tasks = [];
    }
  }

  Future<void> _save() async {
    await _prefs.setString('boards', jsonEncode(boards.map((b) => b.toJson()).toList()));
    await _prefs.setString('columns', jsonEncode(columns.map((c) => c.toJson()).toList()));
    await _prefs.setString('tasks', jsonEncode(tasks.map((t) => t.toJson()).toList()));
    await _prefs.setBool('darkMode', isDarkMode);
    if (currentBoardId != null) {
      await _prefs.setString('currentBoardId', currentBoardId!);
    }
  }

  // ── seed ──────────────────────────────────────────────────────────────────
  void _seedSampleData() {
    final now = DateTime.now();
    final b1 = newId(), b2 = newId();
    boards = [
      Board(id: b1, name: 'Personal', colorValue: 0xFF6C63FF, createdAt: now, updatedAt: now),
      Board(id: b2, name: 'Work', colorValue: 0xFF00BFA5, createdAt: now, updatedAt: now),
    ];
    currentBoardId = b1;

    final c1 = newId(), c2 = newId(), c3 = newId();
    final c4 = newId(), c5 = newId(), c6 = newId();
    columns = [
      KanbanColumn(id: c1, boardId: b1, name: 'Todo', order: 0, colorValue: 0xFF6C63FF),
      KanbanColumn(id: c2, boardId: b1, name: 'Doing', order: 1, colorValue: 0xFFFF9800),
      KanbanColumn(id: c3, boardId: b1, name: 'Done', order: 2, colorValue: 0xFF4CAF50),
      KanbanColumn(id: c4, boardId: b2, name: 'Todo', order: 0, colorValue: 0xFF00BFA5),
      KanbanColumn(id: c5, boardId: b2, name: 'In Progress', order: 1, colorValue: 0xFF2196F3),
      KanbanColumn(id: c6, boardId: b2, name: 'Done', order: 2, colorValue: 0xFF4CAF50),
    ];

    tasks = [
      Task(
        id: newId(), boardId: b1, columnId: c1,
        title: 'Buy groceries', description: 'Milk, eggs, bread, vegetables',
        priority: Priority.medium,
        dueDate: now.add(const Duration(days: 1)),
        tags: ['shopping', 'errands'],
        createdAt: now, updatedAt: now, order: 0,
      ),
      Task(
        id: newId(), boardId: b1, columnId: c1,
        title: 'Read a book', description: 'Finish "Atomic Habits"',
        priority: Priority.low, isFavorite: true,
        dueDate: now.add(const Duration(days: 7)),
        tags: ['reading', 'self-growth'],
        progress: 40,
        createdAt: now, updatedAt: now, order: 1,
      ),
      Task(
        id: newId(), boardId: b1, columnId: c2,
        title: 'Morning workout', description: '30 min cardio + stretching',
        priority: Priority.high, isPinned: true,
        dueDate: now,
        tags: ['health', 'fitness'],
        estimatedMinutes: 30,
        subtasks: [
          SubTask(id: newId(), title: 'Warm up', isDone: true),
          SubTask(id: newId(), title: 'Cardio 20 min', isDone: true),
          SubTask(id: newId(), title: 'Cool down', isDone: false),
        ],
        progress: 66,
        createdAt: now, updatedAt: now, order: 0,
      ),
      Task(
        id: newId(), boardId: b1, columnId: c3,
        title: 'Setup Flutter project', description: 'Initialize repo and configure CI',
        priority: Priority.high, isDone: true,
        dueDate: now.subtract(const Duration(days: 2)),
        tags: ['dev', 'flutter'],
        progress: 100, actualMinutes: 120,
        createdAt: now.subtract(const Duration(days: 3)), updatedAt: now, order: 0,
      ),
      Task(
        id: newId(), boardId: b2, columnId: c4,
        title: 'Review PRs', description: 'Check open pull requests on GitHub',
        priority: Priority.high, dueDate: now,
        tags: ['code-review'],
        createdAt: now, updatedAt: now, order: 0,
      ),
      Task(
        id: newId(), boardId: b2, columnId: c5,
        title: 'Write unit tests', description: 'Cover core business logic',
        priority: Priority.medium,
        dueDate: now.add(const Duration(days: 3)),
        estimatedMinutes: 90, tags: ['testing', 'dev'],
        createdAt: now, updatedAt: now, order: 0,
      ),
    ];
    _save();
  }

  // ── theme ─────────────────────────────────────────────────────────────────
  void toggleDarkMode() {
    isDarkMode = !isDarkMode;
    _save();
    notifyListeners();
  }

  // ── board CRUD ────────────────────────────────────────────────────────────
  Board createBoard(String name, int colorValue) {
    final now = DateTime.now();
    final board =
        Board(id: newId(), name: name, colorValue: colorValue, createdAt: now, updatedAt: now);
    boards.add(board);
    final c1 = newId(), c2 = newId(), c3 = newId();
    columns.addAll([
      KanbanColumn(id: c1, boardId: board.id, name: 'Todo', order: 0, colorValue: colorValue),
      KanbanColumn(id: c2, boardId: board.id, name: 'Doing', order: 1, colorValue: 0xFFFF9800),
      KanbanColumn(id: c3, boardId: board.id, name: 'Done', order: 2, colorValue: 0xFF4CAF50),
    ]);
    currentBoardId = board.id;
    _save();
    notifyListeners();
    return board;
  }

  void updateBoard(String id, {String? name, int? colorValue}) {
    final idx = boards.indexWhere((b) => b.id == id);
    if (idx == -1) return;
    boards[idx] = boards[idx].copyWith(name: name, colorValue: colorValue, updatedAt: DateTime.now());
    _save();
    notifyListeners();
  }

  void deleteBoard(String id) {
    boards.removeWhere((b) => b.id == id);
    columns.removeWhere((c) => c.boardId == id);
    tasks.removeWhere((t) => t.boardId == id);
    if (currentBoardId == id) {
      currentBoardId = boards.isNotEmpty ? boards.first.id : null;
    }
    _save();
    notifyListeners();
  }

  void selectBoard(String id) {
    currentBoardId = id;
    _save();
    notifyListeners();
  }

  Board? get currentBoard => boards.firstWhereOrNull((b) => b.id == currentBoardId);

  List<Board> get recentBoards {
    final sorted = List<Board>.from(boards);
    sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.take(4).toList();
  }

  // ── column CRUD ───────────────────────────────────────────────────────────
  KanbanColumn createColumn(String boardId, String name, int colorValue) {
    final existing = columnsForBoard(boardId);
    final maxOrder = existing.isEmpty
        ? 0
        : existing.map((c) => c.order).reduce((a, b) => a > b ? a : b) + 1;
    final col = KanbanColumn(
        id: newId(), boardId: boardId, name: name, order: maxOrder, colorValue: colorValue);
    columns.add(col);
    _save();
    notifyListeners();
    return col;
  }

  void updateColumn(String id, {String? name, int? colorValue}) {
    final idx = columns.indexWhere((c) => c.id == id);
    if (idx == -1) return;
    columns[idx] = columns[idx].copyWith(name: name, colorValue: colorValue);
    _save();
    notifyListeners();
  }

  void deleteColumn(String id) {
    tasks.removeWhere((t) => t.columnId == id);
    columns.removeWhere((c) => c.id == id);
    _save();
    notifyListeners();
  }

  void reorderColumns(String boardId, int oldIndex, int newIndex) {
    final cols = columnsForBoard(boardId);
    final item = cols.removeAt(oldIndex);
    cols.insert(newIndex, item);
    for (int i = 0; i < cols.length; i++) {
      final gi = columns.indexWhere((c) => c.id == cols[i].id);
      if (gi != -1) columns[gi] = columns[gi].copyWith(order: i);
    }
    _save();
    notifyListeners();
  }

  List<KanbanColumn> columnsForBoard(String boardId) {
    final result = columns.where((c) => c.boardId == boardId).toList();
    result.sort((a, b) => a.order.compareTo(b.order));
    return result;
  }

  // ── task CRUD ─────────────────────────────────────────────────────────────
  Task createTask({
    required String boardId,
    required String columnId,
    required String title,
    String description = '',
    String note = '',
    Priority priority = Priority.medium,
    bool isFavorite = false,
    bool isPinned = false,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    DateTime? reminderAt,
    List<String> tags = const [],
    int progress = 0,
    int estimatedMinutes = 0,
    int actualMinutes = 0,
    List<SubTask> subtasks = const [],
  }) {
    final now = DateTime.now();
    final existing = tasksForColumn(columnId);
    final maxOrder = existing.isEmpty
        ? 0
        : existing.map((t) => t.order).reduce((a, b) => a > b ? a : b) + 1;
    final task = Task(
      id: newId(),
      boardId: boardId,
      columnId: columnId,
      title: title,
      description: description,
      note: note,
      priority: priority,
      isFavorite: isFavorite,
      isPinned: isPinned,
      dueDate: dueDate,
      dueTime: dueTime,
      reminderAt: reminderAt,
      tags: List.from(tags),
      progress: progress,
      estimatedMinutes: estimatedMinutes,
      actualMinutes: actualMinutes,
      subtasks: List.from(subtasks),
      createdAt: now,
      updatedAt: now,
      order: maxOrder,
    );
    tasks.add(task);
    _updateBoardTimestamp(boardId);
    _save();
    notifyListeners();
    return task;
  }

  void updateTask(String id, Task updated) {
    final idx = tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    tasks[idx] = updated.copyWith(updatedAt: DateTime.now());
    _updateBoardTimestamp(updated.boardId);
    _save();
    notifyListeners();
  }

  void deleteTask(String id) {
    tasks.removeWhere((t) => t.id == id);
    _save();
    notifyListeners();
  }

  void duplicateTask(String id) {
    final original = tasks.firstWhereOrNull((t) => t.id == id);
    if (original == null) return;
    final now = DateTime.now();
    final existing = tasksForColumn(original.columnId);
    final maxOrder = existing.isEmpty
        ? 0
        : existing.map((t) => t.order).reduce((a, b) => a > b ? a : b) + 1;
    final dup = original.copyWith(
      id: newId(),
      title: '${original.title} (copy)',
      createdAt: now,
      updatedAt: now,
      order: maxOrder,
      isDone: false,
    );
    tasks.add(dup);
    _save();
    notifyListeners();
  }

  void archiveTask(String id) {
    final idx = tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    tasks[idx] = tasks[idx].copyWith(isArchived: true, updatedAt: DateTime.now());
    _save();
    notifyListeners();
  }

  void restoreTask(String id) {
    final idx = tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    tasks[idx] = tasks[idx].copyWith(isArchived: false, updatedAt: DateTime.now());
    _save();
    notifyListeners();
  }

  void toggleDone(String id) {
    final idx = tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final t = tasks[idx];
    tasks[idx] = t.copyWith(
      isDone: !t.isDone,
      progress: !t.isDone ? 100 : t.progress,
      updatedAt: DateTime.now(),
    );
    _save();
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final idx = tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    tasks[idx] = tasks[idx].copyWith(isFavorite: !tasks[idx].isFavorite, updatedAt: DateTime.now());
    _save();
    notifyListeners();
  }

  void togglePin(String id) {
    final idx = tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    tasks[idx] = tasks[idx].copyWith(isPinned: !tasks[idx].isPinned, updatedAt: DateTime.now());
    _save();
    notifyListeners();
  }

  // Drag task between columns
  void moveTask(String taskId, String targetColumnId, int targetIndex) {
    final taskIdx = tasks.indexWhere((t) => t.id == taskId);
    if (taskIdx == -1) return;
    final task = tasks[taskIdx];

    // Re-order source column
    final oldColTasks = tasksForColumn(task.columnId)..removeWhere((t) => t.id == taskId);
    for (int i = 0; i < oldColTasks.length; i++) {
      final gi = tasks.indexWhere((t) => t.id == oldColTasks[i].id);
      if (gi != -1) tasks[gi] = tasks[gi].copyWith(order: i);
    }

    // Insert into target column
    final newColTasks = tasksForColumn(targetColumnId);
    final clamped = targetIndex.clamp(0, newColTasks.length);
    newColTasks.insert(clamped, task);
    for (int i = 0; i < newColTasks.length; i++) {
      final gi = tasks.indexWhere((t) => t.id == newColTasks[i].id);
      if (gi != -1) {
        tasks[gi] = tasks[gi].copyWith(order: i, columnId: targetColumnId, updatedAt: DateTime.now());
      }
    }
    final mi = tasks.indexWhere((t) => t.id == taskId);
    if (mi != -1) {
      tasks[mi] = tasks[mi].copyWith(columnId: targetColumnId, order: clamped, updatedAt: DateTime.now());
    }

    _save();
    notifyListeners();
  }

  // Reorder within same column
  void reorderTaskInColumn(String columnId, int oldIndex, int newIndex) {
    final colTasks = tasksForColumn(columnId);
    if (oldIndex < 0 || oldIndex >= colTasks.length) return;
    final item = colTasks.removeAt(oldIndex);
    final adj = (newIndex > oldIndex ? newIndex - 1 : newIndex).clamp(0, colTasks.length);
    colTasks.insert(adj, item);
    for (int i = 0; i < colTasks.length; i++) {
      final gi = tasks.indexWhere((t) => t.id == colTasks[i].id);
      if (gi != -1) tasks[gi] = tasks[gi].copyWith(order: i);
    }
    _save();
    notifyListeners();
  }

  List<Task> tasksForColumn(String columnId) {
    final result = tasks.where((t) => t.columnId == columnId && !t.isArchived).toList();
    result.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return a.order.compareTo(b.order);
    });
    return result;
  }

  void _updateBoardTimestamp(String boardId) {
    final idx = boards.indexWhere((b) => b.id == boardId);
    if (idx != -1) boards[idx] = boards[idx].copyWith(updatedAt: DateTime.now());
  }

  // ── search & filter ───────────────────────────────────────────────────────
  List<Task> get filteredTasks {
    var result = tasks.where((t) => !t.isArchived).toList();

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result
          .where((t) =>
              t.title.toLowerCase().contains(q) ||
              t.description.toLowerCase().contains(q))
          .toList();
    }

    if (filterOptions.boardId != null) {
      result = result.where((t) => t.boardId == filterOptions.boardId).toList();
    }

    switch (filterOptions.status) {
      case FilterStatus.active:
        result = result.where((t) => !t.isDone).toList();
        break;
      case FilterStatus.done:
        result = result.where((t) => t.isDone).toList();
        break;
      case FilterStatus.archived:
        return tasks.where((t) => t.isArchived).toList();
      default:
        break;
    }

    if (filterOptions.priority != null) {
      result = result.where((t) => t.priority == filterOptions.priority).toList();
    }
    if (filterOptions.onlyOverdue) result = result.where((t) => t.isOverdue).toList();
    if (filterOptions.onlyToday) result = result.where((t) => t.isDueToday).toList();
    if (filterOptions.onlyFavorite) result = result.where((t) => t.isFavorite).toList();

    switch (filterOptions.sortBy) {
      case SortBy.deadline:
        result.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case SortBy.createdAt:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortBy.priority:
        result.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      default:
        result.sort((a, b) => a.order.compareTo(b.order));
    }

    if (filterOptions.sortDesc) result = result.reversed.toList();
    return result;
  }

  // ── dashboard stats ───────────────────────────────────────────────────────
  int get totalTasks => tasks.where((t) => !t.isArchived).length;
  int get todayTasks => tasks.where((t) => !t.isArchived && t.isDueToday).length;
  int get overdueTasks => tasks.where((t) => !t.isArchived && t.isOverdue).length;
  int get doneTasks => tasks.where((t) => !t.isArchived && t.isDone).length;
  int get highPriorityTasks =>
      tasks.where((t) => !t.isArchived && t.priority == Priority.high && !t.isDone).length;

  // ── formatting ────────────────────────────────────────────────────────────
  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d, yyyy').format(date);
  }

  String formatDateTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d, yyyy HH:mm').format(date);
  }

  String formatTime(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
