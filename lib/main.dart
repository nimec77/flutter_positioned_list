import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_positioned_list/item_data.dart';
import 'package:flutter_positioned_list/list_item.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

const numberOfItems = 50001;
const minItemHeight = 20.0;
const maxItemHeight = 150.0;
const scrollDuration = Duration(seconds: 2);
const randomMax = 1 << 32;

void main() {
  runApp(PositionedListApp());
}

class PositionedListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Positioned List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PositionedListPage(),
    );
  }
}

class PositionedListPage extends StatefulWidget {
  @override
  _PositionedListPageState createState() => _PositionedListPageState();
}

class _PositionedListPageState extends State<PositionedListPage> {
  final itemScrollController = ItemScrollController();
  final itemPositionsListener = ItemPositionsListener.create();
  final itemsMap = <int, ListItem>{};
  late List<double> itemHeights;
  late List<Color> itemColors;
  bool reversed = false;
  double alignment = 0;

  @override
  void initState() {
    super.initState();
    final heightGenerator = Random(328902348);
    final colorGenerator = Random(42490823);
    itemHeights = List<double>.generate(
        numberOfItems, (_) => heightGenerator.nextDouble() * (maxItemHeight - minItemHeight) + minItemHeight);
    itemColors = List<Color>.generate(numberOfItems, (_) => Color(colorGenerator.nextInt(randomMax)).withOpacity(1));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: OrientationBuilder(
        builder: (context, orientation) => Column(
          children: [
            Expanded(
              child: list(orientation),
            ),
            positionsView,
            Row(
              children: [
                Column(
                  children: [
                    scrollControlButtons,
                    const SizedBox(height: 10),
                    jumpControlButtons,
                    alignmentControl,
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget get alignmentControl => Row(
        children: [
          const Text('Alignment: '),
          SizedBox(
            width: 200,
            child: SliderTheme(
              data: const SliderThemeData(
                showValueIndicator: ShowValueIndicator.always,
              ),
              child: Slider(
                value: alignment,
                label: alignment.toStringAsFixed(2),
                onChanged: (value) => setState(() => alignment = value),
              ),
            ),
          ),
        ],
      );

  Widget list(Orientation orientation) => ScrollablePositionedList.builder(
        itemCount: numberOfItems,
        itemBuilder: (context, index) {
          final listItem = ListItem(itemData: ItemData(index, itemHeights[index], itemColors[index], orientation));
          itemsMap[index] = listItem;
          return listItem;
        },
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        reverse: reversed,
        scrollDirection: orientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
      );

  Widget get positionsView => ValueListenableBuilder<Iterable<ItemPosition>>(
        valueListenable: itemPositionsListener.itemPositions,
        builder: (context, positions, child) {
          int? min, max;
          if (positions.isNotEmpty) {
            final minPos = positions.where((position) => position.itemTrailingEdge > 0).reduce(
                (minPosition, position) =>
                    position.itemTrailingEdge < minPosition.itemTrailingEdge ? position : minPosition);
            min = minPos.index;
            // debugPrint('Min:$minPos');

            final maxPos = positions.where((position) => position.itemLeadingEdge < 1).reduce((maxPosition, position) =>
                position.itemLeadingEdge > maxPosition.itemLeadingEdge ? position : maxPosition);
            // debugPrint('Max:$maxPos');
            max = maxPos.index;
          }
          return Row(
            children: [
              Expanded(child: Text('First Item: ${min ?? ''}')),
              Expanded(child: Text('Last Item: ${max ?? ''}')),
              const Text('Reversed: '),
              Checkbox(
                value: reversed,
                onChanged: (value) => setState(() => reversed = value!),
              ),
            ],
          );
        },
      );

  Widget get scrollControlButtons => Row(
        children: [
          const Text('Scroll to'),
          scrollButton(0),
          scrollButton(5),
          scrollButton(10),
          scrollButton(100),
          scrollButton(1000),
          scrollButton(5000),
        ],
      );

  Widget get jumpControlButtons => Row(
        children: [
          const Text('jump to'),
          jumpButton(0),
          jumpButton(5),
          jumpButton(10),
          jumpButton(100),
          jumpButton(1000),
          jumpButton(5000),
        ],
      );

  final _scrollButtonStyle = ButtonStyle(
    padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 20)),
    minimumSize: MaterialStateProperty.all(Size.zero),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  Widget scrollButton(int value) => TextButton(
        key: ValueKey('Scroll$value'),
        onPressed: () => scrollTo(value),
        style: _scrollButtonStyle,
        child: Text('$value'),
      );

  Widget jumpButton(int value) => TextButton(
        key: ValueKey('Jump$value'),
        onPressed: () => jumpTo(value),
        child: Text('$value'),
      );

  void scrollTo(int index) => itemScrollController.scrollTo(
        index: index,
        duration: scrollDuration,
        curve: Curves.easeInOutCubic,
        alignment: alignment,
      );

  void jumpTo(int index) => itemScrollController.jumpTo(index: index, alignment: alignment);
}
