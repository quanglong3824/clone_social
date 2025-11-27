import 'package:flutter/material.dart';
import '../../domain/entities/post_entity.dart';

/// A widget that displays a reaction picker with 6 reaction options.
/// Shows on long press with animated appearance.
class ReactionPicker extends StatefulWidget {
  final ReactionType? currentReaction;
  final void Function(ReactionType reaction) onReactionSelected;
  final VoidCallback? onDismiss;

  const ReactionPicker({
    super.key,
    this.currentReaction,
    required this.onReactionSelected,
    this.onDismiss,
  });

  @override
  State<ReactionPicker> createState() => _ReactionPickerState();
}

class _ReactionPickerState extends State<ReactionPicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: ReactionType.values.asMap().entries.map((entry) {
            final index = entry.key;
            final reaction = entry.value;
            final isSelected = widget.currentReaction == reaction;
            final isHovered = _hoveredIndex == index;

            return _ReactionItem(
              reaction: reaction,
              isSelected: isSelected,
              isHovered: isHovered,
              delay: index * 50,
              onTap: () => widget.onReactionSelected(reaction),
              onHover: (hovered) {
                setState(() {
                  _hoveredIndex = hovered ? index : null;
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ReactionItem extends StatefulWidget {
  final ReactionType reaction;
  final bool isSelected;
  final bool isHovered;
  final int delay;
  final VoidCallback onTap;
  final void Function(bool hovered) onHover;

  const _ReactionItem({
    required this.reaction,
    required this.isSelected,
    required this.isHovered,
    required this.delay,
    required this.onTap,
    required this.onHover,
  });

  @override
  State<_ReactionItem> createState() => _ReactionItemState();
}

class _ReactionItemState extends State<_ReactionItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOut,
    ));

    // Delayed entrance animation
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _bounceController.forward();
      }
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.isHovered ? 1.4 : (widget.isSelected ? 1.2 : 1.0);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => widget.onHover(true),
      onTapUp: (_) => widget.onHover(false),
      onTapCancel: () => widget.onHover(false),
      child: MouseRegion(
        onEnter: (_) => widget.onHover(true),
        onExit: (_) => widget.onHover(false),
        child: AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _bounceAnimation.value * scale,
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  transform: Matrix4.translationValues(
                    0,
                    widget.isHovered ? -8 : 0,
                    0,
                  ),
                  child: Text(
                    widget.reaction.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                if (widget.isHovered)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: widget.isHovered ? 1.0 : 0.0,
                    child: Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.reaction.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A button that shows the reaction picker on long press
class ReactionButton extends StatefulWidget {
  final ReactionType? currentReaction;
  final void Function(ReactionType? reaction) onReactionChanged;
  final Widget child;

  const ReactionButton({
    super.key,
    this.currentReaction,
    required this.onReactionChanged,
    required this.child,
  });

  @override
  State<ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<ReactionButton> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  void _showReactionPicker() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Dismiss area
          Positioned.fill(
            child: GestureDetector(
              onTap: _hideReactionPicker,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),
          // Reaction picker
          Positioned(
            width: 280,
            child: CompositedTransformFollower(
              link: _layerLink,
              targetAnchor: Alignment.topCenter,
              followerAnchor: Alignment.bottomCenter,
              offset: const Offset(0, -8),
              child: ReactionPicker(
                currentReaction: widget.currentReaction,
                onReactionSelected: (reaction) {
                  _hideReactionPicker();
                  widget.onReactionChanged(reaction);
                },
                onDismiss: _hideReactionPicker,
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideReactionPicker() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _handleTap() {
    // Toggle like on tap
    if (widget.currentReaction != null) {
      widget.onReactionChanged(null);
    } else {
      widget.onReactionChanged(ReactionType.like);
    }
  }

  @override
  void dispose() {
    _hideReactionPicker();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _handleTap,
        onLongPress: _showReactionPicker,
        child: widget.child,
      ),
    );
  }
}
