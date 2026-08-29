# Working log

## 2026-08-29 - Environment setup

Built AlmaLinux 10 VM in Hyper-V, 6GB RAM, 4 vCPU, nested virt enabled via PowerShell.
Went with Default Switch (not External) because FortiClient conflict from previous project.
Installed git, KVM/libvirt, rootless Podman, Terraform 1.16.
All installs clean. virt-host-validate PASS on VMX so nested virt is working.

Hit two issues: typo on libvirt install ("libvrt"), and virsh defaulted to session mode
instead of system mode — fixed by adding LIBVIRT_DEFAULT_URI to .bashrc.

## 2026-08-29 - libvirt storage and base image

Started Phase 2 (Terraform against libvirt).

libvirt didn't auto-create the default storage pool on AlmaLinux 10 — had to
define it manually. Three commands: pool-define-as, pool-start, pool-autostart.
Worth remembering: pool-define-as creates the definition, but you still have to
start it AND set autostart separately. Not one command.

Downloaded AlmaLinux 10 GenericCloud image (~547MB) directly into
/var/lib/libvirt/images/ with curl. First mistake: assumed libvirt would see
the file automatically. It didn't — vol-list came back empty.

Fixed with `virsh pool-refresh default`. Lesson: libvirt maintains its own
view of pool contents, separate from what's actually on disk. If you drop files
in via curl/cp/whatever, you have to refresh. Alternatively could have used
`virsh vol-create-from` or `virsh vol-upload` to keep libvirt in sync from the
start.

Storage pool now:
- default, active, autostart yes
- 34.55 GiB capacity, 31 GiB free
- One volume: almalinux-10-base.qcow2

Also learned: cloud images are a different animal from install ISOs. Pre-installed
minimal system + cloud-init for first-boot configuration. This is why VMs on
AWS/GCP can be provisioned by API without console access — same model.

Next: write first Terraform config to spin up one VM from this base image.
