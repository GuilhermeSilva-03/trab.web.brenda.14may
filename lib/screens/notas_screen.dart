import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/nota.dart';
import 'nota_form_screen.dart';

class NotasScreen extends StatefulWidget {
  const NotasScreen({super.key});

  @override
  State<NotasScreen> createState() => _NotasScreenState();
}

class _NotasScreenState extends State<NotasScreen> {
  List<Nota> _notas = [];
  bool _loading = true;
  final TextEditingController _buscaCtrl = TextEditingController();
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    _carregarNotas();
    _buscaCtrl.addListener(() {
      setState(() => _filtro = _buscaCtrl.text);
      _carregarNotas(filtro: _buscaCtrl.text);
    });
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarNotas({String? filtro}) async {
    setState(() => _loading = true);
    final lista = await DatabaseHelper.instance.buscarNotas(filtro: filtro);
    setState(() {
      _notas = lista;
      _loading = false;
    });
  }

  Future<void> _deletarNota(Nota nota) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir Nota'),
        content: Text('Deseja excluir "${nota.titulo}" permanentemente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar == true && nota.id != null) {
      await DatabaseHelper.instance.deletarNota(nota.id!);
      await _carregarNotas(filtro: _filtro);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nota excluída')),
        );
      }
    }
  }

  Future<void> _abrirNota({Nota? nota}) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NotaFormScreen(nota: nota),
      ),
    );
    if (resultado == true) {
      await _carregarNotas(filtro: _filtro);
    }
  }

  String _formatarData(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat("dd/MM/yy 'às' HH:mm", 'pt_BR').format(dt);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: const Color(0xFFFF6584),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Bloco de Notas'),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF6584), Color(0xFFFF8E53)],
                  ),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Icon(
                      Icons.note_alt,
                      size: 80,
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Busca ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _buscaCtrl,
                decoration: InputDecoration(
                  hintText: 'Buscar notas...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _filtro.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _buscaCtrl.clear();
                            _carregarNotas();
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),

          // ── Contador ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                '${_notas.length} nota${_notas.length != 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),

          // ── Grade de Notas ────────────────────────────────────
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_notas.isEmpty)
            SliverFillRemaining(
              child: _EmptyNotasState(onAdd: () => _abrirNota()),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final nota = _notas[index];
                    return _NotaCard(
                      nota: nota,
                      dataFormatada: _formatarData(nota.atualizadoEm),
                      onTap: () => _abrirNota(nota: nota),
                      onDeletar: () => _deletarNota(nota),
                    );
                  },
                  childCount: _notas.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirNota(),
        backgroundColor: const Color(0xFFFF6584),
        icon: const Icon(Icons.note_add),
        label: const Text('Nova Nota'),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card de Nota
// ─────────────────────────────────────────────────────────────────────────────

const _notaColors = [
  Color(0xFFFFF9C4),
  Color(0xFFE8F5E9),
  Color(0xFFE3F2FD),
  Color(0xFFFCE4EC),
  Color(0xFFF3E5F5),
  Color(0xFFFFF3E0),
];

class _NotaCard extends StatelessWidget {
  final Nota nota;
  final String dataFormatada;
  final VoidCallback onTap;
  final VoidCallback onDeletar;

  const _NotaCard({
    required this.nota,
    required this.dataFormatada,
    required this.onTap,
    required this.onDeletar,
  });

  Color _cardColor() {
    final idx = (nota.titulo.codeUnitAt(0)) % _notaColors.length;
    return _notaColors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final cor = _cardColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    nota.titulo,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: onDeletar,
                  child: const Icon(Icons.close, size: 16, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (nota.imagemPath != null)
              Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(nota.imagemPath!),
                    fit: BoxFit.cover,
                    onError: (_, __) {},
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    nota.imagemPath!,
                    height: 60,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image,
                          color: Colors.grey, size: 24),
                    ),
                  ),
                ),
              ),
            if (nota.imagemPath == null)
              Expanded(
                child: Text(
                  nota.resumo,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF555555),
                        height: 1.4,
                      ),
                  overflow: TextOverflow.fade,
                ),
              ),
            const Spacer(),
            Text(
              dataFormatada,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estado vazio
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyNotasState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyNotasState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_alt_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma nota ainda',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque em "Nova Nota" para criar',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
