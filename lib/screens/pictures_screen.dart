import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/models/picture.dart';
import 'package:image_picker/image_picker.dart';

class PicturesScreen extends StatelessWidget {
  const PicturesScreen({Key? key}) : super(key: key);

  Future<List<Picture>> loadPictures() async {
    final storage = FirebaseStorage.instance;
    final listResult = await storage.ref().listAll();
    List<Picture> pictures = [];
    for (final ref in listResult.items) {
      final meta = await ref.getMetadata();
      pictures.add(
        Picture(
            name: ref.name,
            url: await ref.getDownloadURL(),
            bytesSize: meta.size ?? -1),
      );
    }
    return pictures;
  }

  Future uploadPicture() async {
    final result = await ImagePicker.platform.pickImage(
      source: ImageSource.gallery,
    );
    if (result == null) return;
    final file = File(result.path);
    final storage = FirebaseStorage.instance;
    try {
      await storage.ref(file.path.split('/').last).putFile(file);
    } catch (e) {
      print('ошибка');
      print(e);
    }
  }
  Future deletePicture(String name) async {
    final storage = FirebaseStorage.instance;
    await storage.ref(name).delete();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest auth'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              uploadPicture();
            },
            child: const Text('Загрузить фото'),
          ),
          FutureBuilder(
              future: loadPictures(),
              builder: (_, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final data = snapshot.data;
                if (data == null) return const Text('Произошла ошибка');
                return Expanded(
                  child: ListView.builder(
                    itemCount: data.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (_, index) {
                      final item = data[index];
                      return ListTile(
                        leading: Image.network(item.url),
                        title: Text(item.name),
                        subtitle: Text("${item.bytesSize} байт\n${item.url}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            deletePicture(item.name);
                          },
                        ),
                      );
                    },
                  ),
                );
              }),
        ],
      ),
    );
  }
}