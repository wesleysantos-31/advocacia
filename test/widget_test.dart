import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:advocacia/theme.dart';
import 'package:advocacia/models/cliente.dart';
import 'package:advocacia/models/documento.dart';
import 'package:advocacia/widgets/campo_texto.dart';
import 'package:advocacia/widgets/cliente_card.dart';
import 'package:advocacia/widgets/documento_tile.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });
  // ─── Testes do Model Cliente ───────────────────────────────────────────────

  group('Cliente Model', () {
    test('fromJson cria cliente corretamente', () {
      final json = {
        'id': 1,
        'nome': 'João Silva',
        'cpf': '123.456.789-00',
        'rg': '1234567',
        'telefone': '(91) 99999-9999',
        'email': 'joao@email.com',
        'prioridade': true,
        'senha_gov': 'senha123',
      };

      final cliente = Cliente.fromJson(json);

      expect(cliente.id, 1);
      expect(cliente.nome, 'João Silva');
      expect(cliente.cpf, '123.456.789-00');
      expect(cliente.rg, '1234567');
      expect(cliente.telefone, '(91) 99999-9999');
      expect(cliente.email, 'joao@email.com');
      expect(cliente.prioridade, true);
      expect(cliente.senhaGov, 'senha123');
    });

    test('toJson converte cliente corretamente', () {
      final cliente = Cliente(
        nome: 'Maria Santos',
        cpf: '987.654.321-00',
        prioridade: false,
      );

      final json = cliente.toJson();

      expect(json['nome'], 'Maria Santos');
      expect(json['cpf'], '987.654.321-00');
      expect(json['prioridade'], false);
    });

    test('copyWith cria cópia com campos alterados', () {
      final original = Cliente(nome: 'Ana', cpf: '111.222.333-44');
      final copia = original.copyWith(nome: 'Ana Maria', prioridade: true);

      expect(copia.nome, 'Ana Maria');
      expect(copia.cpf, '111.222.333-44'); // mantém o original
      expect(copia.prioridade, true);
    });

    test('camposParaHistorico retorna mapa correto', () {
      final cliente = Cliente(
        nome: 'Pedro',
        cpf: '000.000.000-00',
        prioridade: true,
      );

      final campos = cliente.camposParaHistorico;

      expect(campos['Nome'], 'Pedro');
      expect(campos['CPF'], '000.000.000-00');
      expect(campos['Prioridade'], 'Sim');
    });

    test('fromJson com campos nulos não quebra', () {
      final json = {'nome': null, 'cpf': null};
      final cliente = Cliente.fromJson(json);

      expect(cliente.nome, '');
      expect(cliente.cpf, '');
      expect(cliente.prioridade, false);
    });
  });

  // ─── Testes do Model Documento ─────────────────────────────────────────────

  group('Documento Model', () {
    test('fromJson cria documento corretamente', () {
      final json = {
        'id': 1,
        'cliente_id': 10,
        'nome': 'rg_frente.pdf',
        'tipo': 'RG',
        'url': 'https://storage.example.com/rg.pdf',
      };

      final doc = Documento.fromJson(json);

      expect(doc.id, 1);
      expect(doc.clienteId, 10);
      expect(doc.nome, 'rg_frente.pdf');
      expect(doc.tipo, 'RG');
      expect(doc.url, 'https://storage.example.com/rg.pdf');
    });

    test('tipos contém todos os tipos de documento esperados', () {
      expect(Documento.tipos, contains('RG'));
      expect(Documento.tipos, contains('CPF'));
      expect(Documento.tipos, contains('Processo'));
      expect(Documento.tipos, contains('Laudo Médico'));
      expect(Documento.tipos, contains('Outro'));
    });
  });

  // ─── Testes do Theme ──────────────────────────────────────────────────────

  group('AppColors', () {
    test('cores principais estão definidas', () {
      expect(AppColors.primary, const Color(0xFF1B3A6B));
      expect(AppColors.gold, const Color(0xFFD4A843));
      expect(AppColors.error, const Color(0xFFD32F2F));
      expect(AppColors.success, const Color(0xFF2E7D32));
    });
  });

  group('AppTheme', () {
    testWidgets('tema é criado e aplicado sem erros', (tester) async {
      // Permite fetch em runtime (vai falhar silenciosamente no teste, mas não quebra)
      GoogleFonts.config.allowRuntimeFetching = true;
      final theme = AppTheme.theme;
      expect(theme, isNotNull);
      expect(theme.useMaterial3, true);
      expect(theme.colorScheme.primary, AppColors.primary);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(body: Text('Teste')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Teste'), findsOneWidget);

      // Restaura config para os próximos testes
      GoogleFonts.config.allowRuntimeFetching = false;
    });
  });

  // ─── Testes do Widget CampoTexto ──────────────────────────────────────────

  group('CampoTexto Widget', () {
    testWidgets('renderiza com label e ícone', (tester) async {
      final ctrl = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: Scaffold(
            body: CampoTexto(
              label: 'Nome Completo',
              controller: ctrl,
              icone: Icons.person,
            ),
          ),
        ),
      );

      expect(find.text('Nome Completo'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('aceita texto digitado', (tester) async {
      final ctrl = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: Scaffold(
            body: CampoTexto(
              label: 'CPF',
              controller: ctrl,
              icone: Icons.badge,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '12345678900');
      expect(ctrl.text, '12345678900');
    });
  });

  // ─── Testes do Widget ClienteCard ─────────────────────────────────────────

  group('ClienteCard Widget', () {
    testWidgets('exibe nome e CPF do cliente', (tester) async {
      final cliente = Cliente(
        id: 1,
        nome: 'Carlos Souza',
        cpf: '111.222.333-44',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: Scaffold(
            body: ClienteCard(
              cliente: cliente,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Carlos Souza'), findsOneWidget);
      expect(find.text('CPF: 111.222.333-44'), findsOneWidget);
    });

    testWidgets('exibe inicial do nome no avatar', (tester) async {
      final cliente = Cliente(id: 1, nome: 'Maria', cpf: '000');

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: Scaffold(
            body: ClienteCard(cliente: cliente, onTap: () {}),
          ),
        ),
      );

      expect(find.text('M'), findsOneWidget);
    });

    testWidgets('exibe badge de prioritário quando prioridade = true',
        (tester) async {
      final cliente = Cliente(
        id: 1,
        nome: 'Ana',
        cpf: '000',
        prioridade: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: Scaffold(
            body: ClienteCard(cliente: cliente, onTap: () {}),
          ),
        ),
      );

      expect(find.text('Prioritário'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('não exibe badge quando prioridade = false', (tester) async {
      final cliente = Cliente(
        id: 1,
        nome: 'João',
        cpf: '000',
        prioridade: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: Scaffold(
            body: ClienteCard(cliente: cliente, onTap: () {}),
          ),
        ),
      );

      expect(find.text('Prioritário'), findsNothing);
    });

    testWidgets('chama onTap ao clicar', (tester) async {
      bool clicou = false;
      final cliente = Cliente(id: 1, nome: 'Test', cpf: '000');

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: Scaffold(
            body: ClienteCard(
              cliente: cliente,
              onTap: () => clicou = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ClienteCard));
      expect(clicou, true);
    });
  });

  // ─── Testes do Widget DocumentoTile ────────────────────────────────────────

  group('DocumentoTile Widget', () {
    testWidgets('exibe nome e tipo do documento', (tester) async {
      final doc = Documento(
        id: 1,
        clienteId: 1,
        nome: 'rg_frente.pdf',
        tipo: 'RG',
        url: 'https://example.com/rg.pdf',
        createdAt: DateTime(2025, 1, 15, 10, 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: Scaffold(
            body: DocumentoTile(
              documento: doc,
              onVisualizar: () {},
              onBaixar: () {},
              onDeletar: () {},
            ),
          ),
        ),
      );

      expect(find.text('rg_frente.pdf'), findsOneWidget);
      expect(find.textContaining('RG'), findsOneWidget);
    });

    testWidgets('tem botões de visualizar e excluir', (tester) async {
      final doc = Documento(
        id: 1,
        clienteId: 1,
        nome: 'doc.pdf',
        tipo: 'Outro',
        url: 'https://example.com/doc.pdf',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: Scaffold(
            body: DocumentoTile(
              documento: doc,
              onVisualizar: () {},
              onBaixar: () {},
              onDeletar: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.open_in_new_rounded), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });
  });
}
