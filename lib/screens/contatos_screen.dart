import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/contato.dart';
import 'contato_form_screen.dart';

class ContatosScreen extends StatefulWidget {
  const ContatosScreen({super.key});

  @override
  State<ContatosScreen> createState() => _ContatosScreenState();
}

class _ContatosScreenState extends State<ContatosScreen> {
  List<Contato> _contatos = [];
  bool _loading = true;
  final TextEditingController _buscaCtrl = TextEditingController();
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    _carregarContatos();
    _buscaCtrl.addListener(() {
      setState(() => _filtro = _buscaCtrl.text);
      _carregarContatos(filtro: _buscaCtrl.text);
    });
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarContatos({String? filtro}) async {
    setState(() => _loading = true);
    final lista =
        await DatabaseHelper.instance.buscarContatos(filtro: filtro);
    setState(() {
      _contatos = lista;
      _loading = false;
    });
  }

  Future<void> _deletarContato(Contato contato) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir Contato'),
        content:
            Text('Deseja excluir "${contato.nome}" permanentemente?'),
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
    if (confirmar == true && contato.id != null) {
      await DatabaseHelper.instance.deletarContato(contato.id!);
      await _carregarContatos(filtro: _filtro);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contato excluído')),
        );
      }
    }
  }

  Future<void> _toggleFavorito(Contato contato) async {
    final atualizado = contato.copyWith(favorito: !contato.favorito);
    await DatabaseHelper.instance.atualizarContato(atualizado);
    await _carregarContatos(filtro: _filtro);
  }

  Future<void> _abrirFormulario({Contato? contato}) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ContatoFormScreen(contato: contato),
      ),
    );
    if (resultado == true) {
      await _carregarContatos(filtro: _filtro);
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
            backgroundColor: colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Contatos'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withBlue(220),
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Icon(
                      Icons.contacts,
                      size: 80,
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Barra de Busca ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _buscaCtrl,
                decoration: InputDecoration(
                  hintText: 'Buscar por nome ou telefone...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _filtro.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _buscaCtrl.clear();
                            _carregarContatos();
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
                '${_contatos.length} contato${_contatos.length != 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),

          // ── Lista ─────────────────────────────────────────────
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_contatos.isEmpty)
            SliverFillRemaining(
              child: _EmptyState(onAdd: () => _abrirFormulario()),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final contato = _contatos[index];
                  return _ContatoCard(
                    contato: contato,
                    onEditar: () => _abrirFormulario(contato: contato),
                    onDeletar: () => _deletarContato(contato),
                    onFavorito: () => _toggleFavorito(contato),
                  );
                },
                childCount: _contatos.length,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.person_add),
        label: const Text('Novo Contato'),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card de Contato
// ─────────────────────────────────────────────────────────────────────────────

class _ContatoCard extends StatelessWidget {
  final Contato contato;
  final VoidCallback onEditar;
  final VoidCallback onDeletar;
  final VoidCallback onFavorito;

  const _ContatoCard({
    required this.contato,
    required this.onEditar,
    required this.onDeletar,
    required this.onFavorito,
  });

  static const _avatarColors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6584),
    Color(0xFF43C6AC),
    Color(0xFFFFB347),
    Color(0xFF4FC3F7),
    Color(0xFFCE93D8),
  ];

  Color _avatarColor() {
    final idx = contato.nome.codeUnitAt(0) % _avatarColors.length;
    return _avatarColors[idx];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Card(
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: _avatarColor(),
            radius: 26,
            child: Text(
              contato.iniciais,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  contato.nome,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (contato.favorito)
                const Icon(Icons.star, color: Color(0xFFFFB347), size: 18),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.phone, size: 13, color: Color(0xFF7B78A8)),
                  const SizedBox(width: 4),
                  Text(contato.telefone),
                ],
              ),
              if (contato.email != null && contato.email!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.email, size: 13, color: Color(0xFF7B78A8)),
                    const SizedBox(width: 4),
                    Expanded(
                        child: Text(contato.email!,
                            overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ],
          ),
          trailing: PopupMenuButton<String>(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'editar') onEditar();
              if (value == 'favorito') onFavorito();
              if (value == 'deletar') onDeletar();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'editar',
                child: ListTile(
                  leading: Icon(Icons.edit, color: Color(0xFF6C63FF)),
                  title: Text('Editar'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'favorito',
                child: ListTile(
                  leading: Icon(
                    contato.favorito ? Icons.star_border : Icons.star,
                    color: const Color(0xFFFFB347),
                  ),
                  title: Text(
                      contato.favorito ? 'Remover favorito' : 'Favoritar'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'deletar',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Excluir', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          onTap: onEditar,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estado vazio
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.contacts, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Nenhum contato encontrado',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque em "Novo Contato" para adicionar',
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),
        ],
      ),
    );
  }
}
