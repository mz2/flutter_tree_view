import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';

import '../foundation.dart';

/// Signature for a function that creates a widget for a given node, e.g., in a
/// tree.
typedef TreeNodeWidgetBuilder<T> = Widget Function(
  BuildContext context,
  TreeNode<T> node,
);

/// Signature for a function that takes a widget and an animation to apply
/// transitions if needed.
typedef TreeTransitionBuilder = Widget Function(
  Widget child,
  Animation<double>,
);

/// Signature for a function that takes a tree item and returns a [Key].
typedef KeyFactory<T> = Key Function(T item);

/// A simple, fancy and highly customizable hierarchy visualization Widget.
///
/// This widget wraps a [SliverTree] in a [CustomScrollView] with some defaults.
///
/// See also:
///
///  * [SliverTree], which could be used to build more sophisticated scrolling
///    experiences with [CustomScrollView].
class TreeView<T> extends StatelessWidget {
  /// Creates a [TreeView].
  ///
  /// Take a look at [TreeTile] for your [builder].
  const TreeView({
    super.key,
    this.sliverTreeKey,
    required this.delegate,
    required this.builder,
    this.controller,
    this.keyFactory,
    this.transitionBuilder = defaultTransitionBuilder,
    this.itemExtent,
    this.prototypeItem,
    this.padding,
    this.scrollController,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.anchor = 0.0,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  });

  /// The key passed in to [SliverTree].
  ///
  /// Use a [GlobalKey<SliverTreeState<T>>] to get access to the current state
  /// of the tree, the [SliverTreeState] subclasses [TreeControllerMixin]
  /// providing some useful methods like `expand`, `collapse`, `toggle`,
  /// `rebuild`, ..., to manage the state of the tree.
  final Key? sliverTreeKey;

  /// An interface to dynamically manage the state of the tree.
  ///
  /// Subclass [TreeDelegate] and implement the required methods to compose the
  /// tree and its state.
  ///
  /// Checkout [TreeDelegate.fromHandlers] for a simple implementation based on
  /// handler callbacks.
  final TreeDelegate<T> delegate;

  /// Callback used to map your data into widgets.
  ///
  /// The `TreeNode<T> node` parameter contains important information about the
  /// current tree context of the particular [TreeNode.item] that it holds.
  ///
  /// Checkout the [TreeTile] widget.
  final TreeNodeWidgetBuilder<T> builder;

  /// An optional controller that can be used to dynamically update the tree.
  final TreeController<T>? controller;

  /// A helper method to get a [Key] for [item].
  ///
  /// If null, [defaultKeyFactory] will be used to create [ValueKey<T>]'s for
  /// each item of the tree.
  ///
  /// Make sure the key provided for an item is always the same and unique
  /// among other keys, otherwise it could lead to inconsistent tree state.
  final KeyFactory<T>? keyFactory;

  /// Callback used to animate the expansion state change of a branch.
  ///
  /// See also:
  ///
  ///   * [defaultTransitionBuilder] that uses [SizeTransition] with a curve of
  ///     [Curves.decelerate].
  final TreeTransitionBuilder transitionBuilder;

  /// {@macro flutter.widgets.scroll_view.controller}
  final ScrollController? scrollController;

  /// {@macro flutter.widgets.scroll_view.primary}
  final bool? primary;

  /// {@macro flutter.widgets.scroll_view.physics}
  final ScrollPhysics? physics;

  /// {@macro flutter.widgets.scroll_view.shrinkWrap}
  final bool shrinkWrap;

  /// {@macro flutter.widgets.scroll_view.anchor}
  final double anchor;

  /// The amount of space by which to inset the tree contents.
  ///
  /// It defaults to `EdgeInsets.zero`.
  final EdgeInsetsGeometry? padding;

  /// {@macro flutter.rendering.RenderViewportBase.cacheExtent}
  final double? cacheExtent;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// {@macro flutter.widgets.scroll_view.keyboardDismissBehavior}
  ///
  /// The default is [ScrollViewKeyboardDismissBehavior.manual]
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// {@macro flutter.widgets.scrollable.restorationId}
  final String? restorationId;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  /// {@macro flutter.widgets.list_view.itemExtent}
  final double? itemExtent;

