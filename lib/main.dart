/*
color
1. Outer Space Crayola #283d3b
2. Skobeloff #197278
3. Champagne Pink #edddd4
4. International Orange Golden Gate Bridge #c44536
5. Liver Organ #772e25

ads
testID->realID

icon

localization

 */

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:native_pdf_renderer/native_pdf_renderer.dart' as render;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GrannyStatePic',
      theme: ThemeData(
        primarySwatch: createMaterialColor(Color(0xff772e25)),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final AdRequest request = AdRequest();

  BannerAd? _anchoredBanner;
  bool _loadingAnchoredBanner = false;

  Future<void> _createAnchoredBanner(BuildContext context) async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      MediaQuery.of(context).size.width.truncate(),
    );

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    final BannerAd banner = BannerAd(
      size: size,
      request: request,
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' //testID !!!
          : 'ca-app-pub-3940256099942544/6300978111', //testID !!!
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$BannerAd loaded.');
          setState(() {
            _anchoredBanner = ad as BannerAd?;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$BannerAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
      ),
    );
    return banner.load();
  }

  final BannerAdListener listener = BannerAdListener(
    // Called when an ad is successfully received.
    onAdLoaded: (Ad ad) => print('Ad loaded.'),
    // Called when an ad request failed.
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      // Dispose the ad here to free resources.
      ad.dispose();
      print('Ad failed to load: $error');
    },
    // Called when an ad opens an overlay that covers the screen.
    onAdOpened: (Ad ad) => print('Ad opened.'),
    // Called when an ad removes an overlay that covers the screen.
    onAdClosed: (Ad ad) => print('Ad closed.'),
    // Called when an impression occurs on the ad.
    onAdImpression: (Ad ad) => print('Ad impression.'),
  );

  final _formKey = GlobalKey<FormBuilderState>();

  bool isVideo = false;

  final ImagePicker _picker = ImagePicker();

  String? tempPath;
  String? appDocPath;

  void requestTempDirectory() async {
    Directory tempDirectory = await getTemporaryDirectory();
    tempPath = tempDirectory.path;
  }

  @override
  void initState() {
    super.initState();
    requestTempDirectory();
  }

  @override
  void dispose() {
    super.dispose();
    _anchoredBanner?.dispose();
  }

  List<String> imagePaths = [];
  String state1 = '';
  String state2 = '';
  String state3 = '';
  String state4 = '';
  String state5 = '';
  String state6 = '';
  String state7 = '';
  String shareText = '';

  @override
  Widget build(BuildContext context) {
    shareText = 'Nutrition & Weight Maintenance\n' +
        state1 +
        '\n\nMood & Activity Level\n' +
        state2;
    if (state3 != '')
      shareText = shareText + '\n\nAbility to Walk & Move\n' + state3;
    if (state4 != '')
      shareText = shareText + '\n\nAbility of Memory & Attention\n' + state4;
    if (state5 != '')
      shareText = shareText + '\n\nSleep & Circadian Rhythm\n' + state5;
    if (state6 != '') shareText = shareText + '\n\nPain & Treatment\n' + state6;
    if (state7 != '')
      shareText = shareText + '\n\nSkin Problem & Care\n' + state7;
    final threadText = shareText;
    shareText = 'Granny\'s State \( ' +
        DateFormat('yyyy-MM-dd').format(DateTime.now()) +
        ' \)\n\n\n' +
        shareText;

    Future<void> _pdf() async {
      final pdf = pw.Document();
      var data = await rootBundle.load("assets/fonts/NanumGothic-Regular.ttf");
      var myFont = pw.Font.ttf(data);

      pdf.addPage(pw.Page(
        build: (pw.Context context) => pw.Container(
          padding: pw.EdgeInsets.all(8.0),
          alignment: pw.Alignment.center,
          color: PdfColor.fromHex('772e25'),
          child: pw.Text(
            shareText,
            style: pw.TextStyle(
              color: PdfColor.fromHex('edddd4'),
              font: myFont,
              fontWeight: pw.FontWeight.bold,
              fontSize: 26,
            ),
          ),
        ),
      ));

      final file = File('$tempPath/granny.pdf');
      await file.writeAsBytes(await pdf.save());

      final document =
          await render.PdfDocument.openFile('$tempPath/granny.pdf');
      final page = await document.getPage(1);
      final pageImage = await page.render(
        width: page.width,
        height: page.height,
      );
      final file1 = File('$tempPath/granny.png');
      await file1.writeAsBytes(pageImage!.bytes);
      await page.close();
      if (imagePaths.length > 1) imagePaths.removeLast();
      imagePaths.add('$tempPath/granny.png');
      Share.shareFiles(imagePaths,
          subject: 'Granny\'s State, ' +
              DateFormat('yyyy-MM-dd').format(DateTime.now()),
          text: threadText);
    }

    return Builder(builder: (BuildContext context) {
      if (!_loadingAnchoredBanner) {
        _loadingAnchoredBanner = true;
        _createAnchoredBanner(context);
      }
      return SafeArea(
          child: Scaffold(
        floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 150.0,
              ),
              if (imagePaths.isNotEmpty && state1 != '' && state2 != '')
                FloatingActionButton(
                  backgroundColor: Color(0xff197278),
                  mini: true,
                  focusNode: FocusNode(),
                  onPressed: () {
                    _pdf();
                  },
                  heroTag: 'Share as Save',
                  tooltip: 'Share as Save',
                  child: const Icon(
                    Icons.share,
                    color: Color(0xffedddd4),
                  ),
                ),
            ]),
        appBar: AppBar(
          title: Text(
            'GrannyStatePic',
            style: TextStyle(color: Color(0xffedddd4)),
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: Color(0xffedddd4),
                ),
                tooltip: 'Reset',
                onPressed: () {
                  setState(() {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        transitionDuration: Duration.zero,
                        pageBuilder: (_, __, ___) => MyHomePage(),
                      ),
                    );
                  });
                })
          ],
        ),
        body: Center(
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            children: <Widget>[
              if (_anchoredBanner != null)
                Container(
                  color: Colors.white,
                  width: _anchoredBanner!.size.width.toDouble(),
                  height: _anchoredBanner!.size.height.toDouble(),
                  child: AdWidget(ad: _anchoredBanner!),
                ),
              ListTile(
                title: Text(
                  'Share as Save Granny\'s Pic & State',
                  style: TextStyle(color: Color(0xff283d3b)),
                ),
                subtitle: Text(
                  'to assess elderly, get helped',
                  style: TextStyle(
                      color: Color(0xff283d3b), fontWeight: FontWeight.bold),
                ),
              ),
              FormBuilder(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(children: <Widget>[
                    Card(
                        child: imagePaths.isNotEmpty
                            ? ListTile(
                                title: isVideo == false
                                    ? Text(
                                        'Picture',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            color: Color(0xffC44536)),
                                      )
                                    : Text(
                                        'Video',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            color: Color(0xffC44536)),
                                      ),
                                trailing:
                                    Icon(Icons.check, color: Color(0xff283d3b)),
                              )
                            : FormBuilderChoiceChip(
                                focusNode: _formKey.currentState
                                    ?.fields['image']!.effectiveFocusNode,
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(context,
                                      errorText: 'required'),
                                ]),
                                onChanged: (value) async {
                                  if (value == 'take_picture') {
                                    isVideo = false;
                                    final pickedFile = await _picker.pickImage(
                                      source: ImageSource.camera,
                                    );
                                    if (pickedFile != null) {
                                      setState(() {
                                        imagePaths.add(pickedFile.path);
                                      });
                                    }
                                  }

                                  if (value == 'gallery_picture') {
                                    isVideo = false;
                                    final pickedFile = await _picker.pickImage(
                                      source: ImageSource.gallery,
                                    );
                                    if (pickedFile != null) {
                                      setState(() {
                                        imagePaths.add(pickedFile.path);
                                      });
                                    }
                                  }

                                  if (value == 'gallery_video') {
                                    isVideo = true;
                                    final pickedFile = await _picker.pickVideo(
                                      source: ImageSource.gallery,
                                    );
                                    if (pickedFile != null) {
                                      setState(() {
                                        imagePaths.add(pickedFile.path);
                                      });
                                    }
                                  }

                                  if (value == 'take_video') {
                                    isVideo = true;
                                    final pickedFile = await _picker.pickVideo(
                                      source: ImageSource.camera,
                                    );
                                    if (pickedFile != null) {
                                      setState(() {
                                        imagePaths.add(pickedFile.path);
                                      });
                                    }
                                  }
                                },
                                name: 'image',
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(
                                      fontSize: 22.0, color: Color(0xffC44536)),
                                  labelText: 'Picture or Video *',
                                ),
                                options: [
                                  FormBuilderFieldOption(
                                      value: 'gallery_video',
                                      child: Icon(Icons.video_library)),
                                  FormBuilderFieldOption(
                                      value: 'gallery_picture',
                                      child: Icon(Icons.photo)),
                                  FormBuilderFieldOption(
                                      value: 'take_video',
                                      child: Icon(Icons.videocam)),
                                  FormBuilderFieldOption(
                                      value: 'take_picture',
                                      child: Icon(Icons.camera_alt)),
                                ],
                              )),
                    Card(
                        child: state1 != ''
                            ? ListTile(
                                title: Text(
                                  'Nutrition & Weight Maintenance',
                                  style: TextStyle(
                                      fontSize: 16.0, color: Color(0xffC44536)),
                                ),
                                trailing: Text(
                                  state1,
                                  style: TextStyle(
                                      fontSize: 16.0, color: Color(0xff283d3b)),
                                ),
                              )
                            : FormBuilderChoiceChip(
                                focusNode: _formKey.currentState
                                    ?.fields['diet_weight']!.effectiveFocusNode,
                                onChanged: (value) {
                                  setState(() {
                                    state1 = value.toString();
                                  });
                                },
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(context,
                                      errorText: 'required'),
                                ]),
                                name: 'diet_weight',
                                decoration: InputDecoration(
                                    labelStyle: TextStyle(
                                        fontSize: 22.0,
                                        color: Color(0xffC44536)),
                                    labelText:
                                        'Nutrition & Weight Maintenance *'),
                                options: [
                                  FormBuilderFieldOption(
                                      value: '1/5', child: Text('1/5')),
                                  FormBuilderFieldOption(
                                      value: '2/5', child: Text('2/5')),
                                  FormBuilderFieldOption(
                                      value: '3/5', child: Text('3/5')),
                                  FormBuilderFieldOption(
                                      value: '4/5', child: Text('4/5')),
                                  FormBuilderFieldOption(
                                      value: '5/5', child: Text('5/5')),
                                ],
                              )),
                    Card(
                        child: state2 != ''
                            ? ListTile(
                                title: Text(
                                  'Mood & Activity Level',
                                  style: TextStyle(
                                      fontSize: 16.0, color: Color(0xffC44536)),
                                ),
                                trailing: Text(
                                  state2,
                                  style: TextStyle(
                                      fontSize: 16.0, color: Color(0xff283d3b)),
                                ),
                              )
                            : FormBuilderChoiceChip(
                                focusNode: _formKey
                                    .currentState
                                    ?.fields['mood_activity']!
                                    .effectiveFocusNode,
                                onChanged: (value) {
                                  setState(() {
                                    state2 = value.toString();
                                  });
                                },
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(context,
                                      errorText: 'required'),
                                ]),
                                name: 'mood_activity',
                                decoration: InputDecoration(
                                  labelText: 'Mood & Activity Level *',
                                  labelStyle: TextStyle(
                                      fontSize: 22.0, color: Color(0xffC44536)),
                                ),
                                options: [
                                  FormBuilderFieldOption(
                                      value: '1/5', child: Text('1/5')),
                                  FormBuilderFieldOption(
                                      value: '2/5', child: Text('2/5')),
                                  FormBuilderFieldOption(
                                      value: '3/5', child: Text('3/5')),
                                  FormBuilderFieldOption(
                                      value: '4/5', child: Text('4/5')),
                                  FormBuilderFieldOption(
                                      value: '5/5', child: Text('5/5')),
                                ],
                              )),
                    Card(
                        child: state3 != ''
                            ? ListTile(
                                title: Text(
                                  'Ability to Walk & Move',
                                  style: TextStyle(
                                      fontSize: 16.0, color: Color(0xffC44536)),
                                ),
                                trailing: Text(
                                  state3,
                                  style: TextStyle(
                                      fontSize: 16.0, color: Color(0xff283d3b)),
                                ),
                              )
                            : FormBuilderChoiceChip(
                                focusNode: _formKey.currentState
                                    ?.fields['ambulation']!.effectiveFocusNode,
                                onChanged: (value) {
                                  setState(() {
                                    state3 = value.toString();
                                  });
                                },
                                name: 'ambulation',
                                decoration: InputDecoration(
                                    labelStyle: TextStyle(
                                        fontSize: 22.0,
                                        color: Color(0xffC44536)),
                                    labelText: 'Ability to Walk & Move'),
                                options: [
                                  FormBuilderFieldOption(
                                      value: '1/5', child: Text('1/5')),
                                  FormBuilderFieldOption(
                                      value: '2/5', child: Text('2/5')),
                                  FormBuilderFieldOption(
                                      value: '3/5', child: Text('3/5')),
                                  FormBuilderFieldOption(
                                      value: '4/5', child: Text('4/5')),
                                  FormBuilderFieldOption(
                                      value: '5/5', child: Text('5/5')),
                                ],
                              )),
                    Card(
                        child: state4 != ''
                            ? ListTile(
                                title: Text(
                                  'Ability of Memory & Attention',
                                  style: TextStyle(
                                      fontSize: 16.0, color: Color(0xffC44536)),
                                ),
                                trailing: Text(
                                  state4,
                                  style: TextStyle(
                                      fontSize: 16.0, color: Color(0xff283d3b)),
                                ),
                              )
                            : FormBuilderChoiceChip(
                                focusNode: _formKey.currentState
                                    ?.fields['cognition']!.effectiveFocusNode,
                                onChanged: (value) {
                                  setState(() {
                                    state4 = value.toString();
                                  });
                                },
                                name: 'cognition',
                                decoration: InputDecoration(
                                    labelStyle: TextStyle(
                                        fontSize: 22.0,
                                        color: Color(0xffC44536)),
                                    labelText: 'Ability of Memory & Attention'),
                                options: [
                                  FormBuilderFieldOption(
                                      value: '1/5', child: Text('1/5')),
                                  FormBuilderFieldOption(
                                      value: '2/5', child: Text('2/5')),
                                  FormBuilderFieldOption(
                                      value: '3/5', child: Text('3/5')),
                                  FormBuilderFieldOption(
                                      value: '4/5', child: Text('4/5')),
                                  FormBuilderFieldOption(
                                      value: '5/5', child: Text('5/5')),
                                ],
                              )),
                    Card(
                        child: state5 != ''
                            ? ListTile(
                                title: Text(
                                  'Sleep & Circadian Rhythm',
                                  style: TextStyle(
                                      fontSize: 16.0, color: Color(0xffC44536)),
                                ),
                                trailing: Text(
                                  state5,
                                  style: TextStyle(
                                      fontSize: 16.0, color: Color(0xff283d3b)),
                                ),
                              )
                            : FormBuilderChoiceChip(
                                focusNode: _formKey.currentState
                                    ?.fields['sleep']!.effectiveFocusNode,
                                onChanged: (value) {
                                  setState(() {
                                    state5 = value.toString();
                                  });
                                },
                                name: 'sleep',
                                decoration: InputDecoration(
                                    labelStyle: TextStyle(
                                        fontSize: 22.0,
                                        color: Color(0xffC44536)),
                                    labelText: 'Sleep & Circadian Rhythm'),
                                options: [
                                  FormBuilderFieldOption(
                                      value: '1/5', child: Text('1/5')),
                                  FormBuilderFieldOption(
                                      value: '2/5', child: Text('2/5')),
                                  FormBuilderFieldOption(
                                      value: '3/5', child: Text('3/5')),
                                  FormBuilderFieldOption(
                                      value: '4/5', child: Text('4/5')),
                                  FormBuilderFieldOption(
                                      value: '5/5', child: Text('5/5')),
                                ],
                              )),
                    Card(
                        child: state6 != ''
                            ? ListTile(
                                title: Text(
                                  'Pain & Treatment',
                                  style: TextStyle(
                                      fontSize: 16.0, color: Color(0xffC44536)),
                                ),
                                trailing: Text(
                                  state6,
                                  style: TextStyle(
                                      fontSize: 16.0, color: Color(0xff283d3b)),
                                ),
                              )
                            : FormBuilderChoiceChip(
                                focusNode: _formKey.currentState
                                    ?.fields['pain']!.effectiveFocusNode,
                                onChanged: (value) {
                                  setState(() {
                                    state6 = value.toString();
                                  });
                                },
                                name: 'pain',
                                decoration: InputDecoration(
                                    labelStyle: TextStyle(
                                        fontSize: 22.0,
                                        color: Color(0xffC44536)),
                                    labelText: 'Pain & Treatment'),
                                options: [
                                  FormBuilderFieldOption(
                                      value: '1/5', child: Text('1/5')),
                                  FormBuilderFieldOption(
                                      value: '2/5', child: Text('2/5')),
                                  FormBuilderFieldOption(
                                      value: '3/5', child: Text('3/5')),
                                  FormBuilderFieldOption(
                                      value: '4/5', child: Text('4/5')),
                                  FormBuilderFieldOption(
                                      value: '5/5', child: Text('5/5')),
                                ],
                              )),
                    Card(
                        child: state7 != ''
                            ? ListTile(
                                title: Text(
                                  'Skin Problem & Care',
                                  style: TextStyle(
                                      fontSize: 16.0, color: Color(0xffC44536)),
                                ),
                                trailing: Text(
                                  state7,
                                  style: TextStyle(
                                      fontSize: 16.0, color: Color(0xff283d3b)),
                                ),
                              )
                            : FormBuilderChoiceChip(
                                focusNode: _formKey.currentState
                                    ?.fields['skin']!.effectiveFocusNode,
                                onChanged: (value) {
                                  setState(() {
                                    state7 = value.toString();
                                  });
                                },
                                name: 'skin',
                                decoration: InputDecoration(
                                    labelStyle: TextStyle(
                                        fontSize: 22.0,
                                        color: Color(0xffC44536)),
                                    labelText: 'Skin Problem & Care'),
                                options: [
                                  FormBuilderFieldOption(
                                      value: '1/5', child: Text('1/5')),
                                  FormBuilderFieldOption(
                                      value: '2/5', child: Text('2/5')),
                                  FormBuilderFieldOption(
                                      value: '3/5', child: Text('3/5')),
                                  FormBuilderFieldOption(
                                      value: '4/5', child: Text('4/5')),
                                  FormBuilderFieldOption(
                                      value: '5/5', child: Text('5/5')),
                                ],
                              )),
                    /* comment suspended
                  Card(
                    child: FormBuilderTextField(
                      name: 'comment',
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(1.0)),
                              borderSide: BorderSide(color: Color(0xff231f20))),
                          labelText: 'comment',
                          labelStyle: TextStyle(
                              fontSize: 16.0,
                              color: Color(0xffC44536),
                              fontWeight: FontWeight.bold)),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                          context,
                          errorText: 'err',
                        ),
                        FormBuilderValidators.maxLength(context, 30),
                      ]),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  */
                  ])),
            ],
          ),
        ),
      ));
    });
  }
}
