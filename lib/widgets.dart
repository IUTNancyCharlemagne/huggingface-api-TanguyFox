import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

Widget buildPercentIndicator(String className, double classConfidence) {
  //List<dynamic> fruitsInfo
  /* final fruitInfo = fruitsInfo.firstWhere((fruit) => fruit['label'] == className);
    return Text("${fruitInfo['name']} (${(classConfidence * 100).toStringAsFixed(2)}%)");
 */
  return LinearPercentIndicator(
    width: 200.0,
    lineHeight: 18.0,
    percent: classConfidence,
    center: Text(
      "${(classConfidence * 100.0).toStringAsFixed(2)} %",
      style: const TextStyle(fontSize: 12.0),
    ),
    trailing: Text(className),
    leading: const Icon(Icons.arrow_forward_ios),
    // linearStrokeCap: LinearStrokeCap.roundAll,
    backgroundColor: Colors.grey,
    progressColor: Colors.blue,
    animation: true,
  );
}

Widget buildResultsIndicators(Map resultsDict) {
  //List<dynamic> fruitsInfo
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildPercentIndicator(resultsDict['confidences'][0]['label'],
          (resultsDict['confidences'][0]['confidence'])),
      /*  buildPercentIndicator(resultsDict['confidences'][1]['label'],
          (resultsDict['confidences'][1]['confidence'])),
      buildPercentIndicator(resultsDict['confidences'][2]['label'],
          (resultsDict['confidences'][2]['confidence'])) */
    ],
  );
}

Future<dynamic> getFruitInfo(String label) async {
  final String data = await rootBundle.loadString('assets/data/data.json');
  final List<dynamic> fruitsInfo = json.decode(data);
  return fruitsInfo.firstWhere((fruit) => fruit['label'] == label);
}

Widget buildFruitInfo(Map resultsDict, BuildContext context) {
  return FutureBuilder(
    future: getFruitInfo(resultsDict['confidences'][0]['label']),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        double confidence = resultsDict['confidences'][0]['confidence'];
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "Je pense à ${(confidence * 100).toStringAsFixed(0)}% que c'est un(e) ${snapshot.data['name']}",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.sticky_note_2),
              iconSize: 25,
              color: const Color.fromARGB(255, 214, 128, 240).withOpacity(0.5),
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  CircleBorder(
                    side: BorderSide(
                      color: Colors.blueGrey.withOpacity(0.8),
                    ),
                  ),
                ),
                backgroundColor:
                    MaterialStateProperty.all(Colors.blueGrey.withOpacity(0.1)),
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) =>
                        buildPopUpInfo(snapshot.data, context));
              },
            )
          ],
        );
      } else {
        return const Text("Aucune données trouvées");
      }
    },
  );
}

Widget buildPopUpInfo(dynamic infos, BuildContext context) {
  return AlertDialog(
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 50.0, vertical: 20.0),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(
              Icons.sticky_note_2_rounded,
              color: Color.fromARGB(255, 214, 128, 240),
              size: 30,
            ),
            const SizedBox(width: 8.0),
            Text(
              infos['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    ),
    iconPadding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    content: SingleChildScrollView(
      child: FittedBox(
        fit: BoxFit.fill,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildInfoRow("Comestible", infos['edible'], 115),
            const SizedBox(height: 10),
            buildInfoRow("Apport nutritionnels", infos['health'], 58),
            const SizedBox(height: 10),
            buildInfoRow("Calories", infos['calorie'], 137),
            const SizedBox(height: 10),
            buildInfoRow("Famille", infos['family'], 142),
            const SizedBox(height: 10),
            buildInfoRow("Période de récolte", infos['harvest'], 70),
            const SizedBox(height: 10),
            buildInfoRow("Climat préférentiel", infos['climate'], 67),
            const SizedBox(height: 10),
            buildInfoRow("Plant :", infos['plant'], 148),
            const SizedBox(height: 10),
            buildInfoRow("Pays d'origine", infos['origin'], 99)
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Fermer'),
      ),
    ],
  );
}

Widget buildInfoRow(String title, String value, double spacing) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(width: spacing),
      Text(value),
    ],
  );
}
