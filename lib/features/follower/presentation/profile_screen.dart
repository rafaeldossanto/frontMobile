import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/network/dio_client.dart';
import '../../../shared/widgets/story_avatar.dart';
import '../../friendship/presentation/friendship_provider.dart';
import '../data/follower_api.dart';
import '../domain/counters.dart';
import '../domain/follow_status.dart';

/// Perfil de outro usuario, estilo Instagram: cabecalho com avatar +
/// contadores, botoes Seguir/Amigo lado a lado e a area de aventuras
/// privada (so amigos veem as trilhas no feed).
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userCode, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        StoryAvatar(name: widget.name, radius: 38),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _counter('Seguidores', _counters?.followers ?? 0,
                                  () => _openList('seguidores', 'Seguidores')),
                              _counter('Seguindo', _counters?.following ?? 0,
                                  () => _openList('seguindo', 'Seguindo')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(widget.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(child: _followButton()),
                        const SizedBox(width: 8),
                        Expanded(child: _addFriendButton()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.only(top: 64, left: 32, right: 32),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 2),
                          ),
                          child: const Icon(Icons.lock_outline, size: 32),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'As aventuras deste trilheiro sao privadas',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Siga e vire amigo para acompanhar as trilhas dele.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _counter(String label, int value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
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
      icon: const Icon(Icons.person_add_alt, size: 18),
      label: Text(isMutual ? 'Adicionar amigo' : 'Amigo (siga mutuo)'),
    );
  }
}
