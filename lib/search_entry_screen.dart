import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchEntryScreen extends StatefulWidget {
  const SearchEntryScreen({
    super.key,
    this.initialQuery = '',
    this.onBack,
    required this.onSearch,
  });

  final String initialQuery;
  final VoidCallback? onBack;
  final ValueChanged<String> onSearch;

  @override
  State<SearchEntryScreen> createState() => _SearchEntryScreenState();
}

class _SearchEntryScreenState extends State<SearchEntryScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final query = value.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o que você deseja pesquisar.')),
      );
      return;
    }
    widget.onSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FDFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.chevron_left_rounded, size: 28),
                    color: const Color(0xFF19354B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Buscar atendimento',
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF19354B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'O que você procura?',
                style: GoogleFonts.manrope(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF19354B),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Pesquise por clínica, médico, exame ou especialidade.',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: const Color(0xFF627389),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: _submit,
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  color: const Color(0xFF19354B),
                ),
                decoration: InputDecoration(
                  hintText: 'Ex.: Clínica Vida, cardiologia, hemograma',
                  hintStyle: GoogleFonts.manrope(
                    fontSize: 13,
                    color: const Color(0xFF718096),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF2743BA),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFE3F2FD),
                  contentPadding: const EdgeInsets.symmetric(vertical: 17),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFDCE3EF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFDCE3EF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: Color(0xFF2743BA),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
