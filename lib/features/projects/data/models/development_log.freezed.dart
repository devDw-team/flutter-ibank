// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'development_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DevelopmentLog _$DevelopmentLogFromJson(Map<String, dynamic> json) {
  return _DevelopmentLog.fromJson(json);
}

/// @nodoc
mixin _$DevelopmentLog {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'project_id')
  String get projectId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'log_type')
  DevelopmentLogType get logType => throw _privateConstructorUsedError;
  DevelopmentLogStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  DateTime? get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'hours_spent')
  double get hoursSpent => throw _privateConstructorUsedError;
  @JsonKey(name: 'related_task_id')
  String? get relatedTaskId => throw _privateConstructorUsedError;
  List<String> get attachments => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt =>
      throw _privateConstructorUsedError; // Additional fields for UI
  @JsonKey(includeFromJson: true, includeToJson: false)
  String? get userName => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: true, includeToJson: false)
  String? get userAvatar => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: true, includeToJson: false)
  String? get taskTitle => throw _privateConstructorUsedError;

  /// Serializes this DevelopmentLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DevelopmentLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DevelopmentLogCopyWith<DevelopmentLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DevelopmentLogCopyWith<$Res> {
  factory $DevelopmentLogCopyWith(
          DevelopmentLog value, $Res Function(DevelopmentLog) then) =
      _$DevelopmentLogCopyWithImpl<$Res, DevelopmentLog>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'project_id') String projectId,
      @JsonKey(name: 'user_id') String userId,
      String title,
      String? description,
      @JsonKey(name: 'log_type') DevelopmentLogType logType,
      DevelopmentLogStatus status,
      @JsonKey(name: 'start_date') DateTime startDate,
      @JsonKey(name: 'end_date') DateTime? endDate,
      @JsonKey(name: 'hours_spent') double hoursSpent,
      @JsonKey(name: 'related_task_id') String? relatedTaskId,
      List<String> attachments,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(includeFromJson: true, includeToJson: false) String? userName,
      @JsonKey(includeFromJson: true, includeToJson: false) String? userAvatar,
      @JsonKey(includeFromJson: true, includeToJson: false) String? taskTitle});
}

/// @nodoc
class _$DevelopmentLogCopyWithImpl<$Res, $Val extends DevelopmentLog>
    implements $DevelopmentLogCopyWith<$Res> {
  _$DevelopmentLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DevelopmentLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? projectId = null,
    Object? userId = null,
    Object? title = null,
    Object? description = freezed,
    Object? logType = null,
    Object? status = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? hoursSpent = null,
    Object? relatedTaskId = freezed,
    Object? attachments = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? userName = freezed,
    Object? userAvatar = freezed,
    Object? taskTitle = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      projectId: null == projectId
          ? _value.projectId
          : projectId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      logType: null == logType
          ? _value.logType
          : logType // ignore: cast_nullable_to_non_nullable
              as DevelopmentLogType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DevelopmentLogStatus,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hoursSpent: null == hoursSpent
          ? _value.hoursSpent
          : hoursSpent // ignore: cast_nullable_to_non_nullable
              as double,
      relatedTaskId: freezed == relatedTaskId
          ? _value.relatedTaskId
          : relatedTaskId // ignore: cast_nullable_to_non_nullable
              as String?,
      attachments: null == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      userAvatar: freezed == userAvatar
          ? _value.userAvatar
          : userAvatar // ignore: cast_nullable_to_non_nullable
              as String?,
      taskTitle: freezed == taskTitle
          ? _value.taskTitle
          : taskTitle // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DevelopmentLogImplCopyWith<$Res>
    implements $DevelopmentLogCopyWith<$Res> {
  factory _$$DevelopmentLogImplCopyWith(_$DevelopmentLogImpl value,
          $Res Function(_$DevelopmentLogImpl) then) =
      __$$DevelopmentLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'project_id') String projectId,
      @JsonKey(name: 'user_id') String userId,
      String title,
      String? description,
      @JsonKey(name: 'log_type') DevelopmentLogType logType,
      DevelopmentLogStatus status,
      @JsonKey(name: 'start_date') DateTime startDate,
      @JsonKey(name: 'end_date') DateTime? endDate,
      @JsonKey(name: 'hours_spent') double hoursSpent,
      @JsonKey(name: 'related_task_id') String? relatedTaskId,
      List<String> attachments,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(includeFromJson: true, includeToJson: false) String? userName,
      @JsonKey(includeFromJson: true, includeToJson: false) String? userAvatar,
      @JsonKey(includeFromJson: true, includeToJson: false) String? taskTitle});
}

