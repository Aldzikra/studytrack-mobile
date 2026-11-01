import type { ReactNode } from "react";
import { motion } from "motion/react";
import type { Variants } from "motion/react";
import { Logo } from "./Logo";

const container: Variants = {
  hidden: {},
  visible: {
    transition: {
      staggerChildren: 0.15,
    },
  },
};

const fadeUp: Variants = {
  hidden: {
    opacity: 0,
    y: 24,
  },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.6,
      ease: "easeOut",
    },
  },
};

export function AuthShell({ children }: { children: ReactNode }) {
  return (
    <div className="flex min-h-screen flex-col bg-surface md:flex-row">
      <section
        aria-hidden="true"
        className="relative flex h-75 shrink-0 flex-col justify-between overflow-hidden rounded-b-[28px] bg-brand-500 px-6 pt-8 pb-7 text-white md:h-auto md:flex-1 md:gap-10 md:rounded-none md:p-12"
      >
        {/* Shape 1 */}
        <motion.div
          initial={{ scale: 0, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{
            duration: 0.7,
            delay: 0.15,
            ease: "easeOut",
          }}
          className="absolute -top-15 -right-15 size-50 rounded-full bg-brand-400 md:-top-20 md:-right-20 md:size-70"
        />

        {/* Shape 2 */}
        <motion.div
          initial={{
            opacity: 0,
            x: 60,
            y: 60,
            rotate: 40,
          }}
          animate={{
            opacity: 1,
            x: 0,
            y: 0,
            rotate: 12,
          }}
          transition={{
            duration: 0.7,
            delay: 0.3,
            ease: "easeOut",
          }}
          className="absolute right-7 bottom-10 size-18 rounded-[18px] bg-brand-cyan-400 md:right-15 md:bottom-22 md:size-30 md:rounded-[28px]"
        />

        {/* Shape 3 */}
        <motion.div
          initial={{
            scale: 0,
            opacity: 0,
          }}
          animate={{
            scale: 1,
            opacity: 1,
          }}
          transition={{
            duration: 0.5,
            delay: 0.45,
            ease: "easeOut",
          }}
          className="absolute right-29 bottom-5.5 size-9 rounded-full bg-brand-lemon-200 md:right-50 md:bottom-10 md:size-16"
        />

        {/* Content */}
        <motion.div
          variants={container}
          initial="hidden"
          animate="visible"
          className="relative flex h-full flex-col justify-between"
        >
          <motion.div variants={fadeUp}>
            <Logo tone="light" size="sm" />
          </motion.div>

          <div className="max-w-60 md:max-w-105">
            <motion.h2
              variants={fadeUp}
              className="text-[28px] leading-[1.15] font-extrabold tracking-tight md:text-[40px]"
            >
              Semua tugas kuliah, satu daftar.
            </motion.h2>

            <motion.p
              variants={fadeUp}
              className="mt-3 hidden text-[17px] leading-relaxed md:block"
            >
              Deadline yang tinggal kurang dari 24 jam langsung naik ke paling
              atas, jadi tidak ada yang terlewat.
            </motion.p>
          </div>
        </motion.div>
      </section>

      <main className="flex flex-1 items-stretch justify-center px-6 pt-7 pb-8 md:items-center md:p-12">
        <div className="flex w-full max-w-100 flex-col">{children}</div>
      </main>
    </div>
  );
}
