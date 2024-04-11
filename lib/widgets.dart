import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            IconButton(
              icon: const Icon(Icons.info),
              iconSize: 20,
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
    title: Text(infos['name']),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              const Text(
                'Période de récolte :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(infos['harvest']),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Climat préférentiel :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(infos['climate']),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Plant :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(infos['plant']),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Pays d'origine :",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(infos['origin']),
            ],
          ),
        ],
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
