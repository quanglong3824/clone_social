import 'package:flutter/material.dart';

/// Animation durations used throughout the app
class AppDurations {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration slower = Duration(milliseconds: 500);
  static const Duration slowest = Duration(milliseconds: 600);
  static const Duration pageTransition = Duration(milliseconds: 350);
}

/// Custom curves for smooth animations
class AppCurves {
  static const Curve smooth = Curves.easeOutCubic;
  static const Curve smoothIn = Curves.easeInCubic;
  static const Curve smoothInOut = Curves.easeInOutCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve spring = Curves.easeOutBack;
  static const Curve decelerate = Curves.decelerate;
  static const Curve overshoot = Curves.easeOutBack;
}

/// Fade in animation widget
class FadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const FadeIn({
    super.key,
    required this.child,
    this.duration = AppDurations.normal,
    this.delay = Duration.zero,
    this.curve = AppCurves.smooth,
  });

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

/// Slide and fade in animation widget
class SlideIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final Offset beginOffset;

  const SlideIn({
    super.key,
    required this.child,
    this.duration = AppDurations.normal,
    this.delay = Duration.zero,
    this.curve = AppCurves.smooth,
    this.beginOffset = const Offset(0, 0.1),
  });

  /// Slide from bottom
  const SlideIn.fromBottom({
    super.key,
    required this.child,
    this.duration = AppDurations.normal,
    this.delay = Duration.zero,
    this.curve = AppCurves.smooth,
  }) : beginOffset = const Offset(0, 0.2);

  /// Slide from top
  const SlideIn.fromTop({
    super.key,
    required this.child,
    this.duration = AppDurations.normal,
    this.delay = Duration.zero,
    this.curve = AppCurves.smooth,
  }) : beginOffset = const Offset(0, -0.2);

  /// Slide from left
  const SlideIn.fromLeft({
    super.key,
    required this.child,
    this.duration = AppDurations.normal,
    this.delay = Duration.zero,
    this.curve = AppCurves.smooth,
  }) : beginOffset = const Offset(-0.2, 0);

  /// Slide from right
  const SlideIn.fromRight({
    super.key,
    required this.child,
    this.duration = AppDurations.normal,
    this.delay = Duration.zero,
    this.curve = AppCurves.smooth,
  }) : beginOffset = const Offset(0.2, 0);

  @override
  State<SlideIn> createState() => _SlideInState();
}

class _SlideInState extends State<SlideIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(curvedAnimation);
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curvedAnimation);
    
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Scale animation widget
class ScaleIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double beginScale;

  const ScaleIn({
    super.key,
    required this.child,
    this.duration = AppDurations.normal,
    this.delay = Duration.zero,
    this.curve = AppCurves.spring,
    this.beginScale = 0.8,
  });

  @override
  State<ScaleIn> createState() => _ScaleInState();
}

class _ScaleInState extends State<ScaleIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    
    _scaleAnimation = Tween<double>(
      begin: widget.beginScale,
      end: 1.0,
    ).animate(curvedAnimation);
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}


/// Staggered list animation - animates children with delay
class StaggeredList extends StatelessWidget {
  final List<Widget> children;
  final Duration itemDuration;
  final Duration staggerDelay;
  final Curve curve;
  final Axis direction;

  const StaggeredList({
    super.key,
    required this.children,
    this.itemDuration = AppDurations.normal,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.curve = AppCurves.smooth,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return direction == Axis.vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildAnimatedChildren(),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: _buildAnimatedChildren(),
          );
  }

  List<Widget> _buildAnimatedChildren() {
    return List.generate(children.length, (index) {
      return SlideIn.fromBottom(
        duration: itemDuration,
        delay: staggerDelay * index,
        curve: curve,
        child: children[index],
      );
    });
  }
}

/// Animated list item for ListView.builder
class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Duration staggerDelay;
  final Curve curve;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.duration = AppDurations.normal,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.curve = AppCurves.smooth,
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(curvedAnimation);

    // Stagger the animation based on index (max 10 items staggered)
    final delay = widget.staggerDelay * (widget.index.clamp(0, 10));
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Tap scale animation - scales down on tap
class TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleDown;
  final Duration duration;

  const TapScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleDown = 0.95,
    this.duration = AppDurations.fast,
  });

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
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
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Pulse animation for attention
class Pulse extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final bool repeat;

  const Pulse({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 0.95,
    this.maxScale = 1.05,
    this.repeat = true,
  });

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

/// Shake animation for errors
class Shake extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double offset;
  final VoidCallback? onComplete;

  const Shake({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.offset = 10.0,
    this.onComplete,
  });

  @override
  State<Shake> createState() => ShakeState();
}

class ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  void shake() {
    _controller.forward(from: 0);
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
        final sineValue = _animation.value * 3.14159 * 4;
        return Transform.translate(
          offset: Offset(widget.offset * (sineValue == 0 ? 0 : (sineValue / sineValue.abs()) * (1 - _animation.value) * 
              (sineValue.abs() < 0.01 ? 0 : (sineValue > 0 ? 1 : -1) * 
              (_animation.value < 0.5 ? _animation.value * 2 : (1 - _animation.value) * 2))), 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Bounce animation
class Bounce extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double height;

  const Bounce({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.height = 10.0,
  });

  @override
  State<Bounce> createState() => _BounceState();
}

class _BounceState extends State<Bounce> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0, end: widget.height).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
        return Transform.translate(
          offset: Offset(0, -_animation.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Animated counter for numbers
class AnimatedCounter extends StatelessWidget {
  final int value;
  final Duration duration;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = AppDurations.normal,
    this.style,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      builder: (context, value, child) {
        return Text(
          '${prefix ?? ''}$value${suffix ?? ''}',
          style: style,
        );
      },
    );
  }
}

/// Smooth page route transition
class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final RouteSettings? routeSettings;

  SmoothPageRoute({
    required this.page,
    this.routeSettings,
  }) : super(
          settings: routeSettings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AppDurations.pageTransition,
          reverseTransitionDuration: AppDurations.normal,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: AppCurves.smooth,
            );
            
            return FadeTransition(
              opacity: curvedAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(curvedAnimation),
                child: child,
              ),
            );
          },
        );
}

/// Smooth bottom sheet transition
class SmoothBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    bool isScrollControlled = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor,
      elevation: elevation,
      isScrollControlled: isScrollControlled,
      shape: shape ?? const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      transitionAnimationController: AnimationController(
        duration: AppDurations.normal,
        vsync: Navigator.of(context),
      ),
      builder: builder,
    );
  }
}

/// Hero animation wrapper with smooth transition
class SmoothHero extends StatelessWidget {
  final String tag;
  final Widget child;

  const SmoothHero({
    super.key,
    required this.tag,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return Material(
              color: Colors.transparent,
              child: child,
            );
          },
        );
      },
      child: child,
    );
  }
}
