/*
focusnode 문제
share 기능
color
localization
icon
 */

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';

void main() {
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
  List<XFile>? _imageFileList;

  set _imageFile(XFile? value) {
    _imageFileList = value == null ? null : [value];
  }

  dynamic _pickImageError;
  bool isVideo = false;

  VideoPlayerController? _controller;
  VideoPlayerController? _toBeDisposed;
  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();

  Future<void> _playVideo(XFile? file) async {
    if (file != null && mounted) {
      await _disposeVideoController();
      late VideoPlayerController controller;
      if (kIsWeb) {
        controller = VideoPlayerController.network(file.path);
      } else {
        controller = VideoPlayerController.file(File(file.path));
      }
      _controller = controller;
      final double volume = kIsWeb ? 0.0 : 1.0;
      await controller.setVolume(volume);
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      setState(() {});
    }
  }

  void _onImageButtonPressed(ImageSource source,
      {BuildContext? context, bool isMultiImage = false}) async {
    if (_controller != null) {
      await _controller!.setVolume(0.0);
    }
    if (isVideo) {
      final XFile? file = await _picker.pickVideo(
          source: source, maxDuration: const Duration(seconds: 10));
      await _playVideo(file);
    } else if (isMultiImage) {
      await _displayPickImageDialog(context!,
          (double? maxWidth, double? maxHeight, int? quality) async {
        try {
          final pickedFileList = await _picker.pickMultiImage(
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            imageQuality: quality,
          );
          setState(() {
            _imageFileList = pickedFileList;
          });
        } catch (e) {
          setState(() {
            _pickImageError = e;
          });
        }
      });
    } else {
      await _displayPickImageDialog(context!,
          (double? maxWidth, double? maxHeight, int? quality) async {
        try {
          final pickedFile = await _picker.pickImage(
            source: source,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            imageQuality: quality,
          );
          setState(() {
            _imageFile = pickedFile;
          });
        } catch (e) {
          setState(() {
            _pickImageError = e;
          });
        }
      });
    }
  }

  @override
  void deactivate() {
    if (_controller != null) {
      _controller!.setVolume(0.0);
      _controller!.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _disposeVideoController();
    maxWidthController.dispose();
    maxHeightController.dispose();
    qualityController.dispose();
    super.dispose();
  }

  Future<void> _disposeVideoController() async {
    if (_toBeDisposed != null) {
      await _toBeDisposed!.dispose();
    }
    _toBeDisposed = _controller;
    _controller = null;
  }

  Widget _previewVideo() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_controller == null) {
      return const Text(
        'You have not yet picked a video',
        textAlign: TextAlign.center,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AspectRatioVideo(_controller),
    );
  }

  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFileList != null) {
      return Semantics(
          child: ListView.builder(
            key: UniqueKey(),
            itemBuilder: (context, index) {
              // Why network for web?
              // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
              return Semantics(
                label: 'image_picker_example_picked_image',
                child: kIsWeb
                    ? Image.network(_imageFileList![index].path)
                    : Image.file(File(_imageFileList![index].path)),
              );
            },
            itemCount: _imageFileList!.length,
          ),
          label: 'image_picker_example_picked_images');
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _handlePreview() {
    if (isVideo) {
      return _previewVideo();
    } else {
      return _previewImages();
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (response.type == RetrieveType.video) {
        isVideo = true;
        await _playVideo(response.file);
      } else {
        isVideo = false;
        setState(() {
          _imageFile = response.file;
          _imageFileList = response.files;
        });
      }
    } else {
      _retrieveDataError = response.exception!.code;
    }
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
              Share.shareFiles(imagePaths, text: shareText);
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

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> _displayPickImageDialog(
      BuildContext context, OnPickImageCallback onPick) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add optional parameters'),
            content: Column(
              children: <Widget>[
                TextField(
                  controller: maxWidthController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      InputDecoration(hintText: "Enter maxWidth if desired"),
                ),
                TextField(
                  controller: maxHeightController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      InputDecoration(hintText: "Enter maxHeight if desired"),
                ),
                TextField(
                  controller: qualityController,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(hintText: "Enter quality if desired"),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                  child: const Text('PICK'),
                  onPressed: () {
                    double? width = maxWidthController.text.isNotEmpty
                        ? double.parse(maxWidthController.text)
                        : null;
                    double? height = maxHeightController.text.isNotEmpty
                        ? double.parse(maxHeightController.text)
                        : null;
                    int? quality = qualityController.text.isNotEmpty
                        ? int.parse(qualityController.text)
                        : null;
                    onPick(width, height, quality);
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }
}

typedef void OnPickImageCallback(
    double? maxWidth, double? maxHeight, int? quality);

class AspectRatioVideo extends StatefulWidget {
  AspectRatioVideo(this.controller);

  final VideoPlayerController? controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController? get controller => widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller!.value.isInitialized) {
      initialized = controller!.value.isInitialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller!.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller!.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: VideoPlayer(controller!),
        ),
      );
    } else {
      return Container();
    }
  }
}
