import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class VideoBannerWidget extends StatefulWidget {
  final String url;
  final VoidCallback? onTap;
  final VoidCallback? onFinished;
  final bool isActive;
  const VideoBannerWidget(
      {super.key,
      required this.url,
      this.onTap,
      this.onFinished,
      this.isActive = false});

  @override
  State<VideoBannerWidget> createState() => _VideoBannerWidgetState();
}

class _VideoBannerWidgetState extends State<VideoBannerWidget>
    with WidgetsBindingObserver {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _initialized = false;
  bool _error = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeController();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_initialized && _videoPlayerController != null) {
      if (state == AppLifecycleState.resumed) {
        if (widget.isActive) {
          _videoPlayerController!.play();
        }
      } else {
        _videoPlayerController!.pause();
      }
    }
  }

  Future<void> _initializeController() async {
    try {
      final fileInfo = await DefaultCacheManager().getFileFromCache(widget.url);
      File file;

      if (fileInfo != null) {
        file = fileInfo.file;
      } else {
        final downloadFile =
            await DefaultCacheManager().getSingleFile(widget.url);
        file = downloadFile;
      }

      _videoPlayerController = VideoPlayerController.file(file);
      await _videoPlayerController!.initialize();
      _videoPlayerController!.addListener(_videoListener);

      // Set initial state based on activity
      if (widget.isActive) {
        _videoPlayerController!.play();
      } else {
        _videoPlayerController!.pause();
      }

      _createChewieController();

      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    } catch (e) {
      debugPrint("❌ [VideoBanner] Error loading video: $e");
      if (mounted) {
        setState(() {
          _error = true;
        });
      }
    }
  }

  @override
  void didUpdateWidget(VideoBannerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_initialized && _videoPlayerController != null) {
      if (widget.isActive && !oldWidget.isActive) {
        _videoPlayerController!.play();
      } else if (!widget.isActive && oldWidget.isActive) {
        _videoPlayerController!.pause();
      }
    }
  }

  void _videoListener() {
    if (mounted) {
      if (_videoPlayerController != null &&
          _videoPlayerController!.value.position >=
              _videoPlayerController!.value.duration &&
          _videoPlayerController!.value.duration != Duration.zero &&
          !_finished) {
        _finished = true;
        if (widget.onFinished != null) {
          widget.onFinished!();
        }
      }
      setState(() {});
    }
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: widget.isActive,
      looping: false,
      showControls:
          true, // لازم تكون true عشان الكنترولز تظهر في الشاشة الكاملة
      showOptions: false,
      allowFullScreen: true,
      allowMuting: true,
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      deviceOrientationsAfterFullScreen: const [DeviceOrientation.portraitUp],
      customControls: const _CustomControls(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoPlayerController?.removeListener(_videoListener);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
      child: Container(
        color: Colors.black12,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_initialized && _chewieController != null)
              GestureDetector(
                onTap: widget
                    .onTap, // يفتح اللينك عند الضغط على أي مكان في الفيديو
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoPlayerController!.value.size.width,
                      height: _videoPlayerController!.value.size.height,
                      child: Chewie(controller: _chewieController!),
                    ),
                  ),
                ),
              )
            else if (_error)
              const Icon(Icons.error_outline, color: Colors.white54)
            else
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),

            // أيقونات التحكم المخصصة في الهوم سكرين (Play/Pause و Fullscreen)
            if (_initialized && _videoPlayerController != null)
              Positioned(
                bottom: 10,
                right: 10,
                child: Row(
                  children: [
                    // زر التشغيل والإيقاف
                    GestureDetector(
                      onTap: () {
                        if (_videoPlayerController!.value.isPlaying) {
                          _videoPlayerController!.pause();
                        } else {
                          _videoPlayerController!.play();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          _videoPlayerController!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // زر التكبير
                    GestureDetector(
                      onTap: () {
                        _chewieController?.enterFullScreen();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomControls extends StatefulWidget {
  const _CustomControls();

  @override
  _CustomControlsState createState() => _CustomControlsState();
}

class _CustomControlsState extends State<_CustomControls> {
  ChewieController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final oldController = _controller;
    _controller = ChewieController.of(context);
    if (oldController != _controller) {
      oldController?.removeListener(_listener);
      _controller?.addListener(_listener);
    }
  }

  void _listener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // في الهوم سكرين (مش FullScreen) مش عاوزين الكنترولز تظهر عشان حاطين أيكوناتنا الخاصة
    if (_controller == null || !_controller!.isFullScreen) {
      return const SizedBox.shrink();
    }

    // في وضع الشاشة الكاملة (FullScreen) بنظهر أدوات التحكم وزر الإغلاق X
    return Stack(
      children: [
        const MaterialControls(),
        Positioned(
          top: 10,
          left: 10,
          child: SafeArea(
            child: GestureDetector(
              onTap: () {
                // إرجاع الشاشة للوضع الطولي ثم الخروج
                SystemChrome.setPreferredOrientations(
                    [DeviceOrientation.portraitUp]);
                _controller!.exitFullScreen();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close,
                    color: Colors.white, size: 28), // أيقونة إغلاق واضحة
              ),
            ),
          ),
        ),
      ],
    );
  }
}
