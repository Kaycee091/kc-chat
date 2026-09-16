import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Renders a network image safely with graceful loading, fallback and error builders.
class SafeNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? fallbackWidget;

  const SafeNetworkImage({
    super.key,
    String? url,
    String? imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackWidget,
  }) : url = imageUrl ?? url ?? '';

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return _buildFallback(context);
    }

    final imageWidget = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildFallback(context),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkBackground
              : Colors.grey.shade200,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }
    return imageWidget;
  }

  Widget _buildFallback(BuildContext context) {
    if (fallbackWidget != null) return fallbackWidget!;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard
            : Colors.grey.shade300,
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Colors.grey, size: 24),
    );
  }
}

/// Renders an Avatar safely with fallback initials or person icon
class SafeAvatar extends StatelessWidget {
  final String url;
  final double radius;
  final String? name;

  const SafeAvatar({
    super.key,
    String? url,
    String? imageUrl,
    this.radius = 20,
    this.name,
  }) : url = imageUrl ?? url ?? '';

  @override
  Widget build(BuildContext context) {
    final initials = (name != null && name!.trim().isNotEmpty)
        ? name!.trim().split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join()
        : '';

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
      backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
      onBackgroundImageError: url.isNotEmpty ? (_, __) {} : null,
      child: url.isEmpty
          ? (initials.isNotEmpty
              ? Text(
                  initials,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: radius * 0.75,
                  ),
                )
              : Icon(Icons.person, size: radius, color: AppColors.primary))
          : null,
    );
  }
}

/// Helper HttpOverrides for Flutter test runner so network image requests return a valid 1x1 transparent PNG.
class TestImageHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _TestImageHttpClient();
  }
}

class _TestImageHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _TestImageHttpClientRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #autoUncompress) return true;
    if (invocation.isMethod) {
      return Future.value(_TestImageHttpClientRequest());
    }
    return null;
  }
}

class _TestImageHttpClientRequest implements HttpClientRequest {
  @override
  final HttpHeaders headers = _EmptyHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _TestImageHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #close) {
      return Future.value(_TestImageHttpClientResponse());
    }
    return null;
  }
}

class _TestImageHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  // 1x1 transparent PNG bytes
  static final List<int> _kTransparentImage = [
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
    0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
    0x42, 0x60, 0x82,
  ];

  @override
  int get statusCode => 200;

  @override
  int get contentLength => _kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  final HttpHeaders headers = _EmptyHttpHeaders();

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_kTransparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _EmptyHttpHeaders implements HttpHeaders {
  @override
  List<String>? operator [](String name) => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
