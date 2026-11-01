import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/api/api_error.dart';
import '../../shared/widgets/message_view.dart';
import 'matkul.dart';
import 'matkul_repository.dart';

class MatkulPage extends ConsumerWidget {
  const MatkulPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(matkulListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mata Kuliah')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const _MatkulForm(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Mata Kuliah'),
      ),
      body: list.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => MessageView(
          icon: Icons.cloud_off,
          text: parseApiError(e),
          action: FilledButton(
            onPressed: () => ref.invalidate(matkulListProvider),
            child: const Text('Coba lagi'),
          ),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: () => ref.refresh(matkulListProvider.future),
          child: items.isEmpty
              ? const MessageView(icon: Icons.menu_book_outlined, text: 'Belum ada mata kuliah.')
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _MatkulTile(items[i]),
                ),
        ),
      ),
    );
  }
}

class _MatkulTile extends StatelessWidget {
  const _MatkulTile(this.m);
  final Matkul m;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(m.nama, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('${m.kode} · ${m.dosen}', style: t.bodySmall?.copyWith(color: AppColors.muted)),
      ]),
    );
  }
}

class _MatkulForm extends ConsumerStatefulWidget {
  const _MatkulForm();

  @override
  ConsumerState<_MatkulForm> createState() => _MatkulFormState();
}

class _MatkulFormState extends ConsumerState<_MatkulForm> {
  final _form = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _kode = TextEditingController();
  final _dosen = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nama.dispose();
    _kode.dispose();
    _dosen.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(matkulRepositoryProvider).create(_nama.text.trim(), _kode.text.trim(), _dosen.text.trim());
      ref.invalidate(matkulListProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      final dup = e is DioException && e.response?.statusCode == 409;
      if (mounted) setState(() => _error = dup ? 'Kode mata kuliah sudah dipakai.' : parseApiError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _required(String? v, String label) => (v?.trim().isEmpty ?? true) ? '$label wajib diisi' : null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Tambah Mata Kuliah',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nama,
              maxLength: 50,
              decoration: const InputDecoration(labelText: 'Nama', border: OutlineInputBorder()),
              validator: (v) => _required(v, 'Nama'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _kode,
              maxLength: 10,
              decoration: const InputDecoration(labelText: 'Kode', border: OutlineInputBorder()),
              validator: (v) => _required(v, 'Kode'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _dosen,
              maxLength: 30,
              decoration: const InputDecoration(labelText: 'Dosen', border: OutlineInputBorder()),
              validator: (v) => _required(v, 'Dosen'),
              onFieldSubmitted: (_) => _submit(),
            ),
            if (_error != null) ...[
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Simpan'),
            ),
          ]),
        ),
      ),
    );
  }
}
