import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../utils/setup_values.dart';

class SetupValuesScreen extends StatefulWidget {
  const SetupValuesScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SetupValuesScreenState();
}

class _SetupValuesScreenState extends State<SetupValuesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _maxHeightController = TextEditingController(text: '12');
  final TextEditingController _minHeightController = TextEditingController(text: '6');
  final TextEditingController _refHeightController = TextEditingController(text: '6');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _maxHeightController.dispose();
    _minHeightController.dispose();
    _refHeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller1 = TextEditingController(text: '6');
    TextEditingController _controller2 = TextEditingController(text: '6');
    TextEditingController _controller3 = TextEditingController(text: '6');


    return Scaffold(
      appBar: AppBar(
        title: const Text("Setup Values"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 10,
              children: [
                const Text(
                    "Define the height boundaries for pitches and the reference height to be used in field calibration",
                style: TextStyle(fontSize: 25)),
                Wrap(direction: Axis.horizontal, spacing: 160, children: [
                  SizedBox(
                      width: 140,
                      height: 200,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                                style: TextStyle(
                                    fontSize: 25, color: Colors.deepPurple),
                                'Max Height'),
                            TextFormField(
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 50),
                              controller: _maxHeightController,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a value';
                                }
                                final num? parsedValue = num.tryParse(value);
                                if (parsedValue == null || parsedValue <= 0) {
                                  return 'Enter a positive number';
                                }
                                return null;
                              },
                            )
                          ])),
                  SizedBox(
                      width: 140,
                      height: 200,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                                style: TextStyle(
                                    fontSize: 25, color: Colors.deepPurple),
                                'Min Height'),
                            TextFormField(
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 50),
                              controller: _minHeightController,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a value';
                                }
                                final num? parsedValue = num.tryParse(value);
                                if (parsedValue == null || parsedValue <= 0) {
                                  return 'Enter a positive number';
                                }
                                return null;
                              },
                            )
                          ])),
                  SizedBox(
                      width: 140,
                      height: 200,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                                style: TextStyle(
                                    fontSize: 25, color: Colors.deepPurple),
                                'Ref Height'),
                            TextFormField(
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 50),
                              controller: _refHeightController,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a value';
                                }
                                final num? parsedValue = num.tryParse(value);
                                if (parsedValue == null || parsedValue <= 0) {
                                  return 'Enter a positive number';
                                }
                                return null;
                              },
                            ),
                          ]))
                ]),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final double maxHeight =
                          double.parse(_maxHeightController.text);
                      final double minHeight =
                          double.parse(_minHeightController.text);
                      final double refHeight =
                          double.parse(_refHeightController.text);
                      if (minHeight >= maxHeight) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Minimum height must be less than maximum height'),
                          ),
                        );
                      } else {
                        Provider.of<SetupValues>(context, listen: false)
                            .setHeights(maxHeight, minHeight, refHeight);
                        Navigator.pushNamed(
                            context, '/setupScreen/cameraCalibrationCapture');
                      }
                    }
                  },
                  child: const Text(style: TextStyle(fontSize: 30), 'Start Calibration'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