  /// {@macro flutter.widgets.list_view.prototypeItem}
  final Widget? prototypeItem;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollDirection: Axis.vertical,
      reverse: false,
      controller: scrollController,
      primary: primary,
      physics: physics,
      shrinkWrap: shrinkWrap,
      anchor: anchor,
      cacheExtent: cacheExtent,
      dragStartBehavior: dragStartBehavior,
      keyboardDismissBehavior: keyboardDismissBehavior,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
      slivers: [
        SliverPadding(
          padding: padding ?? EdgeInsets.zero,
          sliver: SliverTree<T>(
            key: sliverTreeKey,
            delegate: delegate,
            controller: controller,
            builder: builder,
            keyFactory: keyFactory,
            transitionBuilder: transitionBuilder,
            itemExtent: itemExtent,
            prototypeItem: prototypeItem,
          ),
        ),
      ],
    );
  }
}

/// A simple, fancy and highly customizable hierarchy visualization Widget.
///
/// This widget is responsible for working with [TreeController] to display the
/// tree.
///
/// Use inside [CustomScrollView].
///
/// See also:
///
///  * [TreeView], which already covers some of the [CustomScrollView] boilerplate.
class SliverTree<T> extends StatefulWidget {
  /// Creates a [SliverTree].
  const SliverTree({
    super.key,
    required this.delegate,
    required this.builder,
    this.controller,
    this.keyFactory,
    this.transitionBuilder = defaultTransitionBuilder,
    this.itemExtent,
    this.prototypeItem,
  }) : assert(
          itemExtent == null || prototypeItem == null,
          'You can only pass itemExtent or prototypeItem, not both',
        );

  /// An interface to dynamically manage the state of the tree.
  ///
  /// Subclass [TreeDelegate] and implement the required methods to compose the
  /// tree and its state.
  ///
  /// Checkout [TreeDelegate.fromHandlers] for a simple implementation based on
  /// handler callbacks.
  final TreeDelegate<T> delegate;

  /// Callback used to map your data into widgets.
  ///
  /// The `TreeNode<T> node` parameter contains important information about the
  /// current tree context of the particular [TreeNode.item] that it holds.
  final TreeNodeWidgetBuilder<T> builder;

  /// An optional controller that can be used to dynamically update the tree.
  final TreeController<T>? controller;

  /// A helper method to get a [Key] for [item].
  ///
  /// If null, [defaultKeyFactory] will be used to create [ValueKey<T>]'s for
  /// each item of the tree.
  ///
  /// Make sure the key provided for an item is always the same and unique
  /// among other keys, otherwise it could lead to inconsistent tree state.
  final KeyFactory<T>? keyFactory;

  /// Callback used to animate the expansion state change of a branch.
  ///
  /// See also:
  ///
  ///   * [defaultTransitionBuilder] that uses [SizeTransition] with a curve of
  ///     [Curves.decelerate].
  final TreeTransitionBuilder transitionBuilder;

  /// {@macro flutter.widgets.list_view.itemExtent}
  final double? itemExtent;

  /// {@macro flutter.widgets.list_view.prototypeItem}
  final Widget? prototypeItem;

  /// The [SliverTree] state from the closest instance of this class that
  /// encloses the given context.
  ///
  /// If there is no [SliverTree] ancestor widget in the widget tree at the
  /// given context, then this will return null.
  ///
  /// Typical usage is as follows:
  ///
  /// SliverTreeState? treeState = SliverTree.maybeOf<T>(context);
  ///
  /// See also:
  ///
  ///  * [of], which will throw in debug mode if no [SliverTree] ancestor widget
  ///    exists in the widget tree.
  static SliverTreeState<T>? maybeOf<T>(BuildContext context) {
    return context.findAncestorStateOfType<SliverTreeState<T>>();
  }

