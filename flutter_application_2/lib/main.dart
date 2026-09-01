import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _operation = '';
  double _firstNumber = 0;
  bool _shouldResetDisplay = false;

  void _handleNumberPress(String number) {
    setState(() {
      if (_shouldResetDisplay) {
        _display = number;
        _shouldResetDisplay = false;
      } else {
        if (_display == '0' && number != '.') {
          _display = number;
        } else if (number == '.' && _display.contains('.')) {
          return;
        } else {
          _display += number;
        }
      }
    });
  }

  void _handleOperation(String operation) {
    setState(() {
      if (_operation.isNotEmpty && !_shouldResetDisplay) {
        _calculate();
      }
      _firstNumber = double.parse(_display);
      _operation = operation;
      _shouldResetDisplay = true;
    });
  }

  void _calculate() {
    if (_operation.isEmpty) return;

    double secondNumber = double.parse(_display);
    double result = 0;

    switch (_operation) {
      case '+':
        result = _firstNumber + secondNumber;
        break;
      case '-':
        result = _firstNumber - secondNumber;
        break;
      case '×':
        result = _firstNumber * secondNumber;
        break;
      case '÷':
        if (secondNumber != 0) {
          result = _firstNumber / secondNumber;
        } else {
          _display = 'Error';
          _operation = '';
          return;
        }
        break;
    }

    _display = result.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
    _operation = '';
    _shouldResetDisplay = true;
  }

  void _clear() {
    setState(() {
      _display = '0';
      _operation = '';
      _firstNumber = 0;
      _shouldResetDisplay = false;
    });
  }

  void _delete() {
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
      }
    });
  }

  void _handleEquals() {
    setState(() {
      _calculate();
      _shouldResetDisplay = true;
    });
  }

  Widget _buildButton(String label, VoidCallback onPressed,
      {Color? backgroundColor, Color? textColor}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.grey[300],
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor ?? Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[900],
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Text(
              _display,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ElevatedButton(
                            onPressed: _clear,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 54, 124, 244),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'C',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      _buildButton(
                        '⌫',
                        _delete,
                        backgroundColor: const Color.fromARGB(255, 48, 71, 147),
                        textColor: Colors.white,
                      ),
                      _buildButton(
                        '÷',
                        () => _handleOperation('÷'),
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('7', () => _handleNumberPress('7')),
                      _buildButton('8', () => _handleNumberPress('8')),
                      _buildButton('9', () => _handleNumberPress('9')),
                      _buildButton(
                        '×',
                        () => _handleOperation('×'),
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('4', () => _handleNumberPress('4')),
                      _buildButton('5', () => _handleNumberPress('5')),
                      _buildButton('6', () => _handleNumberPress('6')),
                      _buildButton(
                        '-',
                        () => _handleOperation('-'),
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('1', () => _handleNumberPress('1')),
                      _buildButton('2', () => _handleNumberPress('2')),
                      _buildButton('3', () => _handleNumberPress('3')),
                      _buildButton(
                        '+',
                        () => _handleOperation('+'),
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ElevatedButton(
                            onPressed: () => _handleNumberPress('0'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              '0',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      _buildButton('.', () => _handleNumberPress('.')),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ElevatedButton(
                            onPressed: _handleEquals,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              '=',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
