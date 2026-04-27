import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/device_service.dart';
import '../config/asset_config.dart';
import '../services/download_manager.dart';

// Adaptive Image Widget
class AdaptiveImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableCache;
  final String? quality;

  const AdaptiveImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.enableCache = true,
    this.quality,
  });

  @override
  State<AdaptiveImage> createState() => _AdaptiveImageState();
}

class _AdaptiveImageState extends State<AdaptiveImage> {
  final DownloadManager _downloadManager = DownloadManager();
  String? _localPath;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final fileName = _extractFileName(widget.imageUrl);
      final path = await _downloadManager.downloadImage(
        widget.imageUrl,
        fileName: fileName,
        quality: widget.quality,
        onProgress: (progress) {
          // Progress updates can be handled here if needed
        },
        onComplete: (filePath) {
          if (mounted) {
            setState(() {
              _localPath = filePath;
              _isLoading = false;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _hasError = true;
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  String _extractFileName(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'image.jpg';
    } catch (e) {
      return 'image.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholder ?? _buildDefaultPlaceholder();
    }

    if (_hasError || _localPath == null) {
      return widget.errorWidget ?? _buildDefaultError();
    }

    return Image.file(
      File(_localPath!),
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return widget.errorWidget ?? _buildDefaultError();
      },
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.broken_image,
        color: Colors.grey,
        size: 48,
      ),
    );
  }
}

// Adaptive Grid Layout
class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final EdgeInsets padding;
  final int? crossAxisCount;

  const AdaptiveGrid({
    super.key,
    required this.children,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.padding = EdgeInsets.zero,
    this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    final assetConfig = AssetConfig();
    final columns = crossAxisCount ?? assetConfig.getGridColumns();

    return Padding(
      padding: padding,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: runSpacing,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}

// Adaptive Card Widget
class AdaptiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const AdaptiveCard({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.all(8.0),
    this.padding = const EdgeInsets.all(16.0),
    this.elevation,
    this.color,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final deviceService = DeviceService();
    final deviceInfo = deviceService.deviceInfo;
    
    final cardElevation = elevation ?? 
        (deviceInfo.performanceCategory == DevicePerformanceCategory.low ? 1.0 : 4.0);
    
    final cardColor = color ?? Theme.of(context).cardColor;
    final cardRadius = borderRadius ?? BorderRadius.circular(12.0);

    Widget card = Card(
      elevation: cardElevation,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: cardRadius,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: cardRadius,
        child: card,
      );
    }

    return Container(
      margin: margin,
      child: card,
    );
  }
}

// Adaptive Text Widget
class AdaptiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AdaptiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final assetConfig = AssetConfig();
    final fontScaling = assetConfig.getFontScaling();
    
    TextStyle scaledStyle = style ?? Theme.of(context).textTheme.bodyMedium!;
    
    // Apply font scaling
    if (fontScaling != 1.0 && scaledStyle.fontSize != null) {
      scaledStyle = scaledStyle.copyWith(
        fontSize: scaledStyle.fontSize! * fontScaling,
      );
    }

    return Text(
      text,
      style: scaledStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

// Adaptive Icon Widget
class AdaptiveIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;

  const AdaptiveIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final assetConfig = AssetConfig();
    final iconSize = size ?? assetConfig.ui['icon_size'].toDouble();
    
    return Icon(
      icon,
      size: iconSize,
      color: color,
    );
  }
}

// Adaptive Button Widget
class AdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonStyle? style;
  final Widget? icon;
  final bool isLoading;

  const AdaptiveButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.style,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final deviceService = DeviceService();
    final assetConfig = AssetConfig();
    
    // Disable animations on low-end devices
    final enableAnimations = deviceService.canHandleHeavyAnimations();
    
    Widget buttonChild;
    if (isLoading) {
      buttonChild = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            style?.foregroundColor?.resolve({}) ?? Colors.white,
          ),
        ),
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          AdaptiveText(text),
        ],
      );
    } else {
      buttonChild = AdaptiveText(text);
    }

    return AnimatedContainer(
      duration: enableAnimations ? Duration(milliseconds: assetConfig.animations['transition_duration']) : Duration.zero,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: buttonChild,
      ),
    );
  }
}

// Adaptive List Tile
class AdaptiveListTile extends StatelessWidget {
  final Widget? leading;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? contentPadding;

  const AdaptiveListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final assetConfig = AssetConfig();
    
    return ListTile(
      leading: leading,
      title: title != null ? AdaptiveText(title!) : null,
      subtitle: subtitle != null ? AdaptiveText(
        subtitle!,
        style: Theme.of(context).textTheme.bodySmall,
      ) : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: contentPadding,
      minVerticalPadding: assetConfig.ui['font_scaling'] > 1.2 ? 12 : 8,
    );
  }
}

// Adaptive Scaffold
class AdaptiveScaffold extends StatelessWidget {
  final Widget body;
  final Widget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;
  final bool resizeToAvoidBottomInset;

  const AdaptiveScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    final assetConfig = AssetConfig();
    final deviceService = DeviceService();
    
    return Scaffold(
      appBar: appBar as PreferredSizeWidget?,
      body: _buildBodyWithPerformanceOptimizations(),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }

  Widget _buildBodyWithPerformanceOptimizations() {
    final deviceService = DeviceService();
    
    // Wrap with performance optimizations based on device capabilities
    if (!deviceService.canHandleHeavyAnimations()) {
      return PerformanceMode(
        child: body,
      );
    }
    
    return body;
  }
}

// Performance Mode Widget
class PerformanceMode extends StatelessWidget {
  final Widget child;

  const PerformanceMode({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: MediaQuery.withNoTextScaling(
        child: child,
      ),
    );
  }
}

// Adaptive Animation Widget
class AdaptiveAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final bool enable;

  const AdaptiveAnimation({
    super.key,
    required this.child,
    required this.duration,
    this.curve = Curves.easeInOut,
    this.enable = true,
  });

  @override
  State<AdaptiveAnimation> createState() => _AdaptiveAnimationState();
}

class _AdaptiveAnimationState extends State<AdaptiveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    final deviceService = DeviceService();
    final shouldAnimate = widget.enable && deviceService.canHandleHeavyAnimations();
    
    _controller = AnimationController(
      duration: shouldAnimate ? widget.duration : Duration.zero,
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(_animation),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// Responsive Layout Builder
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200 && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= 600 && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

// Device-aware Container
class DeviceAwareContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final Color? color;
  final Decoration? decoration;
  final BoxConstraints? constraints;

  const DeviceAwareContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.decoration,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final assetConfig = AssetConfig();
    final deviceService = DeviceService();
    
    // Adjust constraints based on device type
    BoxConstraints? effectiveConstraints = constraints;
    if (effectiveConstraints == null) {
      final deviceType = deviceService.deviceInfo.deviceType;
      if (deviceType == 'tablet') {
        effectiveConstraints = const BoxConstraints(maxWidth: 800);
      } else if (deviceType == 'large_phone') {
        effectiveConstraints = const BoxConstraints(maxWidth: 600);
      } else {
        effectiveConstraints = const BoxConstraints(maxWidth: 480);
      }
    }

    return Container(
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      color: color,
      decoration: decoration,
      constraints: effectiveConstraints,
      child: child,
    );
  }
}
