import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/views/screens/gallery/video_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class GalleryView extends StatefulWidget {
  var imageUrls;
  final int initialIndex;

  GalleryView({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  _GalleryViewState createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _currentIndex = widget.initialIndex;
        _pageController.jumpToPage(_currentIndex);
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool isVideo(String url) {
    return url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.avi');
  }

  Widget buildMediaWidget(String url) {
    if (isVideo(url)) {
      return VideoPlayerScreen(video: url);
    } else {
      return PhotoView(imageProvider: NetworkImage(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottompadding = MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('View Media', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => RouteHelper.pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: bottompadding),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Center(child: buildMediaWidget(widget.imageUrls[index]));
              },
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "${_currentIndex + 1} / ${widget.imageUrls.length}",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
