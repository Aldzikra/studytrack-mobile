import { useState, type SubmitEvent } from "react";
import { Link } from "@tanstack/react-router";
import { Button } from "../components/Button";
import { ArrowRightIcon, PencilIcon, TrashIcon } from "../components/icons";
import { Input } from "../components/Input";
import { getApiError } from "../lib/api";
import { createMatkul, deleteMatkul, getMatkul, updateMatkul } from "../lib/matkul";
import { useFetch } from "../lib/useFetch";
import type { Matkul } from "../types";

const empty = { kode: "", nama: "", dosen: "" };

export function MatkulPage() {
  const { data, error: loadError, reload } = useFetch(getMatkul);

  const [form, setForm] = useState(empty);
  const [editingId, setEditingId] = useState<number>();
  const [error, setError] = useState("");
  const [saving, setSaving] = useState(false);

  const set = (key: keyof typeof empty) => (e: { target: { value: string } }) =>
    setForm((f) => ({ ...f, [key]: e.target.value }));

  function startEdit(m: Matkul) {
    setEditingId(m.id);
    setForm({ kode: m.kode, nama: m.nama, dosen: m.dosen });
    setError("");
    window.scrollTo({ top: 0, behavior: "smooth" });
  }

  function reset() {
    setEditingId(undefined);
    setForm(empty);
    setError("");
  }

  async function handleSubmit(e: SubmitEvent<HTMLFormElement>) {
    e.preventDefault();
    setError("");
    setSaving(true);

    try {
      if (editingId) await updateMatkul(editingId, form);
      else await createMatkul(form);

      reset();
      reload();
    } catch (err) {
      setError(getApiError(err));
    } finally {
      setSaving(false);
    }
  }

  async function remove(m: Matkul) {
    if (!window.confirm(`Hapus ${m.kode} · ${m.nama}? Semua tugas di mata kuliah ini ikut terhapus.`)) return;

    try {
      await deleteMatkul(m.id);
      if (editingId === m.id) reset();
      reload();
    } catch (err) {
      setError(getApiError(err));
    }
  }

  return (
    <div className="flex flex-col gap-5 md:gap-7">
      <header className="flex flex-col gap-1 md:gap-1.5">
        <span className="text-xs font-semibold text-muted md:text-[13px]">Semester berjalan</span>
        <h1 className="text-[26px] font-extrabold tracking-tight md:text-[32px]">Mata Kuliah</h1>
      </header>

      <form
        onSubmit={handleSubmit}
        aria-label={editingId ? "Ubah mata kuliah" : "Tambah mata kuliah"}
        className="flex flex-wrap items-end gap-3.5 rounded-card border border-line bg-surface p-4 md:px-5.5 md:py-5"
      >
        <div className="min-w-0 flex-[1_1_120px]">
          <Input label="Kode" placeholder="CS186" maxLength={10} required
            value={form.kode} onChange={set("kode")} />
        </div>
        <div className="min-w-0 flex-[3_1_200px]">
          <Input label="Nama mata kuliah" placeholder="Database Systems" maxLength={50} required
            value={form.nama} onChange={set("nama")} />
        </div>
        <div className="min-w-0 flex-[2_1_180px]">
          <Input label="Dosen pengampu" placeholder="Nama dosen" maxLength={30} required
            value={form.dosen} onChange={set("dosen")} />
        </div>

        <div className="flex w-full gap-2 md:w-auto">
          <Button type="submit" disabled={saving} className="flex-1 md:flex-none">
            {editingId ? "Simpan" : "Tambah"}
          </Button>
          {editingId && (
            <Button variant="secondary" onClick={reset}>
              Batal
            </Button>
          )}
        </div>

        {error && (
          <p role="alert" className="w-full rounded-control border border-danger-border bg-danger-bg px-3.5 py-2.5 text-sm font-semibold text-danger">
            {error}
          </p>
        )}
      </form>

      {loadError && <p role="alert" className="text-sm font-semibold text-danger">{loadError}</p>}
      {!data && !loadError && <p className="text-muted">Memuat mata kuliah…</p>}
      {data?.length === 0 && (
        <p className="rounded-card border border-line bg-surface p-6 text-center text-muted">
          Belum ada mata kuliah. Tambahkan lewat form di atas.
        </p>
      )}

      <section
        aria-label="Daftar mata kuliah"
        className="grid grid-cols-[repeat(auto-fill,minmax(260px,1fr))] gap-4"
      >
        {data?.map((m, i) => (
          <article key={m.id} style={{ animationDelay: `${Math.min(i, 8) * 50}ms` }} className="animate-fade-up flex flex-col gap-3.5 rounded-card border border-line bg-surface p-5">
            <div className="flex items-center justify-between gap-2">
              <span className="rounded-chip bg-brand-50 px-2.5 py-1.25 text-[13px] font-extrabold text-brand-600">
                {m.kode}
              </span>
              <div className="flex gap-1">
                <button type="button" onClick={() => startEdit(m)} aria-label={`Ubah ${m.kode}`}
                  className="flex size-11 cursor-pointer items-center justify-center rounded-control text-muted hover:bg-line hover:text-ink">
                  <PencilIcon />
                </button>
                <button type="button" onClick={() => remove(m)} aria-label={`Hapus ${m.kode}`}
                  className="flex size-11 cursor-pointer items-center justify-center rounded-control text-muted hover:bg-line hover:text-danger">
                  <TrashIcon />
                </button>
              </div>
            </div>
            <div className="flex flex-col gap-1">
              <h2 className="text-lg font-bold">{m.nama}</h2>
              <span className="text-sm text-muted">{m.dosen}</span>
            </div>
            <Link
              to="/"
              search={{ matkul: m.id }}
              className="group inline-flex min-h-11 items-center gap-1.5 self-start text-sm font-bold underline underline-offset-4"
            >
              Lihat tugas
              <ArrowRightIcon className="transition-transform group-hover:translate-x-1" />
            </Link>
          </article>
        ))}
      </section>
    </div>
  );
}
