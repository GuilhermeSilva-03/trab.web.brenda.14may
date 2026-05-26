import 'package:flutter/material.dart';
import 'contatos_screen.dart';
import 'notas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _telas = const [
    ContatosScreen(),
    NotasScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _telas,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          selectedIndex: _currentIndex,
          indicatorColor: colorScheme.primary.withOpacity(0.15),
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.contacts_outlined,
                  color: _currentIndex == 0
                      ? colorScheme.primary
                      : Colors.grey[500]),
              selectedIcon:
                  Icon(Icons.contacts, color: colorScheme.primary),
              label: 'Contatos',
            ),
            NavigationDestination(
              icon: Icon(Icons.note_alt_outlined,
                  color: _currentIndex == 1
                      ? colorScheme.primary
                      : Colors.grey[500]),
              selectedIcon:
                  Icon(Icons.note_alt, color: colorScheme.primary),
              label: 'Notas',
            ),
          ],
        ),
      ),
    );
  }
}
