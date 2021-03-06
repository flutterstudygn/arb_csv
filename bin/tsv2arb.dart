import 'dart:convert';
import 'dart:io';

import 'package:arb_tsv/bundle.dart';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;

void main(List<String> arguments) {
  var outputDir = Directory.current;
  final parser = ArgParser();
  parser.addOption(
    'output-dir',
    abbr: 'o',
    defaultsTo: '.',
    help:
        'Set output directory for generated arb file. Create directory if given directory is not exists',
    valueHelp: 'output directory',
    callback: (path) {
      outputDir = Directory(path!);
      if (!outputDir.existsSync()) outputDir.createSync(recursive: true);
    },
  );

  final result = parser.parse(arguments);
  final targetDirectory =
      Directory(result.rest.isEmpty ? '.' : result.rest.first);

  if (!targetDirectory.existsSync() && !targetDirectory.path.contains('.tsv')) {
    print('Cannot find path specified which [$targetDirectory].');
    print(
        'Usage: tsv2arb [path of tsv file or directory containing tsv files] [options]');
    print(parser.usage);
    exit(0);
  }

  final tsvFiles = <File>{};

  if (targetDirectory.path.contains('.tsv')) {
    tsvFiles.add(File(targetDirectory.path));
  } else {
    tsvFiles.addAll(
      targetDirectory
          .listSync()
          .where((directory) => directory.path.contains('.tsv'))
          .map((directory) => File(directory.path)),
    );
  }

  for (final tsvFile in tsvFiles) {
    final bundle = Bundle.fromTsv(tsvFile.readAsStringSync());
    final fileName = tsvFile.path.split(r'\').last.split('.').first;
    final arbFile = File(path.join(outputDir.path, '$fileName.arb'));
    arbFile.writeAsStringSync(json.encode(bundle.arb));
  }
}
