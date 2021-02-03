import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:view/models/postModel.dart';
import 'package:view/models/userData.dart';
import 'package:view/services/database.dart';
import 'package:view/services/storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib;
import 'package:view/utilities/tools.dart';

class AddPostPage extends StatefulWidget {
  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  File _image;
  TextEditingController _captionController = TextEditingController();
  String _caption = '';
  bool _isLoading = false;
  String _fileName = '';

  _handleImage(ImageSource source) async {
    Navigator.pop(context);
    PickedFile selectedFile = await ImagePicker().getImage(source: source);
    File imageFile = File(selectedFile.path);
    _fileName = imageFile.path;
    RegExp exp = RegExp(r'image_picker(.*).(jpg|jpeg)');
    var expMatchRes = exp.firstMatch(_fileName);
    if (expMatchRes == null) {
      return showDialog(
          context: context,
          builder: (_) => new AlertDialog(
                title: new Text("图片类型限制"),
                content: new Text("目前 View 仅支持 jpg, jpeg 类型的图片哦"),
                actions: <Widget>[
                  FlatButton(
                    child: Text('好的, 我知道了'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ));
    }
    _fileName = expMatchRes[0];
    print('选中的文件名字是' + _fileName);
    if (imageFile != null) {
      imageFile = await _cropImage(imageFile);
      var image = imageLib.decodeImage(imageFile.readAsBytesSync());
      Map map = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => new PhotoFilterSelector(
            appBarColor: Colors.white,
            title: Text(
              '选个喜欢的滤镜吧',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            image: image,
            filters: presetFiltersList,
            filename: _fileName,
            loader: Center(child: CircularProgressIndicator()),
            fit: BoxFit.contain,
          ),
        ),
      );
      if (map != null && map.containsKey('image_filtered')) {
        setState(() {
          imageFile = map['image_filtered'];
        });
        print(imageFile.path);
      }
      setState(() {
        _image = imageFile;
      });
    }
  }

  _cropImage(File imageFile) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
    );
    return croppedImage;
  }

  _showSelectImageDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('上传照片'),
          children: <Widget>[
            SimpleDialogOption(
              child: Text('拍照'),
              onPressed: () => _handleImage(ImageSource.camera),
            ),
            SimpleDialogOption(
              child: Text('从相册上传'),
              onPressed: () => _handleImage(ImageSource.gallery),
            ),
            SimpleDialogOption(
              child: Text(
                '取消',
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  _submit() async {
    if (!_isLoading && _image != null && _caption.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      // Create post
      String imageUrl = await StorageService.uploadPost(_image);
      Post post = Post(
        imageUrl: imageUrl,
        caption: _caption,
        likeCount: 0,
        authorId: Provider.of<UserData>(context, listen: false).currentUserId,
        timestamp: Timestamp.fromDate(DateTime.now()),
      );
      DatabaseService.createPost(context, post);

      // Reset data
      _captionController.clear();

      setState(() {
        _caption = '';
        _image = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '发帖',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          _isLoading
              ? SizedBox.shrink()
              : IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _submit,
                ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            height: height,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: _showSelectImageDialog,
                  child: Container(
                      height: width,
                      width: width,
                      color: Colors.grey[300],
                      child: _isLoading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : (_image == null
                              ? Icon(
                                  Icons.add_a_photo,
                                  color: Colors.white70,
                                  size: 150.0,
                                )
                              : Image(
                                  image: FileImage(_image),
                                  fit: BoxFit.cover,
                                ))),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: _isLoading
                      ? Text(
                          '发布中......请稍等......',
                          style: TextStyle(fontSize: 20.0),
                        )
                      : TextField(
                          controller: _captionController,
                          style: TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: '说点什么吧',
                          ),
                          onChanged: (input) => _caption = input,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
