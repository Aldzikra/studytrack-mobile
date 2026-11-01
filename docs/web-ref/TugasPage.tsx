import { useEffect, useState } from "react";
import { createPortal } from "react-dom";
import { Link, useNavigate, useSearch } from "@tanstack/react-router";
import { Button } from "../components/Button";
import { PlusIcon } from "../components/icons";
import { StatCard } from "../components/StatCard";
import { TaskCard } from "../components/TaskCard";
import { getApiError } from "../lib/api";
import { formatNow } from "../lib/date";
import { deleteTugas, getTugas, updateStatusTugas } from "../lib/tugas";
import { useFetch } from "../lib/useFetch";
import type { Tugas } from "../types";

const REFRESH_MS = 60_000;

function Section({ title, tone, items, render }: {
  title: string;
  tone: string;
  items: Tugas[];
  render: (t: Tugas, i: number) => React.ReactNode;
}) {
  if (items.length === 0) return null;

  return (
    <section className="flex flex-col gap-2.5 md:gap-3">
      <h2 className={`text-xs font-extrabold tracking-[0.06em] uppercase md:text-sm md:font-bold ${tone}`}>
        {title}
      </h2>
      {items.map((t, i) => render(t, i))}
    </section>
  );
}

export function TugasPage() {
  const navigate = useNavigate();
  const { matkul } = useSearch({ strict: false }) as { matkul?: number };
  const { data, error, reload } = useFetch(getTugas);

  const [now, setNow] = useState(() => new Date());
  const [busyId, setBusyId] = useState<number>();
  const [actionError, setActionError] = useState("");

  // Backend yang menghitung kategori, jadi muat ulang berkala agar tetap mutakhir.
  useEffect(() => {
    const timer = setInterval(() => {
      setNow(new Date());
      reload();
    }, REFRESH_MS);

    return () => clearInterval(timer);
  }, [reload]);

  async function toggle(t: Tugas) {
    setBusyId(t.id);
    setActionError("");

    try {
      await updateStatusTugas(t.id, t.status === "selesai" ? "belum" : "selesai");
      setNow(new Date());
      reload();
    } catch (err) {
      setActionError(getApiError(err));
    } finally {
      setBusyId(undefined);
    }
  }

  async function remove(t: Tugas) {
    if (!window.confirm(`Hapus tugas "${t.judul}"?`)) return;
    setActionError("");

    try {
      await deleteTugas(t.id);
      reload();
    } catch (err) {
      setActionError(getApiError(err));
    }
  }

  const all = data ?? [];
  const list = matkul ? all.filter((t) => t.matkul_id === matkul) : all;
  const filterNama = matkul ? all.find((t) => t.matkul_id === matkul)?.matkul_nama : undefined;

  // Urutan sudah dari backend; di sini hanya dikelompokkan per kategori.
  const mendekati = list.filter((t) => t.status !== "selesai" && t.deadline_category === "mendekati");
  const overdue = list.filter((t) => t.status !== "selesai" && t.deadline_category === "overdue");
  const lainnya = list.filter((t) => !mendekati.includes(t) && !overdue.includes(t));

  const renderCard = (t: Tugas, i: number) => (
    <TaskCard key={t.id} index={i} tugas={t} now={now} busy={busyId === t.id} onToggle={toggle} onDelete={remove} />
  );

  return (
    <div className="flex flex-col gap-5 md:gap-7">
      <header className="flex flex-wrap items-end justify-between gap-4">
        <div className="flex flex-col gap-1 md:gap-1.5">
          <span className="text-xs font-semibold text-muted md:text-[13px]">{formatNow(now)}</span>
          <h1 className="text-[26px] font-extrabold tracking-tight md:text-[32px]">Daftar Tugas</h1>
        </div>
        <Link to="/tugas/baru" className="hidden md:block">
          <Button className="gap-2">
            <PlusIcon /> Tambah Tugas
          </Button>
        </Link>
      </header>

      <section aria-label="Ringkasan" className="grid grid-cols-3 gap-2 md:gap-4">
        <StatCard tone="mendekati" count={mendekati.length} label="Mendekati" />
        <StatCard tone="overdue" count={overdue.length} label="Terlambat" />
        <StatCard tone="lainnya" count={lainnya.length} label="Lainnya" />
      </section>

      {matkul && (
        <div className="flex flex-wrap items-center gap-3 text-sm text-text-2">
          Mata kuliah: <strong>{filterNama ?? `#${matkul}`}</strong>
          <button
            type="button"
            onClick={() => void navigate({ to: "/", search: {} })}
            className="min-h-11 cursor-pointer font-bold text-brand-600"
          >
            Hapus filter
          </button>
        </div>
      )}

      {(error || actionError) && (
        <p role="alert" className="rounded-control border border-danger-border bg-danger-bg px-3.5 py-2.5 text-sm font-semibold text-danger">
          {actionError || error}
        </p>
      )}

      {!data && !error && <p className="text-muted">Memuat tugas…</p>}

      {data && list.length === 0 && (
        <div className="flex flex-col items-center gap-4 rounded-card border border-line bg-surface p-6 text-center">
          <p className="text-muted">Belum ada tugas. Tambahkan tugas pertamamu.</p>
          <Link to="/tugas/baru" className="md:hidden">
            <Button className="gap-2">
              <PlusIcon /> Tambah Tugas
            </Button>
          </Link>
        </div>
      )}

      <Section title="Mendekati deadline · kurang dari 24 jam" tone="text-mendekati-fg" items={mendekati} render={renderCard} />
      <Section title="Terlambat" tone="text-overdue-fg" items={overdue} render={renderCard} />
      <Section title="Tugas lainnya · terbaru di atas" tone="text-text-2" items={lainnya} render={renderCard} />

      {/* Portal: `fixed` tidak boleh di dalam pembungkus beranimasi (transform) */}
      {list.length > 0 &&
        createPortal(
        <Link
          to="/tugas/baru"
          aria-label="Tambah tugas"
          className="fixed right-5 bottom-24 z-10 flex size-14 animate-pop items-center justify-center rounded-[18px] bg-brand-600 text-white shadow-[0_8px_20px_rgb(26_95_214/0.35)] hover:bg-brand-700 hover:text-white md:hidden"
        >
          <PlusIcon width={24} height={24} />
        </Link>,
        document.body,
        )}
    </div>
  );
}
