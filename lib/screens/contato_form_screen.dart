import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';
import '../models/contato.dart';

class ContatoFormScreen extends StatefulWidget {
  final Contato? contato;

  const ContatoFormScreen({super.key, this.contato});

  @override
  State<ContatoFormScreen> createState() => _ContatoFormScreenState();
}

class _ContatoFormScreenState extends State<ContatoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _favorito = false;
  bool _salvando = false;

  bool get _editando => widget.contato != null;

  @override
  void initState() {
    super.initState();
    if (_editando) {
      _nomeCtrl.text = widget.contato!.nome;
      _telefoneCtrl.text = widget.contato!.telefone;
      _emailCtrl.text = widget.contato!.email ?? '';
      _favorito = widget.contato!.favorito;
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _telefoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final agora = DateTime.now().toIso8601String();
    try {
      if (_editando) {
        final atualizado = widget.contato!.copyWith(
          nome: _nomeCtrl.text.trim(),
          telefone: _telefoneCtrl.text.trim(),
          email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
          favorito: _favorito,
        );
        await DatabaseHelper.instance.atualizarContato(atualizado);
      } else {
        final novo = Contato(
          nome: _nomeCtrl.text.trim(),
          telefone: _telefoneCtrl.text.trim(),
          email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
          favorito: _favorito,
          criadoEm: agora,
        );
        await DatabaseHelper.instance.criarContato(novo);
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar Contato' : 'Novo Contato'),
        actions: [
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar preview
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.7)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _nomeCtrl.text.isEmpty
                          ? '?'
                          : _nomeCtrl.text
                              .trim()
                              .split(' ')
                              .take(2)
                              .map((w) => w.isNotEmpty ? w[0] : '')
                              .join()
                              .toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Nome
              _SectionLabel(label: 'Nome completo *'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nomeCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Ex: Maria Oliveira',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Informe o nome do contato';
                  }
                  if (v.trim().length < 2) {
                    return 'Nome muito curto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Telefone
              _SectionLabel(label: 'Telefone *'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _telefoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d\s\(\)\-\+]')),
                ],
                decoration: const InputDecoration(
                  hintText: 'Ex: (42) 99999-1234',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Informe o telefone';
                  }
                  final digits = v.replaceAll(RegExp(r'\D'), '');
                  if (digits.length < 8) {
                    return 'Número de telefone inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // E-mail (opcional)
              _SectionLabel(label: 'E-mail (opcional)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Ex: contato@email.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final emailRegex = RegExp(r'^[\w\.\+\-]+@\w+\.\w+');
                  if (!emailRegex.hasMatch(v.trim())) {
                    return 'E-mail inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Favorito
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _favorito
                        ? const Color(0xFFFFB347)
                        : Colors.grey.withOpacity(0.2),
                    width: _favorito ? 1.5 : 1,
                  ),
                ),
                child: SwitchListTile(
                  title: const Text('Marcar como favorito'),
                  subtitle: const Text('Aparece no topo da lista'),
                  secondary: Icon(
                    _favorito ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFFB347),
                  ),
                  value: _favorito,
                  activeColor: const Color(0xFFFFB347),
                  onChanged: (v) => setState(() => _favorito = v),
                ),
              ),
              const SizedBox(height: 32),

              // Botão salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _salvando ? null : _salvar,
                  icon: Icon(
                      _editando ? Icons.save_outlined : Icons.person_add),
                  label: Text(
                    _editando ? 'Salvar Alterações' : 'Criar Contato',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              if (_editando) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancelar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D2B55),
          ),
    );
  }
}
