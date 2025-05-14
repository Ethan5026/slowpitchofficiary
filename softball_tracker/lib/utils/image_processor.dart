import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'dart:io';

// Corrected function type definitions to match C++ signatures
typedef ProcessImageNative = Pointer<Uint8> Function(
    Pointer<Uint8> inputData, Int32 inputLength, Pointer<Int32> outputLength);
typedef ProcessImageDart = Pointer<Uint8> Function(
    Pointer<Uint8> inputData, int inputLength, Pointer<Int32> outputLength);

typedef FreeMemoryNative = Void Function(Pointer<Uint8> ptr);
typedef FreeMemoryDart = void Function(Pointer<Uint8> ptr);

class ImageProcessor {
  final DynamicLibrary _nativeLib;
  late final ProcessImageDart _processImage;
  late final FreeMemoryDart _freeMemory;

  ImageProcessor()
      : _nativeLib = Platform.isAndroid
      ? DynamicLibrary.open("libnative-lib.so")
      : DynamicLibrary.process() {
    // Look up the C++ functions and cast them to the correct Dart function types
    _processImage = _nativeLib
        .lookup<NativeFunction<ProcessImageNative>>('process_image')
        .asFunction<ProcessImageDart>();

    _freeMemory = _nativeLib
        .lookup<NativeFunction<FreeMemoryNative>>('free_memory')
        .asFunction<FreeMemoryDart>();
  }

  Uint8List processImage(Uint8List inputImage) {
    // Allocate memory for the input image data
    final inputPointer = malloc.allocate<Uint8>(inputImage.length);
    inputPointer.asTypedList(inputImage.length).setAll(0, inputImage);

    // Allocate memory for the output length
    final outputLengthPointer = malloc.allocate<Int32>(1);

    // Call the C++ function to process the image
    final outputPointer = _processImage(inputPointer, inputImage.length, outputLengthPointer);

    // Get the length of the output data
    final outputLength = outputLengthPointer.value;

    // Copy the output data to a Uint8List
    final outputData = Uint8List.fromList(outputPointer.asTypedList(outputLength));

    // Free the allocated memory
    malloc.free(inputPointer);
    malloc.free(outputLengthPointer);
    _freeMemory(outputPointer);

    // Return the processed image as a Uint8List
    return outputData;
  }
}
