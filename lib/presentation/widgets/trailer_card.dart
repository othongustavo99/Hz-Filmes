import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/video_model.dart';

class TrailerCard extends StatefulWidget {
  final VideoModel trailer;

  const TrailerCard({super.key, required this.trailer});

  @override
  State<TrailerCard> createState() => _TrailerCardState();
}

class _TrailerCardState extends State<TrailerCard> {
  YoutubePlayerController? _controller;
  bool _isPlaying = false;

  Future<void> _startPlayer() async {
    final controller = YoutubePlayerController.fromVideoId(
      videoId: widget.trailer.key,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        showControls: true,
        mute: false,
      ),
    );

    setState(() {
      _controller = controller;
      _isPlaying = true;
    });
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  static const double _cardWidth = 260;
  static const double _videoHeight = _cardWidth * 9 / 16;
  static const double _controlsBarHeight = 10;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _cardWidth,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: _cardWidth,
              // Enquanto tocando, soma o espaço da barra de controles.
              // Parado (thumbnail), usa só a altura 16:9.
              height: _isPlaying
                  ? _videoHeight + _controlsBarHeight
                  : _videoHeight,
              child: _isPlaying && _controller != null
                  ? YoutubePlayer(
                      controller: _controller!,
                      aspectRatio: 16 / 9,
                    )
                  : GestureDetector(
                      onTap: _startPlayer,
                      child: Stack(
                        alignment: Alignment.center,
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            widget.trailer.thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppTheme.cardDark,
                              child: const Icon(
                                Icons.movie,
                                color: Colors.white24,
                              ),
                            ),
                          ),
                          Container(color: Colors.black38),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.trailer.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
