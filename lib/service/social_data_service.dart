import 'dart:convert';

import 'package:flutter/services.dart';

import '../util/const/app/app_strings.dart';
import '../util/const/app/social_data_constants.dart';

typedef JsonObject = Map<String, dynamic>;

abstract interface class SocialDataService {
  Future<void> load();

  SocialMockData get data;
}

class AssetSocialDataService implements SocialDataService {
  AssetSocialDataService({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  SocialMockData? _data;
  Future<void>? _pendingLoad;

  @override
  SocialMockData get data =>
      _data ?? (throw StateError(AppStrings.socialMockDataNotLoaded));

  @override
  Future<void> load() {
    if (_data != null) return Future<void>.value();
    return _pendingLoad ??= _load();
  }

  Future<void> _load() async {
    try {
      final decoded = jsonDecode(
        await _bundle.loadString(SocialDataConstants.assetPath),
      );
      if (decoded is! JsonObject) {
        throw const FormatException(AppStrings.invalidSocialMockData);
      }
      _data = SocialMockData.fromJson(decoded);
    } finally {
      _pendingLoad = null;
    }
  }
}

class SocialMockData {
  SocialMockData._({
    required this.schemaVersion,
    required this.currentUserPartyId,
    required Map<String, List<JsonObject>> sections,
  }) : _sections = Map.unmodifiable(sections);

  factory SocialMockData.fromJson(JsonObject json) {
    final schemaVersion = json[SocialDataConstants.schemaVersionKey];
    if (schemaVersion is! int) {
      throw const FormatException(AppStrings.invalidSocialMockData);
    }

    final currentUserPartyId = json[SocialDataConstants.currentUserPartyIdKey];
    if (currentUserPartyId is! String) {
      throw const FormatException(AppStrings.invalidSocialMockData);
    }

    return SocialMockData._(
      schemaVersion: schemaVersion,
      currentUserPartyId: currentUserPartyId,
      sections: {
        for (final section in SocialDataConstants.sections)
          section: _readObjects(json, section),
      },
    );
  }

  final int schemaVersion;
  final String currentUserPartyId;
  final Map<String, List<JsonObject>> _sections;

  List<JsonObject> get parties => _sections[SocialDataConstants.partiesKey]!;
  List<JsonObject> get userProfiles =>
      _sections[SocialDataConstants.userProfilesKey]!;
  List<JsonObject> get partyRoles =>
      _sections[SocialDataConstants.partyRolesKey]!;
  List<JsonObject> get friendships =>
      _sections[SocialDataConstants.friendshipsKey]!;
  List<JsonObject> get communities =>
      _sections[SocialDataConstants.communitiesKey]!;
  List<JsonObject> get hashtags => _sections[SocialDataConstants.hashtagsKey]!;
  List<JsonObject> get conversations =>
      _sections[SocialDataConstants.conversationsKey]!;
  List<JsonObject> get conversationMessages =>
      _sections[SocialDataConstants.conversationMessagesKey]!;
  List<JsonObject> get postThemes =>
      _sections[SocialDataConstants.postThemesKey]!;
  List<JsonObject> get stickerAssets =>
      _sections[SocialDataConstants.stickerAssetsKey]!;
  List<JsonObject> get posts => _sections[SocialDataConstants.postsKey]!;
  List<JsonObject> get comments => _sections[SocialDataConstants.commentsKey]!;
  List<JsonObject> get postReactions =>
      _sections[SocialDataConstants.postReactionsKey]!;
  List<JsonObject> get commentReactions =>
      _sections[SocialDataConstants.commentReactionsKey]!;
  List<JsonObject> get postSaves =>
      _sections[SocialDataConstants.postSavesKey]!;
  List<JsonObject> get postShares =>
      _sections[SocialDataConstants.postSharesKey]!;
  List<JsonObject> get liveSessions =>
      _sections[SocialDataConstants.liveSessionsKey]!;
  List<JsonObject> get liveParticipants =>
      _sections[SocialDataConstants.liveParticipantsKey]!;
  List<JsonObject> get liveChatMessages =>
      _sections[SocialDataConstants.liveChatMessagesKey]!;
  List<JsonObject> get liveReactions =>
      _sections[SocialDataConstants.liveReactionsKey]!;
  List<JsonObject> get liveEngagementSummaries =>
      _sections[SocialDataConstants.liveEngagementSummariesKey]!;
  List<JsonObject> get liveModerationActions =>
      _sections[SocialDataConstants.liveModerationActionsKey]!;
  List<JsonObject> get liveRecordings =>
      _sections[SocialDataConstants.liveRecordingsKey]!;

  JsonObject? postById(String id) => _findById(posts, id);

  JsonObject? hashtagById(String id) => _findById(hashtags, id);

  JsonObject? profileForParty(String partyId) =>
      _firstByValue(userProfiles, SocialDataConstants.partyIdKey, partyId);

  JsonObject? profileForPartyRole(String partyRoleId) {
    final partyRole = _firstByValue(
      partyRoles,
      SocialDataConstants.idKey,
      partyRoleId,
    );
    final partyId = partyRole?[SocialDataConstants.partyIdKey];
    if (partyId is! String) return null;
    return profileForParty(partyId);
  }

  JsonObject? liveSessionById(String id) => _findById(liveSessions, id);

  List<JsonObject> commentsForPost(String postId) =>
      _findByValue(comments, SocialDataConstants.postIdKey, postId);

  List<JsonObject> messagesForConversation(String conversationId) =>
      _findByValue(
        conversationMessages,
        SocialDataConstants.conversationIdKey,
        conversationId,
      );

  List<JsonObject> chatMessagesForLive(String liveSessionId) => _findByValue(
    liveChatMessages,
    SocialDataConstants.liveSessionIdKey,
    liveSessionId,
  );

  static List<JsonObject> _readObjects(JsonObject json, String section) {
    final value = json[section];
    if (value is! List) {
      throw FormatException(
        AppStrings.missingSocialMockDataSection.replaceAll(
          '{section}',
          section,
        ),
      );
    }

    return List.unmodifiable(
      value.map((item) {
        if (item is! Map<String, dynamic>) {
          throw FormatException(
            AppStrings.invalidSocialMockDataItems.replaceAll(
              '{section}',
              section,
            ),
          );
        }
        return _freezeObject(item);
      }),
    );
  }

  static JsonObject _freezeObject(JsonObject json) => Map.unmodifiable({
    for (final entry in json.entries) entry.key: _freezeValue(entry.value),
  });

  static Object? _freezeValue(Object? value) {
    if (value is Map<String, dynamic>) return _freezeObject(value);
    if (value is List) {
      return List.unmodifiable(value.map(_freezeValue));
    }
    return value;
  }

  static JsonObject? _findById(List<JsonObject> objects, String id) {
    return _firstByValue(objects, SocialDataConstants.idKey, id);
  }

  static JsonObject? _firstByValue(
    List<JsonObject> objects,
    String key,
    Object? value,
  ) {
    final matches = _findByValue(objects, key, value);
    return matches.isEmpty ? null : matches.first;
  }

  static List<JsonObject> _findByValue(
    List<JsonObject> objects,
    String key,
    Object? value,
  ) => List.unmodifiable(objects.where((item) => item[key] == value));
}
