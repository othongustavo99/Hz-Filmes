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
  static const double _videoHeight = _cardWidth * 9 / 16; // ~146.25

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _cardWidth,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: _cardWidth,
              // Espaço extra só quando o player está ativo (barra do YouTube)
              height: _isPlaying ? _videoHeight + 40 : _videoHeight,
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
                          // SEM overlay preto em cima da imagem inteira
                          // Só o botão de play pequeno
                          const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 30,
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
