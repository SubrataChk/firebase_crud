import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crud/src/update/update.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../post/post.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> deleteData(selectDoc) async {
    return FirebaseFirestore.instance
        .collection("todos")
        .doc(selectDoc)
        .delete()
        .then((value) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Data Delete")));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => PostSection()));
          },
          child: Icon(
            Icons.add,
            color: Colors.black,
            size: 7.w,
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("todos").snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("There is some Error"),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h),
                  child: Container(
                    height: 30.h,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                height: 10.h,
                                width: double.maxFinite,
                                child: Image.network(
                                  data["img"],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Text(data["title"]),
                            Text(data["des"]),
                            Row(
                              children: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  UpdatePostSection(
                                                    documentId: document.id,
                                                    des: data["des"],
                                                    title: data["title"],
                                                    imageUrl: data["img"],
                                                  )));
                                    },
                                    child: Text(
                                      "Edit",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp),
                                    )),
                                TextButton(
                                    onPressed: () {
                                      deleteData(document.id);
                                    },
                                    child: Text(
                                      "Delete",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp),
                                    ))
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ));
  }
}
