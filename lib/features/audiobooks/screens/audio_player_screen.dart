import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/continue_content_service.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/utils/auth_guard.dart';
import '../../cart/cart_provider.dart';
import '../../cart/screens/cart_screen.dart';
import '../../books/models/content_model.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key, this.contentId});

  final int? contentId;

  static const String routeName = '/audio-player';

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final _api = ApiService();
  final _player = AudioPlayer();

  bool _loading = true;
  String? _error;
  ContentModel? _content;
  bool _purchaseRequired = false;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _playing = false;
  double _speed = 1.0;
  static const _speeds = [1.0, 1.25, 1.5];

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _stateSub;

  @override
  void initState() {
    super.initState();
    _positionSub = _player.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _durationSub = _player.durationStream.listen((d) {
      if (mounted && d != null) setState(() => _duration = d);
    });
    _stateSub = _player.playerStateStream.listen((s) {
      if (mounted) setState(() => _playing = s.playing);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!ensureLoggedIn(context)) {
        Navigator.of(context).pop();
        return;
      }
      _load();
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  int _resolveId(BuildContext context) {
    if (widget.contentId != null) return widget.contentId!;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ContentModel) return args.id;
    if (args is int) return args;
    return 0;
  }

  Future<void> _load() async {
    final id = _resolveId(context);
    if (id <= 0) {
      setState(() {
        _loading = false;
        _error = 'Invalid audiobook.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _purchaseRequired = false;
    });

    try {
      final data = await _api.get(
        ApiConstants.contentDetails,
        query: {'id': '$id'},
      );
      final raw = data is Map ? (data['content'] ?? data['data']) : null;
      if (raw is! Map) throw Exception('Audiobook not found.');
      final content = ContentModel.fromJson(Map<String, dynamic>.from(raw));

      if (!content.userCanAccessContent) {
        if (!mounted) return;
        setState(() {
          _content = content;
          _loading = false;
          _purchaseRequired = true;
        });
        return;
      }

      final url = _resolveStreamUrl(content);
      if (url.isEmpty) {
        throw Exception('No audio file is available.');
      }

      final token = await SecureStorage().getAuthToken();
      final headers = <String, String>{};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(url), headers: headers),
      );
      if (!mounted) return;
      setState(() {
        _content = content;
        _loading = false;
      });
      final auth = context.read<AuthService>();
      if (auth.isLoggedIn && auth.user != null) {
        await ContinueContentService.instance
            .saveListening(auth.user!.id, content);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _friendlyAudioError(e);
      });
    }
  }

  String _resolveStreamUrl(ContentModel content) {
    final raw = content.listenUrl ?? content.audioUrl ?? '';
    if (raw.isEmpty) return '';
    if (raw.contains('/uploads/audio/')) {
      return ApiConstants.endpoint('/stream_audio.php?id=${content.id}');
    }
    return raw;
  }

  String _friendlyAudioError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('source error') || msg.contains('(0)')) {
      return 'Could not load audio. Check your connection and try again.';
    }
    return e.toString();
  }

  Future<void> _togglePlay() async {
    if (_playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> _seekRelative(int seconds) async {
    final target = _position + Duration(seconds: seconds);
    final clamped = target < Duration.zero
        ? Duration.zero
        : (_duration.inMilliseconds > 0 && target > _duration)
            ? _duration
            : target;
    await _player.seek(clamped);
  }

  void _cycleSpeed() {
    final idx = _speeds.indexOf(_speed);
    final next = _speeds[(idx + 1) % _speeds.length];
    setState(() => _speed = next);
    _player.setSpeed(next);
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  void _addToCart() {
    final content = _content;
    if (content == null) return;
    requireLogin(context, () {
      context.read<CartProvider>().addItem(content);
      Navigator.of(context).pushNamed(CartScreen.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.espresso,
              AppColors.espressoDeep,
              AppColors.espressoDark,
            ],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.caramel),
                )
              : _purchaseRequired
                  ? _purchaseView()
                  : _error != null
                      ? _errorView()
                      : _playerView(),
        ),
      ),
    );
  }

  Widget _playerView() {
    final content = _content!;
    final maxMs = _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 1.0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.tortilla, size: 32),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Now playing',
                      style: TextStyle(
                        color: AppColors.mutedText.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      content.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.tortilla,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 32,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: content.coverUrl != null && content.coverUrl!.isNotEmpty
                          ? Image.network(content.coverUrl!, fit: BoxFit.cover)
                          : Container(
                              color: AppColors.espressoSoft,
                              child: const Icon(Icons.headphones_rounded,
                                  size: 80, color: AppColors.caramel),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  content.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.tortilla,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (content.author != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    content.author!,
                    style: const TextStyle(color: AppColors.mutedText, fontSize: 15),
                  ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  activeTrackColor: AppColors.caramel,
                  inactiveTrackColor: AppColors.espressoSoft,
                  thumbColor: AppColors.tortilla,
                ),
                child: Slider(
                  value: _position.inMilliseconds.clamp(0, maxMs.toInt()).toDouble(),
                  max: maxMs,
                  onChanged: (v) => _player.seek(Duration(milliseconds: v.toInt())),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_format(_position),
                      style: const TextStyle(color: AppColors.mutedText, fontSize: 12)),
                  Text(_format(_duration),
                      style: const TextStyle(color: AppColors.mutedText, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _cycleSpeed,
                    child: Text(
                      '${_speed}x',
                      style: const TextStyle(
                        color: AppColors.caramel,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _seekRelative(-10),
                    iconSize: 36,
                    color: AppColors.tortilla,
                    icon: const Icon(Icons.replay_10_rounded),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: AppColors.caramel,
                    shape: const CircleBorder(),
                    elevation: 8,
                    child: InkWell(
                      onTap: _togglePlay,
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: 72,
                        height: 72,
                        child: Icon(
                          _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 40,
                          color: AppColors.espressoDeep,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _seekRelative(10),
                    iconSize: 36,
                    color: AppColors.tortilla,
                    icon: const Icon(Icons.forward_10_rounded),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _purchaseView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 56, color: AppColors.caramel),
            const SizedBox(height: 16),
            Text(
              _content?.title ?? 'Audiobook',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.tortilla,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Purchase required',
              style: TextStyle(color: AppColors.mutedText),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addToCart,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add to Cart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.caramel,
                foregroundColor: AppColors.espressoDeep,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.caramel),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.tortilla),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.caramel,
                foregroundColor: AppColors.espressoDeep,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
