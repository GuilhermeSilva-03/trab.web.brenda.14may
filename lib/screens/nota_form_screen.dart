import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database/database_helper.dart';
import '../models/nota.dart';

class NotaFormScreen extends StatefulWidget {
  final Nota? nota;

  const NotaFormScreen({super.key, this.nota});

  @override
  State<NotaFormScreen> createState() => _NotaFormScreenState();
}

class _NotaFormScreenState extends State<NotaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _conteudoCtrl = TextEditingController();
  String? _imagemPath;
  bool _salvando = false;
  bool _alterado = false;

  bool get _editando => widget.nota != null;

  @override
  void initState() {
    super.initState();
    if (_editando) {
      _tituloCtrl.text = widget.nota!.titulo;
      _conteudoCtrl.text = widget.nota!.conteudo;
      _imagemPath = widget.nota!.imagemPath;
    }
    _tituloCtrl.addListener(() => setState(() => _alterado = true));
    _conteudoCtrl.addListener(() => setState(() => _alterado = true));
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _conteudoCtrl.dispose();
    super.dispose();
  }

  Future<void> _escolherImagem(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _imagemPath = picked.path;
          _alterado = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar imagem: $e')),
        );
      }
    }
  }

  void _mostrarOpcoesImagem() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anexar Imagem',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library,
                    color: Color(0xFF6C63FF)),
              ),
              title: const Text('Galeria de Fotos'),
              subtitle: const Text('Escolha uma imagem existente'),
              onTap: () {
                Navigator.pop(ctx);
                _escolherImagem(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6584).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt, color: Color(0xFFFF6584)),
              ),
              title: const Text('Câmera'),
              subtitle: const Text('Tirar uma nova foto'),
              onTap: () {
                Navigator.pop(ctx);
                _escolherImagem(ImageSource.camera);
              },
            ),
            if (_imagemPath != null) ...[
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                title: const Text('Remover Imagem',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _imagemPath = null;
                    _alterado = true;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final agora = DateTime.now().toIso8601String();
    try {
      if (_editando) {
        final atualizada = widget.nota!.copyWith(
          titulo: _tituloCtrl.text.trim(),
          conteudo: _conteudoCtrl.text.trim(),
          imagemPath: _imagemPath,
          clearImagem: _imagemPath == null,
          atualizadoEm: agora,
        );
        await DatabaseHelper.instance.atualizarNota(atualizada);
      } else {
        final nova = Nota(
          titulo: _tituloCtrl.text.trim(),
          conteudo: _conteudoCtrl.text.trim(),
          imagemPath: _imagemPath,
          criadoEm: agora,
          atualizadoEm: agora,
        );
        await DatabaseHelper.instance.criarNota(nova);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _salvando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_alterado) return true;
    final sair = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Descartar alterações?'),
        content: const Text(
            'Você fez alterações nesta nota. Deseja sair sem salvar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Continuar editando'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    return sair ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFBFF),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF6584),
          title: Text(_editando ? 'Editar Nota' : 'Nova Nota'),
          actions: [
            IconButton(
              onPressed: _mostrarOpcoesImagem,
              icon: Icon(
                _imagemPath != null ? Icons.image : Icons.add_photo_alternate,
                color: Colors.white,
              ),
              tooltip: 'Anexar imagem',
            ),
            if (_salvando)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                ),
              )
            else
              TextButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('Salvar',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              // Título
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: TextFormField(
                  controller: _tituloCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                  decoration: const InputDecoration(
                    hintText: 'Título da nota',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe um título';
                    }
                    return null;
                  },
                ),
              ),

              // Separador
              Container(
                height: 1,
                color: const Color(0xFFFF6584).withOpacity(0.2),
              ),

              // Imagem (se selecionada)
              if (_imagemPath != null)
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                      ),
                      child: Image.file(
                        File(_imagemPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image,
                              size: 48, color: Colors.grey),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _imagemPath = null;
                          _alterado = true;
                        }),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),

              // Conteúdo
              Expanded(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: TextFormField(
                    controller: _conteudoCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          color: const Color(0xFF333333),
                        ),
                    decoration: const InputDecoration(
                      hintText: 'Escreva sua nota aqui...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'A nota não pode estar vazia';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        // Botão de imagem na barra inferior
        bottomNavigationBar: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: _mostrarOpcoesImagem,
                icon: const Icon(Icons.add_photo_alternate,
                    color: Color(0xFFFF6584)),
                label: Text(
                  _imagemPath != null ? 'Trocar imagem' : 'Anexar imagem',
                  style: const TextStyle(color: Color(0xFFFF6584)),
                ),
              ),
              const Spacer(),
              Text(
                '${_conteudoCtrl.text.length} caracteres',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
