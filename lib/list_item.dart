import 'package:flutter/material.dart';
import 'package:flutter_positioned_list/item_data.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ListItem extends StatefulWidget {
  final ItemData itemData;

  const ListItem({Key? key, required this.itemData}) : super(key: key);

  @override
  _ListItemState createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  void _afterLayout(_) {
    final renderObject = context.findRenderObject();
    if (renderObject != null) {
      final renderBox = renderObject as RenderBox;
      final size = renderBox.size;
      final position = renderBox.localToGlobal(Offset.zero);
      debugPrint('Item${widget.itemData.index} size:$size, position:$position');
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: (visibilityInfo) {
        if (widget.itemData.index == 0) {
          debugPrint(visibilityInfo.toString());
        }
      },
      child: SizedBox(
        height: widget.itemData.orientation == Orientation.portrait ? widget.itemData.height : null,
        width: widget.itemData.orientation == Orientation.landscape ? widget.itemData.height : null,
        child: Container(
          color: widget.itemData.color,
          child: Center(
            child: Text('Item ${widget.itemData.index}'),
          ),
        ),
      ),
    );
  }
}