/// @nodoc
class __$$DevelopmentLogImplCopyWithImpl<$Res>
    extends _$DevelopmentLogCopyWithImpl<$Res, _$DevelopmentLogImpl>
    implements _$$DevelopmentLogImplCopyWith<$Res> {
  __$$DevelopmentLogImplCopyWithImpl(
      _$DevelopmentLogImpl _value, $Res Function(_$DevelopmentLogImpl) _then)
      : super(_value, _then);

  /// Create a copy of DevelopmentLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? projectId = null,
    Object? userId = null,
    Object? title = null,
    Object? description = freezed,
    Object? logType = null,
    Object? status = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? hoursSpent = null,
    Object? relatedTaskId = freezed,
    Object? attachments = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? userName = freezed,
    Object? userAvatar = freezed,
    Object? taskTitle = freezed,
  }) {
    return _then(_$DevelopmentLogImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      projectId: null == projectId
          ? _value.projectId
          : projectId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      logType: null == logType
          ? _value.logType
          : logType // ignore: cast_nullable_to_non_nullable
              as DevelopmentLogType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DevelopmentLogStatus,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hoursSpent: null == hoursSpent
          ? _value.hoursSpent
          : hoursSpent // ignore: cast_nullable_to_non_nullable
              as double,
      relatedTaskId: freezed == relatedTaskId
          ? _value.relatedTaskId
          : relatedTaskId // ignore: cast_nullable_to_non_nullable
              as String?,
      attachments: null == attachments
          ? _value._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      userAvatar: freezed == userAvatar
          ? _value.userAvatar
          : userAvatar // ignore: cast_nullable_to_non_nullable
              as String?,
      taskTitle: freezed == taskTitle
          ? _value.taskTitle
          : taskTitle // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DevelopmentLogImpl implements _DevelopmentLog {
  const _$DevelopmentLogImpl(
      {required this.id,
      @JsonKey(name: 'project_id') required this.projectId,
      @JsonKey(name: 'user_id') required this.userId,
      required this.title,
      this.description,
      @JsonKey(name: 'log_type') required this.logType,
      required this.status,
      @JsonKey(name: 'start_date') required this.startDate,
      @JsonKey(name: 'end_date') this.endDate,
      @JsonKey(name: 'hours_spent') this.hoursSpent = 0.0,
      @JsonKey(name: 'related_task_id') this.relatedTaskId,
      final List<String> attachments = const [],
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      @JsonKey(includeFromJson: true, includeToJson: false) this.userName,
      @JsonKey(includeFromJson: true, includeToJson: false) this.userAvatar,
      @JsonKey(includeFromJson: true, includeToJson: false) this.taskTitle})
      : _attachments = attachments;

  factory _$DevelopmentLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$DevelopmentLogImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'project_id')
  final String projectId;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String title;
  @override
  final String? description;
  @override
  @JsonKey(name: 'log_type')
  final DevelopmentLogType logType;
  @override
  final DevelopmentLogStatus status;
  @override
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @override
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  @override
  @JsonKey(name: 'hours_spent')
  final double hoursSpent;
  @override
  @JsonKey(name: 'related_task_id')
  final String? relatedTaskId;
  final List<String> _attachments;
  @override
  @JsonKey()
  List<String> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
// Additional fields for UI
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  final String? userName;
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  final String? userAvatar;
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  final String? taskTitle;

  @override
  String toString() {
    return 'DevelopmentLog(id: $id, projectId: $projectId, userId: $userId, title: $title, description: $description, logType: $logType, status: $status, startDate: $startDate, endDate: $endDate, hoursSpent: $hoursSpent, relatedTaskId: $relatedTaskId, attachments: $attachments, createdAt: $createdAt, updatedAt: $updatedAt, userName: $userName, userAvatar: $userAvatar, taskTitle: $taskTitle)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DevelopmentLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.logType, logType) || other.logType == logType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.hoursSpent, hoursSpent) ||
                other.hoursSpent == hoursSpent) &&
            (identical(other.relatedTaskId, relatedTaskId) ||
                other.relatedTaskId == relatedTaskId) &&
            const DeepCollectionEquality()
                .equals(other._attachments, _attachments) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userAvatar, userAvatar) ||
                other.userAvatar == userAvatar) &&
            (identical(other.taskTitle, taskTitle) ||
                other.taskTitle == taskTitle));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      projectId,
      userId,
      title,
      description,
      logType,
      status,
      startDate,
      endDate,
      hoursSpent,
      relatedTaskId,
      const DeepCollectionEquality().hash(_attachments),
      createdAt,
      updatedAt,
      userName,
      userAvatar,
      taskTitle);

  /// Create a copy of DevelopmentLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DevelopmentLogImplCopyWith<_$DevelopmentLogImpl> get copyWith =>
      __$$DevelopmentLogImplCopyWithImpl<_$DevelopmentLogImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DevelopmentLogImplToJson(
      this,
    );
  }
}

abstract class _DevelopmentLog implements DevelopmentLog {
  const factory _DevelopmentLog(
      {required final String id,
      @JsonKey(name: 'project_id') required final String projectId,
      @JsonKey(name: 'user_id') required final String userId,
      required final String title,
      final String? description,
      @JsonKey(name: 'log_type') required final DevelopmentLogType logType,
      required final DevelopmentLogStatus status,
      @JsonKey(name: 'start_date') required final DateTime startDate,
      @JsonKey(name: 'end_date') final DateTime? endDate,
      @JsonKey(name: 'hours_spent') final double hoursSpent,
      @JsonKey(name: 'related_task_id') final String? relatedTaskId,
      final List<String> attachments,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at') required final DateTime updatedAt,
      @JsonKey(includeFromJson: true, includeToJson: false)
      final String? userName,
      @JsonKey(includeFromJson: true, includeToJson: false)
      final String? userAvatar,
      @JsonKey(includeFromJson: true, includeToJson: false)
      final String? taskTitle}) = _$DevelopmentLogImpl;

  factory _DevelopmentLog.fromJson(Map<String, dynamic> json) =
      _$DevelopmentLogImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'project_id')
  String get projectId;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get title;
  @override
  String? get description;
  @override
  @JsonKey(name: 'log_type')
  DevelopmentLogType get logType;
  @override
  DevelopmentLogStatus get status;
  @override
  @JsonKey(name: 'start_date')
  DateTime get startDate;
  @override
  @JsonKey(name: 'end_date')
  DateTime? get endDate;
  @override
  @JsonKey(name: 'hours_spent')
  double get hoursSpent;
  @override
  @JsonKey(name: 'related_task_id')
  String? get relatedTaskId;
  @override
  List<String> get attachments;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt; // Additional fields for UI
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  String? get userName;
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  String? get userAvatar;
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  String? get taskTitle;

  /// Create a copy of DevelopmentLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DevelopmentLogImplCopyWith<_$DevelopmentLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
