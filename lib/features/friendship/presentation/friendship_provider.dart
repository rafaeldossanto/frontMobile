import 'package:flutter/foundation.dart';

import '../data/friendship_api.dart';
import '../data/user_search_api.dart';
import '../domain/friendship.dart';
import '../domain/public_user.dart';

/// Friendship state: friends, pending requests and user search.
class FriendshipProvider extends ChangeNotifier {
  FriendshipProvider(this._api, this._searchApi);

  final FriendshipApi _api;
  final UserSearchApi _searchApi;

  bool _loading = false;
  String? _error;
  List<Friendship> _friends = const [];
  List<Friendship> _pending = const [];
  List<PublicUser> _searchResults = const [];

  bool get loading => _loading;
  String? get error => _error;
  List<Friendship> get friends => List.unmodifiable(_friends);
  List<Friendship> get pending => List.unmodifiable(_pending);
  List<PublicUser> get searchResults => List.unmodifiable(_searchResults);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _friends = (await _api.listFriends()).content;
      _pending = (await _api.pending()).content;
    } catch (_) {
      _error = 'Nao foi possivel carregar as amizades.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> search(String term) async {
    if (term.trim().isEmpty) {
      _searchResults = const [];
      notifyListeners();
      return;
    }
    try {
      _searchResults = await _searchApi.searchUsers(term.trim());
    } catch (_) {
      _searchResults = const [];
    }
    notifyListeners();
  }

  /// Sends a friend request by userCode. Returns null on success or the error message.
  Future<String?> sendRequest(String userCode) async {
    try {
      await _api.sendRequest(userCode);
      return null;
    } catch (_) {
      return 'Nao foi possivel enviar a solicitacao.';
    }
  }

  Future<void> respond(String friendshipId, String status) async {
    try {
      await _api.respond(friendshipId, status);
      await load();
    } catch (_) {
      _error = 'Nao foi possivel responder a solicitacao.';
      notifyListeners();
    }
  }
}
