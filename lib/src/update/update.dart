import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:sizer/sizer.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;

class UpdatePostSection extends StatefulWidget {
  final String documentId;
  final String title;
  final String imageUrl;
  final String des;
  const UpdatePostSection({
    Key? key,
    required this.des,
    required this.documentId,
    required this.imageUrl,
    required this.title,
  }) : super(key: key);

  @override
  State<UpdatePostSection> createState() => _UpdatePostSectionState();
}

class _UpdatePostSectionState extends State<UpdatePostSection> {
  final String uniqueName = DateTime.now().millisecondsSinceEpoch.toString();

  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();

  bool showSpineer = false;

  @override
  void initState() {
    super.initState();
    title.text = widget.title;
    description.text = widget.des;
  }

  File? _image;
  final ImagePicker imagePicker = ImagePicker();
  Future galleryImage() async {
    final pickImage = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickImage != null) {
        _image = File(pickImage.path);
      } else {
        print("There is no imgae");
      }
    });
  }

  Future cameraImage() async {
    final pickImage = await imagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickImage != null) {
        _image = File(pickImage.path);
      } else {
        print("There is no image");
      }
    });
  }

  String imagUrl = "";

  //Publish:
  updateData(selectDoc) async {
    if (_image == null) {
      CollectionReference _todos =
          FirebaseFirestore.instance.collection("todos");
      _todos.doc(selectDoc).update({
        "title": title.text,
        "des": description.text,
        "img": widget.imageUrl,
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Update")));
      Navigator.pop(context);
    } else {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      fStorage.Reference reference = fStorage.FirebaseStorage.instance
          .ref()
          .child("images")
          .child(fileName);

      fStorage.UploadTask uploadTask = reference.putFile(File(_image!.path));
      fStorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      await taskSnapshot.ref.getDownloadURL().then((img) {
        imagUrl = img;
      });

      CollectionReference _todos =
          FirebaseFirestore.instance.collection("todos");
      _todos.doc(selectDoc).update({
        "title": title.text,
        "des": description.text,
        "img": imagUrl,
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Update")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpineer,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 6.w,
                color: Colors.black,
              )),
        ),
        body: SafeArea(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: ListView(
            children: [
              Center(
                child: Container(
                  height: 20.h,
                  width: double.infinity,
                  child: _image != null
                      ? ClipRRect(
                          child: Image.file(
                            _image!.absolute,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          height: 100,
                          width: 100,
                          child: Image.network(widget.imageUrl)),
                ),
              ),
              TextButton(
                  onPressed: () {
                    setState(() {
                      imagUrl = "";
                    });
                  },
                  child: Text("Clear Image")),
              PostTextField(
                hintText: "Write an Title",
                maxLine: 1,
                controller: title,
              ),
              PostTextField(
                hintText: "Write an Description",
                maxLine: 10,
                controller: description,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    PostButton(
                      icons: Icons.post_add,
                      onTap: () {
                        cameraDialog(context);
                      },
                      title: "Update Media",
                    ),
                    PostButton(
                      icons: Icons.podcasts,
                      onTap: () {
                        updateData(widget.documentId);
                      },
                      title: "Update",
                    )
                  ],
                ),
              )
            ],
          ),
        )),
      ),
    );
  }

  void cameraDialog(context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            content: Container(
                height: 15.h,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        cameraImage();
                        Navigator.pop(context);
                      },
                      child: ListTile(
                        title: Text("Camera"),
                        leading: Icon(Icons.camera),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        galleryImage();
                        Navigator.pop(context);
                      },
                      child: ListTile(
                        title: Text("Gallery"),
                        leading: Icon(Icons.photo_library),
                      ),
                    )
                  ],
                )),
          );
        });
  }
}

class PostButton extends StatelessWidget {
  final String title;
  final IconData icons;
  final VoidCallback onTap;

  const PostButton(
      {Key? key, required this.icons, required this.onTap, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 6.h,
        width: 40.w,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icons,
              color: Colors.white,
            ),
            SizedBox(
              width: 2.w,
            ),
            Text(
              title,
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}

class PostTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLine;
  const PostTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.maxLine,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: TextFormField(
        maxLines: maxLine,
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(12),
          hintText: hintText,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.black,
              )),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.black,
              )),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.black,
              )),
        ),
      ),
    );
  }
}
