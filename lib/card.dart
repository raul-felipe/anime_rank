import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';

import 'data_function.dart';

class CardItemBuild extends StatefulWidget {
  final int index;
  final List<dynamic> topFive;

  const CardItemBuild({super.key, required this.index, required this.topFive});

  @override
  State<StatefulWidget> createState() => _CardItemBuildState();
}

class _CardItemBuildState extends State<CardItemBuild> {
  int currentSliderValue = 1;

  Widget togglePlayer(String op, String ed, Map animeInfo) {
    return AnimatedToggleSwitch<int>.rolling(
      current: currentSliderValue,
      innerGradient:
          LinearGradient(colors: [Colors.red[100]!, Colors.blue[100]!]),
      borderColor: Colors.transparent,
      indicatorColor: Colors.white,
      values: const [0, 1, 2],
      onChanged: (i) => setState(() {
        currentSliderValue = i;
        switch (i) {
          case 0:
            DataRetrieve.cardColorStops = [0, 0.5, 0.95, 1];
            DataRetrieve.playSong(op,animeInfo);
            break;
          case 2:
            DataRetrieve.cardColorStops = [0, 0.05, 0.5, 1];
            DataRetrieve.playSong(ed,animeInfo);
            break;
          default:
            DataRetrieve.cardColorStops = [0, 0.01, 0.99, 1];
            DataRetrieve.player.pause();
            break;
        }
      }),
      iconBuilder: (value, size, foreground) {
        switch (value) {
          case 0:
            return const Center(
                child: Text(
              'OP',
              style: TextStyle(fontWeight: FontWeight.bold),
            ));
          case 1:
            return const Center(child: Icon(Icons.pause));
          case 2:
            return const Center(
                child: Text(
              'ED',
              style: TextStyle(fontWeight: FontWeight.bold),
            ));
          default:
            return const Text('');
        }
      },
    );
  }
  Widget cardAnimeListItem(int index, List topFive) {
    return Card(
        child: AnimatedContainer(
            duration: const Duration(seconds: 1),
            curve: Curves.fastOutSlowIn,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.red[100]!,
                Colors.white,
                Colors.white,
                Colors.blue[100]!
              ],
              stops: DataRetrieve.cardColorStops,
            )),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child:
                            Image.network(topFive[index]['picture']['medium']),
                      )),
                  const SizedBox(height: 30, child: VerticalDivider()),
                  Flexible(
                    flex: 8,
                    child: Column(
                      children: [
                        Text(
                          topFive[index]['title'],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        Text(
                          topFive[index]['ja_title'],
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Divider(),
                        togglePlayer(
                            topFive[index]['op'], topFive[index]['ed'],topFive[index]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30, child: VerticalDivider()),
                  Flexible(
                      flex: 1,
                      child: Column(
                        children: [
                          const Icon(Icons.star),
                          Text(topFive[index]['score'].toString(),
                              style: const TextStyle(fontSize: 10))
                        ],
                      ))
                ],
              ),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return cardAnimeListItem(widget.index, widget.topFive);
  }
}