  /// The [SliverTree] state from the closest instance of this class that
  /// encloses the given context.
  ///
  /// If there is no [SliverTree] ancestor widget in the widget tree at the
  /// given context, then this will throw in debug mode.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// SliverTreeState treeState = SliverTree.of<T>(context);
  /// ```
  ///
  /// See also:
  ///
  ///  * [maybeOf], which will return null if no [SliverTree] ancestor widget
  ///    exists in the widget tree.
  static SliverTreeState<T> of<T>(BuildContext context) {
    final SliverTreeState<T>? instance = maybeOf<T>(context);
    assert(() {
      if (instance == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'SliverTree.of() called with a context that does not contain a '
            'SliverTree.',
          ),
          ErrorDescription(
            'No SliverTree ancestor could be found starting from the context '
            'that was passed to SliverTree.of().',
          ),
          ErrorHint(
            'This can happen when the context provided is from the same '
            'StatefulWidget that built the SliverTree.',
          ),
          context.describeElement('The context used was'),
        ]);
      }
      return true;
    }());
    return instance!;
  }

  @override
  SliverTreeState<T> createState() => SliverTreeState<T>();
}

/// An object that holds the state of a [SliverTree].
///
/// The current [SliverTreeState] instance can be acquired in several ways:
///   - Using a [GlobalKey] in your [SliverTree];
///   - Calling `SliverTree.of<T>(context)` (throws if not found);
///   - Calling `SliverTree.maybeOf<T>(context)` (nullable return);
class SliverTreeState<T> extends State<SliverTree<T>>
    with
        TickerProviderStateMixin<SliverTree<T>>,
        TreeAnimationsStateMixin<SliverTree<T>>,
        TreeControllerStateMixin<T, SliverTree<T>> {
  @override
  TreeDelegate<T> get delegate => widget.delegate;

  late KeyFactory<T> _effectiveKeyFactory;

  @override
  Key keyFactory(T item) => _effectiveKeyFactory(item);

  /// Determines if [Directionality.maybeOf] is set to [TextDirection.rtl].
  bool get isRtl => _isRtl;
  bool _isRtl = false;

  @override
  void initState() {
    // The [TreeControllerStateMixin] uses keyFactory in its [initState] when
    // building the tree for the first time, so it has to be already set.
    _effectiveKeyFactory = widget.keyFactory ?? defaultKeyFactory;
    super.initState();
    widget.controller?.attach(this);
  }

  @override
  void didUpdateWidget(covariant SliverTree<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    _effectiveKeyFactory = widget.keyFactory ?? defaultKeyFactory;

    if (oldWidget.delegate != delegate) {
      rebuild();
    }

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach(this);
      widget.controller?.attach(this);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isRtl = Directionality.maybeOf(context) == TextDirection.rtl;
  }

  @override
  void dispose() {
    widget.controller?.detach(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SliverChildBuilderDelegate delegate = SliverChildBuilderDelegate(
      _builder,
      childCount: treeSize,
    );

    if (widget.itemExtent != null) {
      return SliverFixedExtentList(
        delegate: delegate,
        itemExtent: widget.itemExtent!,
      );
    } else if (widget.prototypeItem != null) {
      return SliverPrototypeExtentList(
        delegate: delegate,
        prototypeItem: widget.prototypeItem!,
      );
    }

    return SliverList(delegate: delegate);
  }

  Widget _builder(BuildContext context, int index) {
    final TreeNode<T> node = nodeAt(index);

    return KeyedSubtree(
      key: node.key,
      child: widget.transitionBuilder(
        widget.builder(context, node),
        findAnimation(node),
      ),
    );
  }
}

/// Default key factory used to get a [Key] for an [item].
///
/// This function creates a [ValueKey<T>] for [item].
///
/// When using this function, make sure [item]'s [operator ==] is consistent.
Key defaultKeyFactory<T>(T item) => ValueKey<T>(item);

/// The default transition builder used by the tree view to animate the
/// expansion state changes of a node.
Widget defaultTransitionBuilder(
  Widget child,
  Animation<double> animation,
) {
  final Animation<double> sizeAnimation = CurvedAnimation(
    curve: Curves.decelerate,
    parent: animation,
  );

  return SizeTransition(
    sizeFactor: sizeAnimation,
    child: child,
  );
}
