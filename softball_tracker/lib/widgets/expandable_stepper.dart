import 'package:bulleted_list/bulleted_list.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:softball_tracker/utils/constants.dart';

import '../utils/expansion_tile.dart';

class ExpandableStepper extends StatefulWidget {
  final List<ExpansionTileContent> tiles;
  final Function? exitFunction;

  const ExpandableStepper({super.key, required this.tiles, required this.exitFunction});

  @override
  State<StatefulWidget> createState() => _ExpandableStepperState();
}

class _ExpandableStepperState
    extends State<ExpandableStepper> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void openStep(int stepNumber, List<ExpansionTileController> controllers) {
    for (var i = 0; i < controllers.length; i++) {
      if (stepNumber == i) {
        controllers[i].expand();
      } else {
        controllers[i].collapse();
      }
    }
  }

  List<Widget> buildExpansionTiles(){
    List<Widget> steppingTiles = [];
    List<ExpansionTileController> controllers = [];
    for(var i = 0; i < widget.tiles.length; i++){
      ExpansionTileController newController = ExpansionTileController();
      controllers.add(newController);
      steppingTiles.add(
          ExpansionTile(
              initiallyExpanded: i == 0,
              controller: newController,
              onExpansionChanged: (expanded) {
                if (expanded) {
                  openStep(i, controllers);
                }
              },
              title: widget.tiles[i].title,
              subtitle: widget.tiles[i].subtitle,
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 20,
                    children: [
                      widget.tiles[i].content,
                      Flex(
                          mainAxisAlignment: MainAxisAlignment.center,
                          direction: Axis.horizontal,
                          children: [
                            Row(spacing: 20, children: [
                              i == 0 ? Container() : OutlinedButton(
                                style: OutlinedButton.styleFrom(minimumSize: const Size(100, 50)),
                                onPressed: () {
                                  openStep(i - 1, controllers);
                                },
                                child: const Text(style: TextStyle(fontSize: 25), 'Back'),
                              ),
                              (i == widget.tiles.length - 1 ?
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(minimumSize: const Size(100, 50)),
                                onPressed: () {widget.exitFunction!();},
                                child: const Text(style: TextStyle(fontSize: 25), 'Done'),
                              ) :
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(minimumSize: const Size(100, 50)),
                                onPressed: () {
                                  openStep(i + 1, controllers);
                                },
                                child: const Text(style: TextStyle(fontSize: 25), 'Next'),
                              )),
                            ])
                          ])
                    ]),
              ]));
    }
    return steppingTiles;
  }

  @override
  Widget build(BuildContext context) {

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [...buildExpansionTiles()]
    );
  }
}
