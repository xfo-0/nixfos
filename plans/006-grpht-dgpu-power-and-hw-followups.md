# 006 — grpht B580 dGPU power-park + toggle, and hardware follow-ups

Hand-authored 2026-06-20 (not `/improve`-generated). Host: **grpht** (Minisforum
BD795m, Ryzen 9 7945HX + AMD 610M iGPU, Intel Arc **B580** dGPU `xe` at PCI
`0000:03:00.0`, behind bridge chain `00:01.1→01:00.0→02:01.0→03:00.0`).
**Edit `~/nx` only.** Verify = `nix eval … grpht … drvPath` for the Nix side;
the power-state items can only be confirmed on the box.

## Landed in this change

`modules/den/aspects/system/hardware/intel-dgpu.nix` — facter-gated on an Arc
card (`hasArc`, same predicate as `graphics.nix`/`intel-xpu.nix`), so it only
activates where a `xe` card exists (= grpht today). Two parts:

- **Deep-idle floor at boot** — udev rule on `DRIVER=="xe"` bind sets
  `power/control=auto` (+ `d3cold_allowed=1`). The card runtime-suspends toward
  D3cold once nothing holds it, and auto-resumes on demand (Jellyfin transcode,
  Sunshine/Steam, compute). Display is on the AMD iGPU (`video=DP-1`), so
  suspending the B580 never touches the console.
- **`dgpu` toggle** (in `environment.systemPackages`, resolves the card via
  `/sys/bus/pci/drivers/xe/`, no hardcoded addr):
  - `dgpu status` — control/runtime state, **PCI `power_state`** (D0/D3hot/D3cold
    = the direct 0W probe; xe exposes no live wattage, only `power1_crit`),
    `d3cold_allowed`, accumulated idle time, render-node holders.
