import 'dart:async';
import 'dart:io';
import 'package:recase/recase.dart';
import 'package:path/path.dart';

Future<int> gen(List<String> folders) async {
  Directory current = Directory.current;

  File _file = File('${current.path}/lib/app_assets.dart');

  String properties = '';
  String hasAsset = '\n';
  int total = 0;

  Map<String, bool> mark = {};

  for (int i = 0; i < folders.length; i++) {
    String folderName = folders[i];
    properties += '\n\t//Assets in $folderName\n';
    String dir = '${current.path}/assets/$folderName';
    List<FileSystemEntity> files = await getFilesInDir(Directory(dir));
    files.sort((a, b) => a.path.compareTo(b.path));

    for (int j = 0; j < files.length; j++) {
      FileSystemEntity e = files[j];
      String _property = basenameWithoutExtension(e.path).camelCase;
      String path = 'assets/$folderName/${basename(e.path)}';
      String property = _property;
      int count = 1;
      while (mark[property] == true) {
        property = '$_property$count';
        count++;
      }
      mark[property] = true;
      properties += """\tstatic const String $property = '$path';\n""";
      hasAsset += """\t'$path': true,\n""";
    }
    total += files.length;
  }

  await _file.writeAsString('''class AppAssets {$properties
  static const Map<String, bool> hasAsset = {$hasAsset};
}''');
  return total;
}

Future<List<FileSystemEntity>> getFilesInDir(Directory dir) {
  var files = <FileSystemEntity>[];
  var completer = Completer<List<FileSystemEntity>>();
  var lister = dir.list(recursive: false);
  lister.listen((file) => files.add(file),
      // should also register onError
      onDone: () => completer.complete(files));
  return completer.future;
}

Future<void> start() async {
  print('***[AssetHelper] STARTED ***');
  List<String> folders = ['images', 'icons'];
  int total = await gen(folders);
  print('***[AssetHelper] GENERATED ${folders.length} folders and $total files ***');
}

main() {
  start();
}
