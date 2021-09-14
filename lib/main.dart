/*
최상단 설명문, 배너광고
선택하면 listTile 체크표시 나오게, * 3개 다 하면 share 플로팅버튼 나오게
 */

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:share/share.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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

  String text = '';
  String subject = '';
  List<String> imagePaths = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('widget.title'),
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          children: <Widget>[
            FormBuilder(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(children: <Widget>[
                  imagePaths.isNotEmpty
                      ? Card(
                          child: ListTile(
                          title: isVideo == false
                              ? Text(
                                  'Picture',
                                  style: TextStyle(
                                      fontSize: 18.0, color: Color(0xffbb4430)),
                                )
                              : Text(
                                  'Video',
                                  style: TextStyle(
                                      fontSize: 18.0, color: Color(0xffbb4430)),
                                ),
                          trailing: Icon(Icons.check),
                        ))
                      : Card(
                          child: FormBuilderChoiceChip(
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
                      child: FormBuilderChoiceChip(
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context,
                          errorText: 'required'),
                    ]),
                    name: 'diet_weight',
                    decoration: InputDecoration(
                        labelStyle:
                            TextStyle(fontSize: 22.0, color: Color(0xffbb4430)),
                        labelText: 'Nutrition & Weight Maintenance *'),
                    options: [
                      FormBuilderFieldOption(value: 'red', child: Text('🔴')),
                      FormBuilderFieldOption(
                          value: 'orange', child: Text('🟠')),
                      FormBuilderFieldOption(value: 'green', child: Text('🟢')),
                    ],
                  )),
                  Card(
                      child: FormBuilderChoiceChip(
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context,
                          errorText: 'required'),
                    ]),
                    name: 'mood_activity',
                    decoration: InputDecoration(
                      labelText: 'Mood & Activity Level *',
                      labelStyle:
                          TextStyle(fontSize: 22.0, color: Color(0xffbb4430)),
                    ),
                    options: [
                      FormBuilderFieldOption(value: 'red', child: Text('🔴')),
                      FormBuilderFieldOption(
                          value: 'orange', child: Text('🟠')),
                      FormBuilderFieldOption(value: 'green', child: Text('🟢')),
                    ],
                  )),
                  Card(
                      child: FormBuilderChoiceChip(
                    name: 'ambulation',
                    decoration: InputDecoration(
                        labelStyle:
                            TextStyle(fontSize: 22.0, color: Color(0xffbb4430)),
                        labelText: 'Ability to Walk & Move'),
                    options: [
                      FormBuilderFieldOption(value: 'red', child: Text('🔴')),
                      FormBuilderFieldOption(
                          value: 'orange', child: Text('🟠')),
                      FormBuilderFieldOption(value: 'green', child: Text('🟢')),
                    ],
                  )),
                  Card(
                      child: FormBuilderChoiceChip(
                    name: 'cognition',
                    decoration: InputDecoration(
                        labelStyle:
                            TextStyle(fontSize: 22.0, color: Color(0xffbb4430)),
                        labelText: 'Ability of Memory & Attention'),
                    options: [
                      FormBuilderFieldOption(value: 'red', child: Text('🔴')),
                      FormBuilderFieldOption(
                          value: 'orange', child: Text('🟠')),
                      FormBuilderFieldOption(value: 'green', child: Text('🟢')),
                    ],
                  )),
                  Card(
                      child: FormBuilderChoiceChip(
                    name: 'sleep',
                    decoration: InputDecoration(
                        labelStyle:
                            TextStyle(fontSize: 22.0, color: Color(0xffbb4430)),
                        labelText: 'Sleep & Circadian Rhythm'),
                    options: [
                      FormBuilderFieldOption(value: 'red', child: Text('🔴')),
                      FormBuilderFieldOption(
                          value: 'orange', child: Text('🟠')),
                      FormBuilderFieldOption(value: 'green', child: Text('🟢')),
                    ],
                  )),
                  Card(
                      child: FormBuilderChoiceChip(
                    name: 'pain',
                    decoration: InputDecoration(
                        labelStyle:
                            TextStyle(fontSize: 22.0, color: Color(0xffbb4430)),
                        labelText: 'Pain & Treatment'),
                    options: [
                      FormBuilderFieldOption(value: 'red', child: Text('🔴')),
                      FormBuilderFieldOption(
                          value: 'orange', child: Text('🟠')),
                      FormBuilderFieldOption(value: 'green', child: Text('🟢')),
                    ],
                  )),
                  Card(
                      child: FormBuilderChoiceChip(
                    name: 'skin',
                    decoration: InputDecoration(
                        labelStyle:
                            TextStyle(fontSize: 22.0, color: Color(0xffbb4430)),
                        labelText: 'Skin Problem & Care'),
                    options: [
                      FormBuilderFieldOption(value: 'red', child: Text('🔴')),
                      FormBuilderFieldOption(
                          value: 'orange', child: Text('🟠')),
                      FormBuilderFieldOption(value: 'green', child: Text('🟢')),
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
            Row(children: <Widget>[
              Expanded(
                child: MaterialButton(
                  color: Theme.of(context).accentColor,
                  child:
                      const Icon(Icons.input_rounded, color: Color(0xffefe6dd)),
                  onPressed: () {
                    _formKey.currentState?.save();
                    if (_formKey.currentState!.validate()) {
                      print(_formKey.currentState?.value);
                      setState(() {
                        // Navigator.of(context).push(_createRoute(2));
                      });
                    } else {
                      // print(AppLocalizations.of(context).question_error);
                    }
                  },
                ),
              ),
            ]),
          ],
        ),
      ),
    );
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
