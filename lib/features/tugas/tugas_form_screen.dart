import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/api/api_error.dart';
import '../../core/utils/date_format.dart';
import '../matkul/matkul_repository.dart';
import 'tugas.dart';
import 'tugas_repository.dart';

/// [tugas] null = tambah, terisi = edit.
class TugasFormScreen extends ConsumerStatefulWidget {
  const TugasFormScreen({super.key, this.tugas});
  final Tugas? tugas;

  @override
  ConsumerState<TugasFormScreen> createState() => _TugasFormScreenState();
}

class _TugasFormScreenState extends ConsumerState<TugasFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _judul = TextEditingController(text: widget.tugas?.judul);
  late final _deskripsi = TextEditingController(text: widget.tugas?.deskripsi);
  late int? _matkulId = widget.tugas?.matkulId;
  // Jam dinding WIB (komponen saja).
  late DateTime? _deadline = widget.tugas == null ? null : toWib(widget.tugas!.deadline);
  bool _deadlineError = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _judul.dispose();
    _deskripsi.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = toWib(DateTime.now());
    final cur = _deadline ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(cur.year, cur.month, cur.day),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: cur.hour, minute: cur.minute),
    );
    if (time == null) return;
    setState(() {
      _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _deadlineError = false;
    });
  }

  Future<void> _submit() async {
    final ok = _form.currentState!.validate();
    setState(() => _deadlineError = _deadline == null);
    if (!ok || _deadline == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = ref.read(tugasRepositoryProvider);
    final judul = _judul.text.trim();
    final desk = _deskripsi.text.trim();
    try {
      final t = widget.tugas;
      if (t == null) {
        await repo.create(judul, desk, _deadline!, _matkulId!);
      } else {
        await repo.update(t.id, judul, desk, _deadline!, _matkulId!);
      }
      ref.invalidate(tugasListProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) setState(() => _error = parseApiError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final matkul = ref.watch(matkulListProvider);
    final err = Theme.of(context).colorScheme.error;
    return Scaffold(
      appBar: AppBar(title: Text(widget.tugas == null ? 'Tambah Tugas' : 'Edit Tugas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TextFormField(
              controller: _judul,
              maxLength: 30,
              decoration: const InputDecoration(labelText: 'Judul', border: OutlineInputBorder()),
              validator: (v) => (v?.trim().isEmpty ?? true) ? 'Judul wajib diisi' : null,
            ),
            const SizedBox(height: 8),
            matkul.when(
              loading: () => const Padding(padding: EdgeInsets.all(12), child: LinearProgressIndicator()),
              error: (e, _) => Row(children: [
                Expanded(child: Text(parseApiError(e), style: TextStyle(color: err))),
                TextButton(onPressed: () => ref.invalidate(matkulListProvider), child: const Text('Coba lagi')),
              ]),
              data: (items) => items.isEmpty
                  ? const Text('Belum ada mata kuliah. Tambahkan dulu di tab Mata Kuliah.')
                  : DropdownButtonFormField<int>(
                      initialValue: items.any((m) => m.id == _matkulId) ? _matkulId : null,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Mata kuliah', border: OutlineInputBorder()),
                      items: [
                        for (final m in items)
                          DropdownMenuItem(value: m.id, child: Text('${m.kode} · ${m.nama}', overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (v) => setState(() => _matkulId = v),
                      validator: (v) => v == null ? 'Pilih mata kuliah' : null,
                    ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _deskripsi,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                  labelText: 'Deskripsi (opsional)', alignLabelWithHint: true, border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDeadline,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Deadline (WIB)',
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.event),
                  errorText: _deadlineError ? 'Deadline wajib diisi' : null,
                ),
                child: Text(_deadline == null ? 'Pilih tanggal & jam' : formatWib(wibToUtc(_deadline!))),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.brand.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Saat sisa waktunya kurang dari 24 jam, tugas ini otomatis ditandai dan naik ke paling atas.'),
                ),
              ]),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: err)),
            ],
            const SizedBox(height: 24),
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
