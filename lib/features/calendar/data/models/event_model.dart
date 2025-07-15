import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_model.freezed.dart';
part 'event_model.g.dart';

enum EventType {
  @JsonValue('personal')
  personal,
  @JsonValue('team')
  team,
  @JsonValue('company')
  company,
  @JsonValue('meeting')
  meeting,
}

@freezed
class EventModel with _$EventModel {
  const factory EventModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String title,
    String? description,
    @JsonKey(name: 'start_time') required DateTime startTime,
    @JsonKey(name: 'end_time') required DateTime endTime,
    String? location,
    @JsonKey(name: 'event_type') @Default(EventType.personal) EventType eventType,
    @JsonKey(name: 'is_all_day') @Default(false) bool isAllDay,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _EventModel;

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);
}

extension EventModelX on EventModel {
  String get eventTypeText {
    switch (eventType) {
      case EventType.personal:
        return '개인';
      case EventType.team:
        return '팀';
      case EventType.company:
        return '회사';
      case EventType.meeting:
        return '회의';
    }
  }

  Duration get duration => endTime.difference(startTime);
}