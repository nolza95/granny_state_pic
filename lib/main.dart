/*
pdf로 만들어서 pdf를 img로 만들어서 share로 내보내려고 하는데 unicode가 안되어서 ttf 폰트를 사용하려는데 FILE을 읽지를 못함.
path provider 가상디렉토리파일을 만들어서 유저퍼미션 쓰고 읽기 할 필요 없도록 할 것
focusNode 문제
share 기능
color
localization
icon
 */

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:native_pdf_renderer/native_pdf_renderer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GrannyStatePic',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  final _formKey = GlobalKey<FormBuilderState>();

  bool isVideo = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
    shareText = 'Nutrition & Weight Maintenance ' +
        state1 +
        ' / Mood & Activity Level ' +
        state2;
    if (state3 != '')
      shareText = shareText + ' / Ability to Walk & Move ' + state3;
    if (state4 != '')
      shareText = shareText + ' / Ability of Memory & Attention ' + state4;
    if (state5 != '')
      shareText = shareText + ' / Sleep & Circadian Rhythm ' + state5;
    if (state6 != '') shareText = shareText + ' / Pain & Treatment ' + state6;
    if (state7 != '')
      shareText = shareText + ' / Skin Problem & Care ' + state7;

    final Uint8List fontData =
        File('lib/OpenSans-Regular.ttf').readAsBytesSync();
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());

    Future<void> _pdf(dynamic txt) async {
      final pdf = pw.Document();
      final Uint8List fontData =
          File('assets/fonts/OpenSans-Regular.ttf').readAsBytesSync();
      final ttf = pw.Font.ttf(fontData.buffer.asByteData());

      pdf.addPage(pw.Page(
        build: (pw.Context context) => pw.Column(children: [
          pw.Image(pw.MemoryImage(File(imagePaths.first).readAsBytesSync())),
          pw.Text(shareText, style: pw.TextStyle(font: ttf, fontSize: 40))
        ]),
      ));
      final file = File('final.pdf');
      await file.writeAsBytes(await pdf.save());
      final document = await PdfDocument.openFile('final.pdf');
      final page = await document.getPage(1);
      final pageImage = await page.render(
        width: page.width,
        height: page.height,
        format: PdfPageFormat.PNG,
      );
      final file1 = File('final.png');
      await file.writeAsBytes(pageImage!.bytes);
      await page.close();
      imagePaths.removeAt(0);
      imagePaths.add('final.png');
      Share.shareFiles(imagePaths);
    }

    return SafeArea(
        child: Scaffold(
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        SizedBox(
          height: 80.0,
        ),
        if (imagePaths.isNotEmpty && state1 != '' && state2 != '')
          FloatingActionButton(
            mini: true,
            focusNode: FocusNode(),
            onPressed: () {
              _pdf(shareText);

              print(shareText);
            },
            heroTag: 'Share as Save',
            tooltip: 'Share as Save',
            child: const Icon(Icons.share),
          ),
      ]),
      appBar: AppBar(
        title: Text('GrannyStatePic'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.refresh),
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
            ListTile(
              title: Text('Share as Save Pic with State of Granny'),
              subtitle: Text(
                  'to assess elderly at nursery/hospital\nget help from caregiver/nurse'),
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
                                          fontSize: 18.0,
                                          color: Color(0xffbb4430)),
                                    )
                                  : Text(
                                      'Video',
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          color: Color(0xffbb4430)),
                                    ),
                              trailing: Icon(Icons.check),
                            )
                          : FormBuilderChoiceChip(
                              focusNode: _formKey.currentState?.fields['image']!
                                  .effectiveFocusNode,
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
                                    fontSize: 22.0, color: Color(0xffbb4430)),
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
                                    fontSize: 18.0, color: Color(0xffbb4430)),
                              ),
                              trailing: Text(state1),
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
                                      fontSize: 22.0, color: Color(0xffbb4430)),
                                  labelText:
                                      'Nutrition & Weight Maintenance *'),
                              options: [
                                FormBuilderFieldOption(
                                    value: '🔴', child: Text('🔴')),
                                FormBuilderFieldOption(
                                    value: '🟠', child: Text('🟠')),
                                FormBuilderFieldOption(
                                    value: '🟢', child: Text('🟢')),
                              ],
                            )),
                  Card(
                      child: state2 != ''
                          ? ListTile(
                              title: Text(
                                'Mood & Activity Level',
                                style: TextStyle(
                                    fontSize: 18.0, color: Color(0xffbb4430)),
                              ),
                              trailing: Text(state2),
                            )
                          : FormBuilderChoiceChip(
                              focusNode: _formKey.currentState
                                  ?.fields['mood_activity']!.effectiveFocusNode,
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
                                    fontSize: 22.0, color: Color(0xffbb4430)),
                              ),
                              options: [
                                FormBuilderFieldOption(
                                    value: '🔴', child: Text('🔴')),
                                FormBuilderFieldOption(
                                    value: '🟠', child: Text('🟠')),
                                FormBuilderFieldOption(
                                    value: '🟢', child: Text('🟢')),
                              ],
                            )),
                  Card(
                      child: state3 != ''
                          ? ListTile(
                              title: Text(
                                'Ability to Walk & Move',
                                style: TextStyle(
                                    fontSize: 18.0, color: Color(0xffbb4430)),
                              ),
                              trailing: Text(state3),
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
                                      fontSize: 22.0, color: Color(0xffbb4430)),
                                  labelText: 'Ability to Walk & Move'),
                              options: [
                                FormBuilderFieldOption(
                                    value: '🔴', child: Text('🔴')),
                                FormBuilderFieldOption(
                                    value: '🟠', child: Text('🟠')),
                                FormBuilderFieldOption(
                                    value: '🟢', child: Text('🟢')),
                              ],
                            )),
                  Card(
                      child: state4 != ''
                          ? ListTile(
                              title: Text(
                                'Ability of Memory & Attention',
                                style: TextStyle(
                                    fontSize: 18.0, color: Color(0xffbb4430)),
                              ),
                              trailing: Text(state4),
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
                                      fontSize: 22.0, color: Color(0xffbb4430)),
                                  labelText: 'Ability of Memory & Attention'),
                              options: [
                                FormBuilderFieldOption(
                                    value: '🔴', child: Text('🔴')),
                                FormBuilderFieldOption(
                                    value: '🟠', child: Text('🟠')),
                                FormBuilderFieldOption(
                                    value: '🟢', child: Text('🟢')),
                              ],
                            )),
                  Card(
                      child: state5 != ''
                          ? ListTile(
                              title: Text(
                                'Sleep & Circadian Rhythm',
                                style: TextStyle(
                                    fontSize: 18.0, color: Color(0xffbb4430)),
                              ),
                              trailing: Text(state5),
                            )
                          : FormBuilderChoiceChip(
                              focusNode: _formKey.currentState?.fields['sleep']!
                                  .effectiveFocusNode,
                              onChanged: (value) {
                                setState(() {
                                  state5 = value.toString();
                                });
                              },
                              name: 'sleep',
                              decoration: InputDecoration(
                                  labelStyle: TextStyle(
                                      fontSize: 22.0, color: Color(0xffbb4430)),
                                  labelText: 'Sleep & Circadian Rhythm'),
                              options: [
                                FormBuilderFieldOption(
                                    value: '🔴', child: Text('🔴')),
                                FormBuilderFieldOption(
                                    value: '🟠', child: Text('🟠')),
                                FormBuilderFieldOption(
                                    value: '🟢', child: Text('🟢')),
                              ],
                            )),
                  Card(
                      child: state6 != ''
                          ? ListTile(
                              title: Text(
                                'Pain & Treatment',
                                style: TextStyle(
                                    fontSize: 18.0, color: Color(0xffbb4430)),
                              ),
                              trailing: Text(state6),
                            )
                          : FormBuilderChoiceChip(
                              focusNode: _formKey.currentState?.fields['pain']!
                                  .effectiveFocusNode,
                              onChanged: (value) {
                                setState(() {
                                  state6 = value.toString();
                                });
                              },
                              name: 'pain',
                              decoration: InputDecoration(
                                  labelStyle: TextStyle(
                                      fontSize: 22.0, color: Color(0xffbb4430)),
                                  labelText: 'Pain & Treatment'),
                              options: [
                                FormBuilderFieldOption(
                                    value: '🔴', child: Text('🔴')),
                                FormBuilderFieldOption(
                                    value: '🟠', child: Text('🟠')),
                                FormBuilderFieldOption(
                                    value: '🟢', child: Text('🟢')),
                              ],
                            )),
                  Card(
                      child: state7 != ''
                          ? ListTile(
                              title: Text(
                                'Skin Problem & Care',
                                style: TextStyle(
                                    fontSize: 18.0, color: Color(0xffbb4430)),
                              ),
                              trailing: Text(state7),
                            )
                          : FormBuilderChoiceChip(
                              focusNode: _formKey.currentState?.fields['skin']!
                                  .effectiveFocusNode,
                              onChanged: (value) {
                                setState(() {
                                  state7 = value.toString();
                                });
                              },
                              name: 'skin',
                              decoration: InputDecoration(
                                  labelStyle: TextStyle(
                                      fontSize: 22.0, color: Color(0xffbb4430)),
                                  labelText: 'Skin Problem & Care'),
                              options: [
                                FormBuilderFieldOption(
                                    value: '🔴', child: Text('🔴')),
                                FormBuilderFieldOption(
                                    value: '🟠', child: Text('🟠')),
                                FormBuilderFieldOption(
                                    value: '🟢', child: Text('🟢')),
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
                              color: Color(0xffbb4430),
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
  }
}
