import 'package:flutter/material.dart'; //componenetes visuales

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget { // statelessWidget: Un widget inmutable que no almacena estado dinámico (su apariencia no cambia por sí sola una vez construida).
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

// Flutter divide las pantallas dinámicas en dos clases: el widget en sí (StatefulWidget) y su estado (State).
class MyHomePage extends StatefulWidget { //StatefulWidget: Permite que la pantalla cambie visualmente cuando los datos internos se actualizan
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
//LOGICA DE ESTADOS Y METODOS
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() { // incicia con _ : variable privada
    // setState(() { ... }): Notifica al framework que los datos internos han cambiado. Al llamarlo, Flutter vuelve a ejecutar el método build() para redibujar la interfaz con el nuevo valor de _counter.
    setState(() { 
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Proporciona el esqueleto visual estándar de una pantalla (barra superior, cuerpo y botones flotantes).
      appBar: AppBar( //La barra de navegación superior que muestra el texto widget.title.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center( //centrar
        child: Column( 
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset( //Muestra una imagen local del proyecto con 150 píxeles de alto (requiere estar declarada en el archivo pubspec.yaml).
              'assets/images/contador.jpg',
              height: 400,
            ),
            const SizedBox(height: 20),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      // floatingActionButton: Row(...): Coloca una fila horizontal alineada a la derecha (MainAxisAlignment.end) con tres botones flotantes (FloatingActionButton)
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _decrementCounter,
            tooltip: 'Restar',
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: _resetCounter,
            tooltip: 'Resetear',
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Sumar',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}