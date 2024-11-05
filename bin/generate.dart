import 'dart:async';
import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;

void main(List<String> args) {
  if (_isHelpCommand(args)) {
    _printHelperDisplay();
  } else {
    handleIconFiles(_generateOption(args));
  }
}

bool _isHelpCommand(List<String> args) {
  return args.length == 1 && (args[0] == '--help' || args[0] == '-h');
}

void _printHelperDisplay() {
  stdout.writeln('Usage: dart generate_icon_keys.dart [options]');
  stdout.writeln('Options:');
  stdout.writeln(
      '  --source-dir, -S  Folder containing icon files (default: assets/icons/)');
  stdout.writeln(
      '  --class-name, -c  The Class that contains the keys (default: AssetIcons)');
  stdout.writeln(
      '  --output-dir, -O  Output folder for the generated file (default: lib/generated)');
  stdout
      .writeln('  --output-file, -o  Output file name (default: icons.g.dart)');
}

GenerateOptions _generateOption(List<String> args) {
  var generateOptions = GenerateOptions();
  var parser = _generateArgParser(generateOptions);
  parser.parse(args);
  return generateOptions;
}

ArgParser _generateArgParser(GenerateOptions generateOptions) {
  var parser = ArgParser();

  parser.addOption('source-dir',
      abbr: 'S',
      defaultsTo: 'assets/icons/',
      callback: (String? x) => generateOptions.sourceDir = x,
      help: 'Folder containing icon files');
  parser.addOption('class-name',
      abbr: 'c',
      defaultsTo: 'AssetIcons',
      callback: (String? x) => generateOptions.className = x,
      help: 'The Class that contains the keys');
  parser.addOption('output-dir',
      abbr: 'O',
      defaultsTo: 'lib/generated',
      callback: (String? x) => generateOptions.outputDir = x,
      help: 'Output folder for the generated file');

  parser.addOption('output-file',
      abbr: 'o',
      defaultsTo: 'icons.g.dart',
      callback: (String? x) => generateOptions.outputFile = x,
      help: 'Output file name');

  return parser;
}

class GenerateOptions {
  String? sourceDir;
  String? className;
  String? outputDir;
  String? outputFile;

  @override
  String toString() {
    return 'sourceDir: $sourceDir, outputDir: $outputDir, outputFile: $outputFile className: $className';
  }
}

void handleIconFiles(GenerateOptions options) async {
  final current = Directory.current;
  final source = Directory.fromUri(Uri.parse(options.sourceDir!));
  final output = Directory.fromUri(Uri.parse(options.outputDir!));
  final sourcePath = Directory(path.join(current.path, source.path));
  final outputPath =
      Directory(path.join(current.path, output.path, options.outputFile));

  if (!await sourcePath.exists()) {
    print(sourcePath);
    stderr.writeln('Source path does not exist');
    return;
  }

  var files = await dirContents(sourcePath);
  if (files.isNotEmpty) {
    generateFile(files, outputPath, options);
  } else {
    stderr.writeln('Source path empty');
  }
}

Future<List<FileSystemEntity>> dirContents(Directory dir) {
  var files = <FileSystemEntity>[];
  var completer = Completer<List<FileSystemEntity>>();
  var lister = dir.list(recursive: false);
  lister.listen((file) => files.add(file),
      onDone: () => completer.complete(files));
  return completer.future;
}

void generateFile(List<FileSystemEntity> files, Directory outputPath,
    GenerateOptions options) async {
  var generatedFile = File(outputPath.path);
  if (!generatedFile.existsSync()) {
    generatedFile.createSync(recursive: true);
  }

  var classBuilder = StringBuffer();

  classBuilder.writeln('''
// DO NOT EDIT. This is code generated via a Dart script

abstract class ${options.className} {
''');

  for (var file in files) {
    final fileName = path.basenameWithoutExtension(file.path);
    final fileExtension = file.path.split(".").last.toString();
    final key = fileName.replaceAll('-', '_').replaceAll(' ', '_');
    classBuilder
        .writeln('  static const String $key = \'$fileName.$fileExtension\';');
  }

  classBuilder.writeln('}');
  generatedFile.writeAsStringSync(classBuilder.toString());

  stdout.writeln('All done! File generated in ${outputPath.path}');
}
