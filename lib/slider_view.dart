import 'dart:async';

import 'package:flutter/material.dart';
import 'package:widget_carousel/helpers.dart';
import 'package:widget_carousel/indicator.dart';

/// [IndicatorAlign] enum specifying alignment of indicator
enum IndicatorAlign {
  top,
  bottom,
}

/// [WidgetCarousel] is a [StatefulWidget] that handles display of items
class WidgetCarousel extends StatefulWidget {
  final List<Widget> items;

  /// [items] --- List of widgets to be looped through
  final num viewportFraction;
  final num initialPage;
  final double aspectRatio;
  final double? height;
  final PageController? pageController;
  final num realPage;
  final bool autoPlay;
  final Duration autoPlayDuration;
  final Curve autoPlayCurve;
  final Duration interval;
  final bool reverse;
  final Function updateCallback;
  final bool distortion;
  final IndicatorAlign align;
  final EdgeInsets padding;
  final double indicatorWidth;
  final Color indicatorBackColor;
  final Color indicatorColor;

  WidgetCarousel({
    required this.items,
    this.viewportFraction: 1.0,
    this.initialPage: 0,
    this.aspectRatio: 16 / 9,
    this.height,
    this.realPage: 10000,
    this.autoPlay: false,
    this.interval: const Duration(seconds: 8),
    this.reverse: false,
    this.autoPlayCurve: Curves.fastOutSlowIn,
    this.autoPlayDuration: const Duration(milliseconds: 800),
    required this.updateCallback,
    this.distortion: true,
    this.align = IndicatorAlign.bottom,
    this.padding = const EdgeInsets.only(bottom: 0.0),
    this.indicatorWidth = 6,
    this.indicatorBackColor = Colors.white,
    this.indicatorColor = Colors.black,
  }) : pageController = new PageController(
          viewportFraction: viewportFraction.toDouble(),
          initialPage: realPage.toInt() + initialPage.toInt(),
        );

  @override
  _WidgetCarouselState createState() {
    return new _WidgetCarouselState();
  }

  /// [nextPage] function to display next widget
  nextPage({Duration? duration, Curve? curve}) {
    return pageController!.nextPage(duration: duration!, curve: curve!);
  }

  /// [previousPage] function to display previous widget
  previousPage({Duration? duration, Curve? curve}) {
    return pageController!.previousPage(duration: duration!, curve: curve!);
  }

  jumpToPage(int page) {
    final index = Helpers.getRealIndex(
            pageController!.page!.toInt(), realPage, items.length)
        .toInt();
    return pageController!
        .jumpToPage(pageController!.page!.toInt() + page - index);
  }

  animateToPage(int page, {Duration? duration, Curve? curve}) {
    final index = Helpers.getRealIndex(
            pageController!.page!.toInt(), realPage, items.length)
        .toInt();
    return pageController!.animateToPage(
        pageController!.page!.toInt() + page - index,
        duration: duration!,
        curve: curve!);
  }
}

class _WidgetCarouselState extends State<WidgetCarousel> with TickerProviderStateMixin {
  int? currentPage;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    currentPage = widget.initialPage.toInt();
    if (widget.autoPlay) {
      timer = new Timer.periodic(widget.interval, (_) {
        widget.pageController!.nextPage(
            duration: widget.autoPlayDuration, curve: widget.autoPlayCurve);
      });
    }
    widget.pageController!.addListener(onScroll);
  }

  onScroll() {
    setState(() {});
  }

  getWrapper(Widget child) {
    if (widget.height != null) {
      return Container(height: widget.height, child: child);
    } else {
      return AspectRatio(aspectRatio: widget.aspectRatio, child: child);
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    widget.pageController!.removeListener(onScroll);
  }

  @override
  Widget build(BuildContext context) {
    Widget indicator = Container(
      child: PageIndicator(
        controller: widget.pageController!,
        length: widget.items.length,
        realPage: widget.realPage.toInt(),
        indicatorBackColor: widget.indicatorBackColor,
        indicatorColor: widget.indicatorColor,
        indicatorSpace: widget.indicatorWidth / 2,
        indicatorWidth: widget.indicatorWidth,
      ),
    );

    var align = widget.align;

    if (align == IndicatorAlign.bottom) {
      indicator = Positioned(
        left: 0.0,
        right: 0.0,
        height: widget.indicatorWidth,
        bottom: widget.padding.bottom,
        child: indicator,
      );
    } else if (align == IndicatorAlign.top) {
      indicator = Positioned(
        left: 0.0,
        right: 0.0,
        height: widget.indicatorWidth,
        top: widget.padding.top,
        child: indicator,
      );
    }

    return Stack(
      children: <Widget>[
        NotificationListener<ScrollNotification>(
          child: Container(
            height: widget.height ??
                MediaQuery.of(context).size.width * (1 / widget.aspectRatio),
            child: PageView.builder(
              onPageChanged: (int index) {
                currentPage = Helpers.getRealIndex(
                    index, widget.realPage.toInt(), widget.items.length);
                widget.updateCallback(currentPage);
              },
              controller: widget.pageController,
              reverse: widget.reverse,
              itemBuilder: (BuildContext context, int i) {
                final int index = Helpers.getRealIndex(
                    i, widget.realPage.toInt(), widget.items.length);
                return AnimatedBuilder(
                    animation: widget.pageController!,
                    builder: (BuildContext context, child) {
                      if (!widget
                          .pageController!.position.hasContentDimensions) {
                        Future.delayed(Duration(microseconds: 1), () {
                          setState(() {});
                        });
                        return Container();
                      }
                      double value = widget.pageController!.page! - i;
                      value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);

                      final double height = widget.height ??
                          MediaQuery.of(context).size.width *
                              (1 / widget.aspectRatio);
                      final double distortionValue = widget.distortion
                          ? Curves.easeOut.transform(value)
                          : 1.0;

                      return Center(
                          child: SizedBox(
                              height: distortionValue * height, child: child));
                    },
                    child: widget.items[index]);
              },
            ),
          ),
          onNotification: _onScroll,
        ),
        indicator,
      ],
    );
  }

  bool _onScroll(ScrollNotification notification) {
    setState(() {});
    return false;
  }
}
