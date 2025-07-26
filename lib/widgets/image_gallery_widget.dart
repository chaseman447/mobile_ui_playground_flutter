import 'package:flutter/material.dart';
import '../utils/alignment_parser.dart'; // Import alignment parsing utilities

class ImageGalleryWidget extends StatelessWidget {
  final List<String> imageUrls;
  final int currentImageIndex;
  final bool imageAutoPlay;
  final bool isVisible;
  final Alignment alignment;
  final double padding;
  final VoidCallback onNextImage;
  final VoidCallback onPrevImage;
  final VoidCallback onToggleAutoPlay;

  const ImageGalleryWidget({
    super.key,
    required this.imageUrls,
    required this.currentImageIndex,
    required this.imageAutoPlay,
    required this.isVisible,
    required this.alignment,
    required this.padding,
    required this.onNextImage,
    required this.onPrevImage,
    required this.onToggleAutoPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Align(
          alignment: alignment,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Image Gallery',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  if (imageUrls.isNotEmpty)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: ClipRRect(
                        key: ValueKey(currentImageIndex),
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrls[currentImageIndex],
                          width: 200,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 200,
                              height: 150,
                              color: Colors.grey[300],
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, size: 40),
                                  Text('Image Error', textAlign: TextAlign.center),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 200,
                      height: 150,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Text('No Images Loaded', textAlign: TextAlign.center),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: onPrevImage,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${currentImageIndex + 1} of ${imageUrls.length}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: onNextImage,
                      ),
                      IconButton(
                        icon: Icon(imageAutoPlay ? Icons.pause_circle : Icons.play_circle),
                        onPressed: onToggleAutoPlay,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(imageUrls.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: currentImageIndex == index ? 12 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentImageIndex == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
