import 'dart:async';
import 'package:flutter/material.dart';

class NetworkImageWithTimeout extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration timeout;
  final BorderRadius? borderRadius;

  const NetworkImageWithTimeout({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.timeout = const Duration(seconds: 10),
    this.borderRadius,
  }) : super(key: key);

  @override
  State<NetworkImageWithTimeout> createState() =>
      _NetworkImageWithTimeoutState();
}

class _NetworkImageWithTimeoutState extends State<NetworkImageWithTimeout> {
  bool _hasTimedOut = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimeout();
  }

  void _startTimeout() {
    _timer = Timer(widget.timeout, () {
      if (mounted) {
        setState(() {
          _hasTimedOut = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[200],
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[200],
      child: Icon(
        Icons.person,
        color: Colors.grey[400],
        size: (widget.width != null && widget.height != null)
            ? (widget.width! + widget.height!) / 4
            : 24,
      ),
    );
  }

  Widget _buildTimeoutWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            color: Colors.grey[400],
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            'Timeout',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (_hasTimedOut) {
      imageWidget = _buildTimeoutWidget();
    } else {
      imageWidget = Image.network(
        widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        loadingBuilder: (context, child, loadingProgress) {
          // Cancel timeout when image loads successfully
          if (loadingProgress == null) {
            _timer?.cancel();
            return child;
          }
          return widget.placeholder ?? _buildDefaultPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          _timer?.cancel();

          // Log error for debugging
          print('🖼️ Image Load Error: $error');
          print('📍 Image URL: ${widget.imageUrl}');

          return widget.errorWidget ?? _buildDefaultErrorWidget();
        },
      );
    }

    // Apply border radius if provided
    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

/// Helper widget specifically for avatar images
class AvatarImageWithTimeout extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Duration timeout;

  const AvatarImageWithTimeout({
    Key? key,
    this.imageUrl,
    this.radius = 24,
    this.timeout = const Duration(seconds: 8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildDefaultAvatar();
    }

    return NetworkImageWithTimeout(
      imageUrl: imageUrl!,
      width: radius * 2,
      height: radius * 2,
      fit: BoxFit.cover,
      timeout: timeout,
      borderRadius: BorderRadius.circular(radius),
      errorWidget: _buildDefaultAvatar(),
      placeholder: _buildLoadingAvatar(),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: Colors.grey[400],
        size: radius,
      ),
    );
  }

  Widget _buildLoadingAvatar() {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SizedBox(
          width: radius * 0.6,
          height: radius * 0.6,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
          ),
        ),
      ),
    );
  }
}
