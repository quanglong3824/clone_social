import 'package:flutter/material.dart';

/// A widget that displays post images in a grid layout.
/// Shows up to 4 images with a "+X" indicator when there are more.
class PostImageGrid extends StatelessWidget {
  final List<String> images;
  final double height;
  final double spacing;
  final BorderRadius? borderRadius;
  final void Function(int index)? onImageTap;

  const PostImageGrid({
    super.key,
    required this.images,
    this.height = 300,
    this.spacing = 2,
    this.borderRadius,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: _buildGrid(),
      ),
    );
  }

  Widget _buildGrid() {
    switch (images.length) {
      case 1:
        return _buildSingleImage();
      case 2:
        return _buildTwoImages();
      case 3:
        return _buildThreeImages();
      default:
        return _buildFourOrMoreImages();
    }
  }

  Widget _buildSingleImage() {
    return _ImageTile(
      imageUrl: images[0],
      onTap: () => onImageTap?.call(0),
    );
  }


  Widget _buildTwoImages() {
    return Row(
      children: [
        Expanded(
          child: _ImageTile(
            imageUrl: images[0],
            onTap: () => onImageTap?.call(0),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _ImageTile(
            imageUrl: images[1],
            onTap: () => onImageTap?.call(1),
          ),
        ),
      ],
    );
  }

  Widget _buildThreeImages() {
    return Row(
      children: [
        Expanded(
          child: _ImageTile(
            imageUrl: images[0],
            onTap: () => onImageTap?.call(0),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: _ImageTile(
                  imageUrl: images[1],
                  onTap: () => onImageTap?.call(1),
                ),
              ),
              SizedBox(height: spacing),
              Expanded(
                child: _ImageTile(
                  imageUrl: images[2],
                  onTap: () => onImageTap?.call(2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFourOrMoreImages() {
    final remainingCount = images.length - 4;
    
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: _ImageTile(
                  imageUrl: images[0],
                  onTap: () => onImageTap?.call(0),
                ),
              ),
              SizedBox(height: spacing),
              Expanded(
                child: _ImageTile(
                  imageUrl: images[2],
                  onTap: () => onImageTap?.call(2),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: _ImageTile(
                  imageUrl: images[1],
                  onTap: () => onImageTap?.call(1),
                ),
              ),
              SizedBox(height: spacing),
              Expanded(
                child: _ImageTile(
                  imageUrl: images[3],
                  onTap: () => onImageTap?.call(3),
                  overlay: remainingCount > 0
                      ? _RemainingCountOverlay(count: remainingCount)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImageTile extends StatelessWidget {
  final String imageUrl;
  final VoidCallback? onTap;
  final Widget? overlay;

  const _ImageTile({
    required this.imageUrl,
    this.onTap,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                  ),
                ),
              );
            },
          ),
          if (overlay != null) overlay!,
        ],
      ),
    );
  }
}

class _RemainingCountOverlay extends StatelessWidget {
  final int count;

  const _RemainingCountOverlay({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Text(
          '+$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
