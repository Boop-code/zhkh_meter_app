
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class MeterScanScreen extends StatefulWidget {
  const MeterScanScreen({super.key});

  @override
  State<MeterScanScreen> createState() => _MeterScanScreenState();
}

class _MeterScanScreenState extends State<MeterScanScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  final TextRecognizer _textRecognizer =
  TextRecognizer(script: TextRecognitionScript.latin);
  final TextEditingController _readingController = TextEditingController();

  bool _initializing = true;
  bool _processing = false;
  String? _errorMessage;
  String _recognizedText = '';
  List<CameraDescription> _cameras = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        throw Exception('Камеры на устройстве не найдены.');
      }

      final camera = _cameras.firstWhere(
            (item) => item.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _initializing = false;
        _errorMessage = null;
      });
    } on CameraException catch (error) {
      if (!mounted) return;

      setState(() {
        _initializing = false;
        _errorMessage = switch (error.code) {
          'CameraAccessDenied' =>
          'Нет доступа к камере. Разреши его в настройках приложения.',
          _ => 'Не удалось открыть камеру: ${error.description ?? error.code}',
        };
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _initializing = false;
        _errorMessage = 'Не удалось инициализировать камеру: $error';
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _cameraController = null;
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _captureAndRecognize() async {
    final controller = _cameraController;

    if (controller == null ||
        !controller.value.isInitialized ||
        _processing) {
      return;
    }

    setState(() {
      _processing = true;
      _errorMessage = null;
    });

    try {
      final imageFile = await controller.takePicture();
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final result = await _textRecognizer.processImage(inputImage);

      final recognizedText = result.text;
      final matches = RegExp(r'\d+(?:[.,]\d+)?')
          .allMatches(recognizedText)
          .map((match) => match.group(0)!)
          .toList();

      if (!mounted) return;

      setState(() {
        _recognizedText = recognizedText;

        if (matches.isNotEmpty) {
          _readingController.text = matches.first.replaceAll(',', '.');
          _readingController.selection = TextSelection.collapsed(
            offset: _readingController.text.length,
          );
        } else {
          _errorMessage =
          'Цифры не найдены. Попробуй сделать снимок ближе к табло.';
        }
      });
    } on CameraException catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
        'Ошибка камеры: ${error.description ?? error.code}';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Не удалось распознать текст: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    }
  }

  void _confirmReading() {
    final value = _readingController.text.trim().replaceAll(',', '.');
    final parsedValue = double.tryParse(value);

    if (parsedValue == null || parsedValue < 0) {
      setState(() {
        _errorMessage = 'Введи корректное неотрицательное показание.';
      });
      return;
    }

    Navigator.of(context).pop(parsedValue);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _textRecognizer.close();
    _readingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraController = _cameraController;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сканирование счётчика'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              height: 280,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: _initializing
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null && cameraController == null
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
                  : cameraController != null &&
                  cameraController.value.isInitialized
                  ? Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(cameraController),
                  Center(
                    child: Container(
                      width: 250,
                      height: 90,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.greenAccent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              )
                  : const Center(
                child: Text(
                  'Камера недоступна',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Направь камеру на дисплей счётчика. Постарайся, чтобы цифры '
                  'были чёткими и хорошо освещёнными.',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _initializing ||
                  _processing ||
                  cameraController == null ||
                  !cameraController.value.isInitialized
                  ? null
                  : _captureAndRecognize,
              icon: _processing
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.document_scanner_outlined),
              label: Text(
                _processing ? 'Распознавание...' : 'Сфотографировать и распознать',
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Распознанное показание',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _readingController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Проверь и исправь цифры',
                hintText: 'Например, 125.4',
                prefixIcon: Icon(Icons.speed_outlined),
              ),
              onChanged: (_) => setState(() {}),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            if (_recognizedText.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Весь распознанный текст',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              SelectableText(_recognizedText),
            ],
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _readingController.text.trim().isEmpty
                  ? null
                  : _confirmReading,
              child: const Text('Подтвердить показание'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
          ],
        ),
      ),
    );
  }
}