- **Default incidental rendering to the iGPU** — `WGPU_POWER_PREF = "low"` in
  `wm/niri/settings/environment.nix` (niri's own `environment` block).
  The B580 enumerates *first* (`renderD128`; iGPU is `renderD129`), so wgpu apps
  that request the highest-perf adapter (e.g. the `rio` terminal) grab the dGPU
  and pin it awake, defeating idle. `low` steers them to the iGPU; Steam/gamescope/
  Vulkan games are unaffected (wgpu-only; they use Vulkan directly).
  **Delivery gotcha:** `environment.sessionVariables` does NOT reach the session —
  niri is launched by the systemd *user manager* (verified: niri's PPid is
  `systemd`), which never sources `/etc/profile`/`/etc/set-environment`. The var
  must live in niri's env block. **Needs a full relog** (niri restart), not just a
  terminal restart. If `rio` still holds `renderD128` after, escalate to
  `WGPU_ADAPTER_NAME=Radeon`.
  **Escalated (2026-06-20, post-reboot verify):** `WGPU_POWER_PREF=low` reached
  the session (present in niri + rio env) but was *insufficient* — rio still
  rendered on the B580 (fdinfo: ~216 MiB `vram0` resident on `renderD128`),
  pinning it at `D0`. Added `WGPU_ADAPTER_NAME = "Radeon"` to niri's env block.
  Adapter names confirmed: iGPU = `AMD Radeon 610M (RADV RAPHAEL_MENDOCINO)`
  (matches `Radeon`), B580 = `Intel(R) Arc(tm) B580 Graphics (BMG G21)` (no match),
  `llvmpipe` also excluded. Needs `nh os switch` + full relog to take effect.
  - `dgpu on` — pin `power/control=on` (force awake; for a compute job you don't
    want autosuspending mid-run, or to claim it). Re-execs via `sudo`.
  - `dgpu off` — back to `power/control=auto` (release to deep idle).

Decisions baked in (from owner, 2026-06-20): goal is **0W idle with auto-wake**;
Jellyfin keeps the B580 available so **AV1/HEVC is there on wake**, with the
manual toggle on top. No `settings` option — facter-gated like its siblings;
to disable parking at runtime use `dgpu on`.

## On-box verification (after `nh os switch` to grpht)

1. **Does it actually park?** Idle the box, then `dgpu status`. Want
   `runtime=suspended`. If it never suspends, something holds the render node —
   `dgpu status` lists holders.
2. **0W (D3cold) vs few-W (D3hot)?** The open question — depends on whether the
   BD795m exposes ACPI `_PR3` for that slot (uncertain behind the bridge chain).
   - `dmesg | grep -iE 'd3cold|_PR3'` and `cat /sys/bus/pci/devices/0000:03:00.0/d3cold_allowed`.
   - If suspended state reports `D3cold` → rails gated, ~0W. If capped at `D3hot`
     → a few W idle; no software fix (it's firmware). Measure at the wall to confirm.
3. **Auto-wake works?** Start a Jellyfin HW transcode or a Steam/Sunshine session;
   `dgpu status` should flip to `active`, then back to `suspended` after.
   If resume is flaky (known Arc D3cold weakness) → fallback below.
4. **Fallback if D3cold resume is unreliable:** point Jellyfin HW accel at the
   **iGPU** instead so the B580 stays parked during playback, and reserve it for
   `dgpu on` + manual jobs. (Jellyfin device is UI state, see next section.)

## Jellyfin transcode device (UI state, not declarative)

`jellyfin.nix` doesn't pin a transcode device — it's set in Dashboard → Playback
→ Hardware acceleration (`/var/lib/jellyfin`, persisted). To use the B580:
- Accel: **Intel QuickSync (QSV)** (or VAAPI), device = the B580 render node.
- Identify it stably: `ls -l /dev/dri/by-path/pci-0000:03:00.0-render`
  (the iGPU is `pci-0000:09:00.0-render`). Don't trust `renderD128/129` ordering.

## oneAPI / PyTorch XPU (compute) — scaffold done, recipe + verify pending

Runtime is already provided: `graphics.nix` ships `intel-compute-runtime`,
`level-zero`, `vpl-gpu-rt`, `intel-media-driver`; `intel-xpu.nix` adds the nix-ld
libs (`level-zero`, `ocl-icd`, `numactl`, …) + `uv`. The missing piece is a
working venv + a real `torch.xpu.is_available()` check. Recipe to try on grpht:

```
mkdir -p ~/xpu && cd ~/xpu
uv venv --python 3.12 && . .venv/bin/activate
uv pip install torch --index-url https://download.pytorch.org/whl/xpu
python -c "import torch; print(torch.__version__, torch.xpu.is_available(), torch.xpu.get_device_name(0))"
```

nix-ld lets the manylinux wheels find `libstdc++`/`level-zero`/`ocl-icd`; the
Level-Zero loader + compute-runtime (NEO) are the XPU backend. If `is_available()`
is False, check `ZE_AFFINITY_MASK`/`clinfo`/`sycl-ls`, and that the pinned
`intel-compute-runtime` is new enough for **Battlemage** (NEO ≥ 24.x). For SYCL/
DPC++ "and others" beyond PyTorch, the full Intel oneAPI Base Toolkit is a
separate (bigger) packaging question — defer until there's a concrete need.

## Deferred hardware items (owner: "make note of, address later")

### A. Wake-on-LAN from full power-off (S5/G3)
OS side is done (`wake-on-lan.nix` arms `ethtool … wol g`; grpht MAC
`58:47:ca:7b:95:8d` set). From a *cold* power-off the rest is firmware:
- BIOS: **disable** "ErP Ready" / "Deep Sleep" / "EuP" (these cut NIC standby
  power → no WoL). **Enable** "Resume by PCI-E/PME" / "Wake on LAN".
- Verify NIC keeps WoL armed across shutdown: `ethtool <iface> | grep Wake-on`
  shows `g`; if it reverts on shutdown, add a `poweroff`-time re-arm.
- Test: `wol 58:47:ca:7b:95:8d` (or `etherwake`) from another tailnet host after
  a clean `poweroff`. Note: WoL over Wi-Fi/Tailscale won't traverse — needs a
  wired L2 path or a relay on the LAN.

### B. BD795m motherboard fan PWM (UEFI curve buggy)
UEFI fan curve unreliable → control from Linux via the Super-I/O hwmon chip.
- Identify it: `sudo sensors-detect` (BD795m Super-I/O is likely Nuvoton
  `nct6775`-family or ITE `it87`; may need `acpi_enforce_resources=lax` and/or
  loading the right module). Then `pwmconfig` maps `/sys/class/hwmon/*/pwm*`.
- Options (pick after ID): `lm_sensors` + `fancontrol`, `nbfc-linux`, or
  `fan2go`. Wire as a small aspect once the chip + pwm mapping are known.

### C. Intel B580 fan control
Arc dGPU fan control on Linux is firmware-managed — `xe` exposes hwmon (temp,
power, freq) but generally **no writable fan curve**. `lact` (already pulled in
via `roles.gaming`) can read sensors and adjust power limit, not the fan curve.
Likely nothing actionable now beyond monitoring temps under load; revisit if a
fan-control interface lands in `xe`/LACT. Power-limit capping via LACT is the
lever if it runs hot/loud under sustained compute.

### D. Storage tooling (done) + HDD spindown (already wired)
- **Tools (landed 2026-06-20):** `smartmontools` + `nvme-cli` + `hdparm` added to
  `apps/cli/tools/cli-tools.nix`, beside the existing `parted` — unconditional,
  reaches every host via `core`. **Deliberately not a facter-gated hardware
  aspect** (the `intel-dgpu` pattern): grpht's facter report (`hardware/facter.json`)
  is an install-time snapshot listing only 2× NVMe + a USB stick — it does **not**
  see the two SATA HDDs (`sda` 23.6T Seagate, `sdb` 3.6T Hitachi). Disks are
  dynamic; facter's disk view is stale, so gating disk tools on it mis-fits
  (would install `nvme-cli`, skip `hdparm`). The CLI bucket is the honest home —
  `parted` already established the precedent there.
- **Spindown:** already handled — `services/media/hd-idle.nix` runs `hd-idle`,
  configured on grpht for the Seagate (`ata-ST26000DM000-3Y8103_ZXA0XSXK`). The
  3.6T Hitachi `sdb` is **not** in `spinDownDisks` — add its by-id name there if
  it should park too.

### E. Slow boot — POST waits on SATA HDDs before Limine (firmware, not OS)
ESP/Limine live on `nvme0n1`; both HDDs are SATA **data** drives with no boot
entry. The delay is UEFI POST enumerating SATA before launching the bootloader —
pre-Linux, so **no OS package fixes it.** BD795m BIOS levers:
- **Fast Boot** = Enabled (skip thorough storage init).
- **Boot order**: NVMe (the 990 PRO with the ESP) first/only; drop/disable the
  two SATA HDDs as boot options (they have no entry anyway).
- If present: per-port "Storage Boot Option Control" / mark the HDD SATA ports as
  hot-plug / non-boot so POST doesn't wait on spin-up.
- CSM off (UEFI-only) trims POST further. (Note the ST26000DM000 is an SMR
  archive drive — slow spin-up is inherent; only POST waiting on it is fixable.)

### F. B580 vfio passthrough — feasible here, but mutually exclusive with host use
Probed 2026-06-20: the B580 is **alone in IOMMU group 17** (clean isolation, no
ACS-override needed) and reports `reset_method = flr bus` — **FLR works**, the
exact capability Arc cards historically lacked for reliable passthrough. So a
GPU-passthrough VM (vfio-pci + virt-manager) is genuinely viable on this box.
**But:** binding `xe → vfio-pci` hands the card to the VM and removes it from the
host — no Jellyfin HW transcode, no PyTorch XPU while passed through. It is *not*
a power solution: D3cold depth is firmware (`_PR3`), driver-agnostic; vfio reaches
no lower state than `xe` already can. The historical "must offload first to idle"
is the Optimus/bbswitch era — here it's already satisfied (display is on the AMD
iGPU, nothing pins the B580 except userspace, steered off via §WGPU vars). Treat
passthrough as a future *mode* to build only when a concrete VM need exists, not
alongside the host-park design.
