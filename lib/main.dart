import 'dart:io';
import 'dart:convert';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'widgets.dart';
import 'utils.dart';

final List<String> imgList = [
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-TanguyFox/main/assets/samples/apple/red_apple.jpeg',
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-TanguyFox/main/assets/samples/banana/pilled_banana.jpeg',
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-TanguyFox/main/assets/samples/mango/mango_on_tree.jpeg',
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-TanguyFox/main/assets/samples/blueberry/myrtille_in_hand.jpeg'
];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fruits Classifier',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(
        title: 'Fruits Classifier',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  String? _resultString;
  Map _resultDict = {
    "label": "Aucun",
    "confidences": [
      {"label": "None", "confidence": 0.0},
      {"label": "None", "confidence": 0.0},
      {"label": "None", "confidence": 0.0}
    ]
  };

  String _latency = "N/A";

  File? imageURI; // Show on image widget on app
  Uint8List? imgBytes; // Store img to be sent for api inference
  bool isClassifying = false;

  String parseResultsIntoString(Map results) {
    return """
    ${results['confidences'][0]['label']} - ${(results['confidences'][0]['confidence'] * 100.0).toStringAsFixed(2)}% \n
    ${results['confidences'][1]['label']} - ${(results['confidences'][1]['confidence'] * 100.0).toStringAsFixed(2)}% \n
    ${results['confidences'][2]['label']} - ${(results['confidences'][2]['confidence'] * 100.0).toStringAsFixed(2)}% """;
  }

  clearInferenceResults() {
    _resultString = "";
    _latency = "N/A";
    _resultDict = {
      "label": "None",
      "confidences": [
        {"label": "None", "confidence": 0.0},
        {"label": "None", "confidence": 0.0},
        {"label": "None", "confidence": 0.0}
      ]
    };
  }

  Widget buildModalBtmSheetItems() {
    return SizedBox(
      height: 120,
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text("Appareil photo"),
            onTap: () async {
              final XFile? pickedFile =
                  await ImagePicker().pickImage(source: ImageSource.camera);

              if (pickedFile != null) {
                // Clear result of previous inference as soon as new image is selected
                setState(() {
                  clearInferenceResults();
                });

                File croppedFile = await cropImage(pickedFile);
                final imgFile = File(croppedFile.path);
                //final imgFile = File(pickedFile.path);

                setState(() {
                  imageURI = imgFile;
                  _btnController.stop();
                  isClassifying = false;
                });
                Navigator.pop(context);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text("Gallerie"),
            onTap: () async {
              final XFile? pickedFile =
                  await ImagePicker().pickImage(source: ImageSource.gallery);

              if (pickedFile != null) {
                // Clear result of previous inference as soon as new image is selected
                setState(() {
                  clearInferenceResults();
                });

                File croppedFile = await cropImage(pickedFile);
                final imgFile = File(croppedFile.path);

                setState(
                  () {
                    imageURI = imgFile;
                    _btnController.stop();
                    isClassifying = false;
                  },
                );
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> imageSliders = imgList
        .map((item) => Container(
              margin: const EdgeInsets.all(5.0),
              child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  child: Stack(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () async {
                          context.loaderOverlay.show();

                          String imgUrl = imgList[imgList.indexOf(item)];

                          final imgFile = await getImage(imgUrl);

                          setState(() {
                            imageURI = imgFile;
                            _btnController.stop();
                            isClassifying = false;
                            clearInferenceResults();
                          });
                          context.loaderOverlay.hide();
                        },
                        child: CachedNetworkImage(
                          imageUrl: item,
                          fit: BoxFit.fill,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                      Positioned(
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(200, 0, 0, 0),
                                Color.fromARGB(0, 0, 0, 0)
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 8.0),
                          child: Text(
                            imgList[imgList.indexOf(item)]
                                .split('/')
                                .reversed
                                .elementAt(1), // get the class name from url
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  )),
            ))
        .toList();

    return LoaderOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          backgroundColor:
              const Color.fromARGB(236, 250, 215, 255).withOpacity(0.5),
        ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              imageURI == null
                  ? SizedBox(
                      height: 200,
                      child: EmptyWidget(
                        image: null,
                        packageImage: PackageImage.Image_3,
                        title: 'Aucune image',
                        subTitle: 'Sélectionnez une image',
                        titleTextStyle: const TextStyle(
                          fontSize: 15,
                          color: Color(0xff9da9c7),
                          fontWeight: FontWeight.w500,
                        ),
                        subtitleTextStyle: const TextStyle(
                          fontSize: 14,
                          color: Color(0xffabb8d6),
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        const Spacer(),
                        Image.file(imageURI!, height: 200, fit: BoxFit.cover),
                        const Spacer(),
                      ],
                    ),
              const SizedBox(
                height: 20,
              ),
              Text("Prédiction (Trouvé en : $_latency ms) :",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              FittedBox(child: buildFruitInfo(_resultDict, context)),
              const SizedBox(height: 30),
              Text("Exemples pour tester :",
                  style: Theme.of(context).textTheme.titleLarge),
              CarouselSlider(
                options: CarouselOptions(
                  height: 180,
                  autoPlay: true,
                  viewportFraction: 0.4,
                  enlargeCenterPage: false,
                  enlargeStrategy: CenterPageEnlargeStrategy.height,
                ),
                items: imageSliders,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: RoundedLoadingButton(
                  width: MediaQuery.of(context).size.width * 0.5,
                  color: Colors.blue,
                  successColor: Colors.green,
                  controller: _btnController,
                  onPressed: isClassifying || imageURI == null
                      ? null // null value disables the button
                      : () async {
                          isClassifying = true;

                          imgBytes = imageURI!.readAsBytesSync();
                          String base64Image =
                              "data:image/png;base64,${base64Encode(imgBytes!)}";

                          try {
                            Stopwatch stopwatch = Stopwatch()..start();
                            final result =
                                await classifyFruitsImage(base64Image);

                            setState(() {
                              _resultString = parseResultsIntoString(result);
                              _resultDict = result;
                              _latency =
                                  stopwatch.elapsed.inMilliseconds.toString();
                            });
                            _btnController.success();
                          } catch (e) {
                            _btnController.error();
                          }
                          isClassifying = false;
                        },
                  // resetAfterDuration: true,
                  // resetDuration: const Duration(seconds: 10),
                  child: const Text('Qu\'est-ce que c\'est ?',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              Row(
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Linkify(
                      onOpen: (link) async {
                        if (await canLaunchUrl(Uri.parse(link.url))) {
                          await launchUrl(Uri.parse(link.url));
                        } else {
                          throw 'Could not launch $link';
                        }
                      },
                      text:
                          "Réalisé par Tanguy RENARD d'après le projet de https://dicksonneoh.com/",
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: const Text("Prendre une photo"),
          icon: const Icon(Icons.camera),
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return buildModalBtmSheetItems();
              },
            );
          },
        ),
      ),
    );
  }
}
