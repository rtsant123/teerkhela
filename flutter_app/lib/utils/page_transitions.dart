import 'package:flutter/material.dart';

/// Professional page transition utilities
/// Provides consistent animations across the app

/// Transition duration constant
const Duration _kTransitionDuration = Duration(milliseconds: 300);

/// Slide transition from right to left
class SlideRightRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideRightRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: _kTransitionDuration,
          reverseTransitionDuration: _kTransitionDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}

/// Slide transition from bottom to top
class SlideUpRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideUpRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: _kTransitionDuration,
          reverseTransitionDuration: _kTransitionDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}

/// Fade transition
class FadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: _kTransitionDuration,
          reverseTransitionDuration: _kTransitionDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOut;

            var tween = Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: curve),
            );

            return FadeTransition(
              opacity: animation.drive(tween),
              child: child,
            );
          },
        );
}

/// Scale transition (for modals/dialogs)
class ScaleRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  ScaleRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: _kTransitionDuration,
          reverseTransitionDuration: _kTransitionDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOutCubic;

            var scaleTween = Tween(begin: 0.9, end: 1.0).chain(
              CurveTween(curve: curve),
            );

            var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: curve),
            );

            return ScaleTransition(
              scale: animation.drive(scaleTween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
        );
}

/// Combined slide and fade transition
class SlideFadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Offset beginOffset;

  SlideFadeRoute({
    required this.page,
    this.beginOffset = const Offset(1.0, 0.0),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: _kTransitionDuration,
          reverseTransitionDuration: _kTransitionDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var slideTween = Tween(begin: beginOffset, end: end).chain(
              CurveTween(curve: curve),
            );

            var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(slideTween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
        );
}

/// Extension methods for easy navigation with transitions
extension PageTransitionNavigation on BuildContext {
  /// Navigate with slide from right
  Future<T?> slideToPage<T>(Widget page) {
    return Navigator.push<T>(
      this,
      SlideRightRoute<T>(page: page),
    );
  }

  /// Navigate with slide from bottom
  Future<T?> slideUpToPage<T>(Widget page) {
    return Navigator.push<T>(
      this,
      SlideUpRoute<T>(page: page),
    );
  }

  /// Navigate with fade
  Future<T?> fadeToPage<T>(Widget page) {
    return Navigator.push<T>(
      this,
      FadeRoute<T>(page: page),
    );
  }

  /// Navigate with scale (for modals)
  Future<T?> scaleToPage<T>(Widget page) {
    return Navigator.push<T>(
      this,
      ScaleRoute<T>(page: page),
    );
  }

  /// Navigate with slide and fade
  Future<T?> slideFadeToPage<T>(Widget page, {Offset? beginOffset}) {
    return Navigator.push<T>(
      this,
      SlideFadeRoute<T>(
        page: page,
        beginOffset: beginOffset ?? const Offset(1.0, 0.0),
      ),
    );
  }
}

/// Animated button scale effect on tap
class AnimatedScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double scaleFactor;
  final Duration duration;

  const AnimatedScaleButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.scaleFactor = 0.95,
    this.duration = const Duration(milliseconds: 100),
  }) : super(key: key);

  @override
  State<AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<AnimatedScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _onTapDown : null,
      onTapUp: widget.onPressed != null ? _onTapUp : null,
      onTapCancel: widget.onPressed != null ? _onTapCancel : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Animated card with elevation change on tap
class AnimatedTapCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  const AnimatedTapCard({
    Key? key,
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 200),
    this.borderRadius,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<AnimatedTapCard> createState() => _AnimatedTapCardState();
}

class _AnimatedTapCardState extends State<AnimatedTapCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              elevation: _elevationAnimation.value,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              color: widget.backgroundColor ?? Colors.white,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Animated like button with scale animation
class AnimatedLikeButton extends StatefulWidget {
  final bool isLiked;
  final VoidCallback onTap;
  final Color likedColor;
  final Color unlikedColor;
  final double size;

  const AnimatedLikeButton({
    Key? key,
    required this.isLiked,
    required this.onTap,
    this.likedColor = Colors.red,
    this.unlikedColor = Colors.grey,
    this.size = 24.0,
  }) : super(key: key);

  @override
  State<AnimatedLikeButton> createState() => _AnimatedLikeButtonState();
}

class _AnimatedLikeButtonState extends State<AnimatedLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Icon(
          widget.isLiked ? Icons.favorite : Icons.favorite_border,
          color: widget.isLiked ? widget.likedColor : widget.unlikedColor,
          size: widget.size,
        ),
      ),
    );
  }
}
