import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contato.dart';
import '../models/nota.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('agenda.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contatos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        telefone TEXT NOT NULL,
        email TEXT,
        favorito INTEGER NOT NULL DEFAULT 0,
        criado_em TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        conteudo TEXT NOT NULL,
        imagem_path TEXT,
        criado_em TEXT NOT NULL,
        atualizado_em TEXT NOT NULL
      )
    ''');
  }

  // ─── CONTATOS ────────────────────────────────────────────────

  Future<Contato> criarContato(Contato contato) async {
    final db = await instance.database;
    final id = await db.insert('contatos', contato.toMap());
    return contato.copyWith(id: id);
  }

  Future<List<Contato>> buscarContatos({String? filtro}) async {
    final db = await instance.database;
    List<Map<String, dynamic>> maps;
    if (filtro != null && filtro.isNotEmpty) {
      maps = await db.query(
        'contatos',
        where: 'nome LIKE ? OR telefone LIKE ?',
        whereArgs: ['%$filtro%', '%$filtro%'],
        orderBy: 'favorito DESC, nome ASC',
      );
    } else {
      maps = await db.query('contatos', orderBy: 'favorito DESC, nome ASC');
    }
    return maps.map((e) => Contato.fromMap(e)).toList();
  }

  Future<int> atualizarContato(Contato contato) async {
    final db = await instance.database;
    return db.update(
      'contatos',
      contato.toMap(),
      where: 'id = ?',
      whereArgs: [contato.id],
    );
  }

  Future<int> deletarContato(int id) async {
    final db = await instance.database;
    return await db.delete('contatos', where: 'id = ?', whereArgs: [id]);
  }

  // ─── NOTAS ────────────────────────────────────────────────────

  Future<Nota> criarNota(Nota nota) async {
    final db = await instance.database;
    final id = await db.insert('notas', nota.toMap());
    return nota.copyWith(id: id);
  }

  Future<List<Nota>> buscarNotas({String? filtro}) async {
    final db = await instance.database;
    List<Map<String, dynamic>> maps;
    if (filtro != null && filtro.isNotEmpty) {
      maps = await db.query(
        'notas',
        where: 'titulo LIKE ? OR conteudo LIKE ?',
        whereArgs: ['%$filtro%', '%$filtro%'],
        orderBy: 'atualizado_em DESC',
      );
    } else {
      maps = await db.query('notas', orderBy: 'atualizado_em DESC');
    }
    return maps.map((e) => Nota.fromMap(e)).toList();
  }

  Future<int> atualizarNota(Nota nota) async {
    final db = await instance.database;
    return db.update(
      'notas',
      nota.toMap(),
      where: 'id = ?',
      whereArgs: [nota.id],
    );
  }

  Future<int> deletarNota(int id) async {
    final db = await instance.database;
    return await db.delete('notas', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
