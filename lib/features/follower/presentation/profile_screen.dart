import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/network/dio_client.dart';
import '../../friendship/presentation/friendship_provider.dart';
import '../data/follower_api.dart';
import '../domain/counters.dart';
import '../domain/follow_status.dart';

/// Profile of another user: follow/following, counters and the add friend button
/// (only enabled when the follow is mutual).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.userCode, required this.name});

  final String userCode;
  final String name;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final FollowerApi _api = FollowerApi(context.read<DioClient>().dio);

  FollowStatus? _followStatus;
  Counters? _counters;
  bool _loading = true;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final followStatus = await _api.status(widget.userCode);
      final counters = await _api.counters(widget.userCode);
      if (!mounted) {
        return;
      }
      setState(() {
        _followStatus = followStatus;
        _counters = counters;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _toggleFollow() async {
    final followStatus = _followStatus;
    if (followStatus == null) {
      return;
    }
    setState(() => _processing = true);
    try {
      if (followStatus.isFollowing) {
        await _api.unfollow(widget.userCode);
      } else {
        await _api.follow(widget.userCode);
      }
      await _load();
    } catch (_) {
      _showMessage('Nao foi possivel atualizar');
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  Future<void> _addFriend() async {
    final error = await context.read<FriendshipProvider>().sendRequest(widget.userCode);
    if (!mounted) {
      return;
    }
    _showMessage(error ?? 'Solicitacao de amizade enviada');
  }

  void _showMessage(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  void _openList(String type, String title) {
    context.push('/usuarios', extra: {
      'codigo': widget.userCode,
      'tipo': type,
      'titulo': title,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 32, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(child: Text(widget.name, style: theme.textTheme.titleLarge)),
                Center(child: Text(widget.userCode, style: theme.textTheme.bodySmall)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _counter('Seguidores', _counters?.followers ?? 0,
                        () => _openList('seguidores', 'Seguidores')),
                    _counter('Seguindo', _counters?.following ?? 0,
                        () => _openList('seguindo', 'Seguindo')),
                  ],
                ),
                const SizedBox(height: 24),
                _followButton(),
                const SizedBox(height: 12),
                _addFriendButton(),
              ],
            ),
    );
  }

  Widget _counter(String label, int value, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text('$value', style: theme.textTheme.titleLarge),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _followButton() {
    final isFollowing = _followStatus?.isFollowing ?? false;
    final child = _processing
        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
        : Text(isFollowing ? 'Seguindo' : 'Seguir');
    return isFollowing
        ? OutlinedButton(onPressed: _processing ? null : _toggleFollow, child: child)
        : FilledButton(onPressed: _processing ? null : _toggleFollow, child: child);
  }

  Widget _addFriendButton() {
    final isMutual = _followStatus?.isMutual ?? false;
    return OutlinedButton.icon(
      onPressed: isMutual ? _addFriend : null,
      icon: const Icon(Icons.person_add),
      label: Text(isMutual ? 'Adicionar amigo' : 'Adicionar amigo (precisa ser mutuo)'),
    );
  }
}
