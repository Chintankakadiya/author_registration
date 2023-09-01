import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:author_registration/helpers/firestore_db_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextStyle myStyle = TextStyle(color: Colors.white);
  final GlobalKey<FormState> insertKey = GlobalKey<FormState>();
  final GlobalKey<FormState> updateKey = GlobalKey<FormState>();

  TextEditingController authorController = TextEditingController();
  TextEditingController bookController = TextEditingController();

  String? author;
  String? book;
  Uint8List? image;
  Uint8List? decodedImage;
  String encodedImage = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("Author Keeper"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: validatorandinsert,
        icon: Icon(Icons.add),
        backgroundColor: Colors.red,
        label: Text('Add Author data'),
      ),
      body: StreamBuilder(
        stream: CloudFirestoreHelper.cloudFirestoreHelper.selectrecord(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapShot) {
          if (snapShot.hasError) {
            return Center(
              child: Text("ERROR:${snapShot.error}"),
            );
          } else if (snapShot.hasData) {
            QuerySnapshot? data = snapShot.data;
            List<QueryDocumentSnapshot> documents = data!.docs;

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, i) {
                if (documents[i]['image'] != null) {
                  decodedImage = base64Decode(documents[i]['image']);
                } else {
                  decodedImage = null;
                }
                return Card(
                  elevation: 5,
                  color: Colors.grey,
                  shadowColor: Colors.orange,
                  child: ListTile(
                    isThreeLine: true,
                    leading: (decodedImage == null)
                        ? Text(
                            'NO IMAGE',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 10),
                          )
                        : Container(
                            height: 65,
                            width: 65,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                decodedImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                    title: Text('${documents[i]['author']}'),
                    subtitle: Text('${documents[i]['book']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Update Records"),
                                content: Form(
                                  key: updateKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextFormField(
                                        validator: (val) {
                                          (val!.isEmpty)
                                              ? "Enter author first..."
                                              : null;
                                        },
                                        onSaved: (val) {
                                          author = val;
                                        },
                                        controller: authorController,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText: 'Enter author Here...',
                                            labelText: "author"),
                                      ),
                                      SizedBox(height: 10),
                                      TextFormField(
                                        maxLines: 5,
                                        validator: (val) {
                                          (val!.isEmpty)
                                              ? "Enter book first..."
                                              : null;
                                        },
                                        onSaved: (val) {
                                          book = val;
                                        },
                                        controller: bookController,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText: 'Enter book Here...',
                                            labelText: 'book'),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      if (updateKey.currentState!.validate()) {
                                        updateKey.currentState!.save();
                                        Map<String, dynamic> data = {
                                          'author': author,
                                          'book': book,
                                        };
                                        CloudFirestoreHelper
                                            .cloudFirestoreHelper
                                            .updateRecords(
                                                id: documents[i].id,
                                                data: data);
                                      }
                                      authorController.clear();
                                      bookController.clear();

                                      author = "";
                                      book = "";
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Update"),
                                  ),
                                  OutlinedButton(
                                    onPressed: () {
                                      authorController.clear();
                                      bookController.clear();
                                      author = null;
                                      book = null;
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Cancel"),
                                  )
                                ],
                              ),
                            );
                          },
                          icon: Icon(Icons.edit),
                        ),
                        IconButton(
                            onPressed: () async {
                              await CloudFirestoreHelper.cloudFirestoreHelper
                                  .deleterecord(id: "${documents[i].id}");
                            },
                            icon: Icon(Icons.delete))
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  validatorandinsert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text('Enter book details here'),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: insertKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () async {
                    final ImagePicker _picker = ImagePicker();
                    XFile? img =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (img != null) {
                      File compressedImage =
                          await FlutterNativeImage.compressImage(img.path);
                      image = await compressedImage.readAsBytes();
                      encodedImage = base64Encode(image!);
                    }
                    setState(() {});
                  },
                  child: CircleAvatar(
                    radius: 50,
                    child: Center(
                      child: image == null
                          ? Text(
                              'ADD IMAGE',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10),
                            )
                          : Container(
                              height: 20,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.memory(
                                  image!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  validator: (val) {
                    (val!.isEmpty) ? 'Enter Auhtor' : null;
                  },
                  controller: authorController,
                  onSaved: (val) {
                    author = val;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'author',
                    hintText: 'Enter author Here....',
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  validator: (val) {
                    (val!.isEmpty) ? 'Enter Book' : null;
                  },
                  controller: bookController,
                  onSaved: (val) {
                    book = val;
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'book',
                      hintText: 'Enter book here....'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (insertKey.currentState!.validate()) {
                insertKey.currentState!.save();
                Map<String, dynamic> data = {
                  'author': author,
                  'book': book,
                  'image': encodedImage
                };
                await CloudFirestoreHelper.cloudFirestoreHelper
                    .insertrecord(data: data);
                Navigator.of(context).pop();
                authorController.clear();
                bookController.clear();
                setState(() {
                  author = null;
                  book = null;
                  decodedImage = null;
                });
              }
            },
            child: Text("Submit"),
          ),
          ElevatedButton(
            onPressed: () {
              authorController.clear();
              bookController.clear();
              setState(() {
                author = null;
                book = null;
                decodedImage = null;
              });
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
