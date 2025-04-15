import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../model/channel.dart';
import 'package:wakelock/wakelock.dart';

class Player extends StatefulWidget {
  final Channel channel;

  Player({required this.channel});

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  bool _isLoading = true;
  bool _channelNotFound = false;

  @override
  void initState() {
    super.initState();
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.channel.streamUrl))
          ..initialize().then((_) {
            setState(() {
              _isLoading = false;
            });
          }).catchError((error) {
            setState(() {
              _isLoading = false;
              _channelNotFound = true;
            });
          });

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoInitialize: true,
      isLive: true,
      autoPlay: true,
      aspectRatio: 4 / 3, 
      showOptions: false,
    );

    videoPlayerController.addListener(() {
      if (videoPlayerController.value.isPlaying) {
        Wakelock.enable();
      } else {
        Wakelock.disable();
      }
    });
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(" Image url ${widget.channel.logoUrl}");
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.6), 
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  widget.channel.logoUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/tv-icon.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.channel.name.toUpperCase(),
                style: GoogleFonts.bungee(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                  letterSpacing: 2.0, 
                  shadows: [
                    Shadow(
                      color: Colors.amber.withOpacity(0.8),
                      blurRadius: 5,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                overflow:
                    TextOverflow.ellipsis, 
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.grey[900]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          StaticNoiseBackground(),
          Center(
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.amber)
                : _channelNotFound
                    ? const Text(
                        'Channel not available now',
                        style: TextStyle(fontSize: 24.0, color: Colors.white),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey[700]!, width: 10),
                              borderRadius: BorderRadius.circular(20.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.2),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.amber.withOpacity(0.1),
                                  BlendMode.softLight),
                              child: Chewie(
                                controller: chewieController,
                              ),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class StaticNoiseBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            Colors.grey[900]!.withOpacity(0.8),
            Colors.grey[800]!.withOpacity(0.8),
            Colors.grey[900]!.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      blendMode: BlendMode.multiply,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [Colors.black, Colors.grey[900]!],
            center: Alignment.center,
            radius: 1.2,
          ),
        ),
      ),
    );
  }
}
