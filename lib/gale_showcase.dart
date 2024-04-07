import 'package:flutter/material.dart';
import 'package:gale/core/base.dart';
import 'package:gale/core/widget_base.dart';

class _GaleMainAxisAlignment extends GalePredicate {
  @override
  final MainAxisAlignment value;

  _GaleMainAxisAlignment([this.value = MainAxisAlignment.start]) : super(value);
}

class _GaleCrossAxisAlignment extends GalePredicate {
  @override
  final CrossAxisAlignment value;

  _GaleCrossAxisAlignment([this.value = CrossAxisAlignment.start]) : super(value);
}

class GaleMainAxisAlignment {
  get start => _GaleMainAxisAlignment(MainAxisAlignment.start);
  get end => _GaleMainAxisAlignment(MainAxisAlignment.end);
  get center => _GaleMainAxisAlignment(MainAxisAlignment.center);
  get spaceAround => _GaleMainAxisAlignment(MainAxisAlignment.spaceAround);
  get spaceBetween => _GaleMainAxisAlignment(MainAxisAlignment.spaceBetween);
  get spaceEvenly => _GaleMainAxisAlignment(MainAxisAlignment.spaceEvenly);
}

class GaleCrossAxisAlignment {
  get start => _GaleCrossAxisAlignment(CrossAxisAlignment.start);
  get end => _GaleCrossAxisAlignment(CrossAxisAlignment.end);
  get center => _GaleCrossAxisAlignment(CrossAxisAlignment.center);
  get stretch => _GaleCrossAxisAlignment(CrossAxisAlignment.stretch);
  get baseline => _GaleCrossAxisAlignment(CrossAxisAlignment.baseline);
}

class GaleMainAxisSize extends GalePredicate {
  @override
  final MainAxisSize value;

  GaleMainAxisSize([this.value = MainAxisSize.max]) : super(value);
}

// extension FontSizeExtension on IGaleFontSize {
//   double get fontSize =>
//       interpretedPredicates.lastWhere((e) => e is _GaleFontSize, orElse: () => _GaleFontSize()).value;
// }
//
// extension FontWeightExtension on IGaleFontWeight {
//   FontWeight get fontWeight =>
//       interpretedPredicates.lastWhere((e) => e is _GaleFontWeight, orElse: () => _GaleFontWeight()).value;
// }
abstract class IGaleMainAxisAlignment extends IGaleWidget {}

abstract class IGaleCrossAxisAlignment extends IGaleWidget {}

abstract class IGaleMainAxisSize extends IGaleWidget {}

extension MainAxisAlignmentExtension on IGaleMainAxisAlignment {
  MainAxisAlignment get mainAxisAlignment =>
      interpretedPredicates.lastWhere((e) => e is _GaleMainAxisAlignment, orElse: () => _GaleMainAxisAlignment()).value;
}

extension CrossAxisAlignmentExtension on IGaleCrossAxisAlignment {
  CrossAxisAlignment get crossAxisAlignment => interpretedPredicates
      .lastWhere((e) => e is _GaleCrossAxisAlignment, orElse: () => _GaleCrossAxisAlignment())
      .value;
}

extension MainAxisSizeExtension on IGaleMainAxisSize {
  MainAxisSize get mainAxisSize =>
      interpretedPredicates.lastWhere((e) => e is GaleMainAxisSize, orElse: () => GaleMainAxisSize()).value;
}

class _GaleFontWeight extends GalePredicate {
  @override
  final FontWeight value;

  _GaleFontWeight([this.value = FontWeight.normal]) : super(value);
}

class GaleVStackStyle extends GaleWidgetStyle {
  const GaleVStackStyle();

  GaleMainAxisAlignment get vertical => GaleMainAxisAlignment();
  GaleCrossAxisAlignment get horizontal => GaleCrossAxisAlignment();

  get shrink => GaleMainAxisSize(MainAxisSize.min);
}

class GaleVStack extends GaleWidget<GaleVStackStyle>
    implements IGaleMainAxisAlignment, IGaleCrossAxisAlignment, IGaleMainAxisSize {
  @override
  late GaleWidgetPredicateGenerator<GaleVStackStyle>? predicates;

  @override
  get interpretedPredicates => predicates != null && style != null ? predicates!(style!) : [];

  get verticalAlign => mainAxisAlignment;
  get horizontalAlign => crossAxisAlignment;

  @override
  GaleVStackStyle? style;

  List<Widget> children;

  GaleVStack({this.predicates, this.style = const GaleVStackStyle(), this.children = const [], super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}
