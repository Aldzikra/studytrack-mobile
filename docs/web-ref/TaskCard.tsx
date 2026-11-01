import { Link } from "@tanstack/react-router";
import { formatDeadline, sisaLabel, terlambatLabel } from "../lib/date";
import type { Tugas } from "../types";
import { Badge } from "./Badge";
import { Button } from "./Button";
import { PencilIcon, TrashIcon } from "./icons";

interface TaskCardProps {
  tugas: Tugas;
  now: Date;
  busy?: boolean;
  index?: number;
  onToggle: (tugas: Tugas) => void;
  onDelete: (tugas: Tugas) => void;
}

// Kategori datang dari backend (deadline_category); di sini hanya dipetakan ke tampilan.
export function TaskCard({ tugas, now, busy, index = 0, onToggle, onDelete }: TaskCardProps) {
  const selesai = tugas.status === "selesai";
  const category = selesai ? "normal" : (tugas.deadline_category ?? "normal");
  const mendekati = category === "mendekati";
  const overdue = category === "overdue";

  const box = mendekati
    ? "border-2 border-mendekati bg-surface shadow-mendekati"
    : overdue
      ? "border border-dashed border-overdue-card-border bg-overdue-card-bg"
      : "border border-line bg-surface";

  const titleColor = selesai ? "text-muted" : overdue ? "text-overdue-fg" : "text-ink";
  const deadlineColor = selesai
    ? "font-semibold text-muted"
    : mendekati
      ? "font-bold text-mendekati-fg"
      : overdue
        ? "font-bold text-overdue line-through"
        : "font-semibold text-text-2";

  return (
    <article
      style={{ animationDelay: `${Math.min(index, 8) * 50}ms` }}
      className={`animate-fade-up flex flex-wrap items-center gap-3 rounded-card p-4 md:gap-4 md:px-5.5 md:py-5 ${box}`}
    >
      <div className="flex min-w-0 flex-[1_1_240px] flex-col gap-2 md:basis-90">
        <div className="flex flex-wrap items-center gap-1.5 md:gap-2">
          {mendekati && <Badge type="mendekati">{sisaLabel(tugas.deadline, now)}</Badge>}
          {overdue && <Badge type="overdue">{terlambatLabel(tugas.deadline, now)}</Badge>}
          {selesai ? (
            <Badge type="selesai">Selesai</Badge>
          ) : (
            <Badge type="belum">Belum</Badge>
          )}
        </div>
        <h3 className={`text-base font-bold md:text-lg ${titleColor}`}>{tugas.judul}</h3>
        <span className="text-[13px] text-muted md:text-sm">{tugas.matkul_nama}</span>
      </div>

      <div className="flex w-full flex-col gap-2.5 md:w-auto md:items-end">
        <span className={`text-[13px] md:text-sm ${deadlineColor}`}>{formatDeadline(tugas.deadline)}</span>
        <div className="flex items-center gap-1">
          <Link
            to="/tugas/$id/edit"
            params={{ id: String(tugas.id) }}
            aria-label={`Ubah ${tugas.judul}`}
            className="flex size-11 items-center justify-center rounded-control text-muted hover:bg-line hover:text-ink"
          >
            <PencilIcon />
          </Link>
          <button
            type="button"
            onClick={() => onDelete(tugas)}
            aria-label={`Hapus ${tugas.judul}`}
            className="flex size-11 cursor-pointer items-center justify-center rounded-control text-muted hover:bg-line hover:text-danger"
          >
            <TrashIcon />
          </button>
          <Button
            variant="secondary"
            disabled={busy}
            onClick={() => onToggle(tugas)}
            className={`ml-auto md:ml-1 ${selesai ? "text-muted" : ""}`}
          >
            {selesai ? "Batalkan selesai" : "Tandai selesai"}
          </Button>
        </div>
      </div>
    </article>
  );
}
