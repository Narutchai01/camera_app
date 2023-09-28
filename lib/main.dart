import 'package:camera/camera.dart';
import 'package:camera_app/screen/camera_screenn.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraApp(),
    );
  }
}

class CameraApp extends StatefulWidget {
  const CameraApp({Key? key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(cameras[0], ResolutionPreset.max);

    // Initialize the camera controller
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraException':
            print("access was denied");
            break;
          default:
            print(e.description);
            break;
        }
      }
    });
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    try {
      final imagePicker = ImagePicker();
      final imageFile =
          await imagePicker.pickImage(source: ImageSource.gallery);
      if (imageFile != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImagePreview(imageFile),
          ),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            child: CameraPreview(_controller),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.all(20.0),
                  child: MaterialButton(
                    onPressed: () async {
                      if (!_controller.value.isInitialized) {
                        return null;
                      }
                      if (_controller.value.isTakingPicture) {
                        return null;
                      }
                      try {
                        await _controller.setFlashMode(FlashMode.auto);
                        XFile file = await _controller.takePicture();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImagePreview(file),
                          ),
                        );
                      } on CameraException catch (e) {
                        debugPrint("Error while taking picture");
                        return null;
                      }
                    },
                    color: Colors.white,
                    child: Text("Take a picture"),
                  ),
                ),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.all(20.0),
                  child: MaterialButton(
                    onPressed: _pickImage,
                    color: Colors.white,
                    child: Text("Pick Image from Gallery"),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
