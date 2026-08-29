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

## 2026-08-29 - First Terraform loop (destroy/recreate proven)

Phase 2 milestone: full IaC loop working against libvirt.

**The provider version mistake.**
Set `version = "~> 0.8"` in required_providers, thinking that meant 0.8.x.
It actually means "0.8.x or higher within 0.x," which let Terraform install
v0.9.8 — a provider that had been completely rewritten with new syntax. All
my resource blocks failed validation because they used pre-0.9 syntax.
Fix: pinned to `~> 0.8.0` (three-part = only 0.8.x patches). Got v0.8.3.
Lesson: version constraints matter. `~> X.Y` and `~> X.Y.Z` behave very
differently. Also: community provider rewrites can invalidate every online
tutorial overnight — always check what version the docs are for.

**Cloud-init not included yet.**
VM boots but no user/SSH key = can't log in. Intentional for this pass —
testing the provisioning loop first, connectivity next session.

**The pieces:**
- libvirt_volume for base image (copies the qcow2 we downloaded manually)
- libvirt_volume for VM disk (copy-on-write overlay from base)
- libvirt_domain for the VM itself (1GB RAM, 1 vCPU, default network)

Terraform correctly built the dependency graph and created things in order.
UUID from Terraform state matched what virsh dominfo reported.

**Destroy/recreate cycle.**
Under 2 seconds each way. This is the payoff of IaC — infrastructure
becomes disposable. New UUID on recreate (52a695a0... vs fa8840b1...) —
that's correct behavior, a recreated VM is a fresh VM, not a resurrection.

**SELinux sVirt observation.**
Noticed the VM got auto-labeled with SELinux MCS categories
(svirt_t:s0:c315,c851). This is libvirt using SELinux to isolate VM
processes from each other and from the host — automatic because SELinux
is enforcing. Real security value from doing nothing except "don't disable
SELinux."

**Deprecation warnings ignored for now.**
libvirt provider defaulted to old machine type (pc-i440fx) and CPU model
(qemu64). Modern is q35 and host-passthrough. Non-blocking, revisit
when adding cloud-init.

**.gitignore update.**
Uncommented `.terraform.lock.hcl` so it gets committed. Lock file pins
provider versions/checksums — should be in git so anyone cloning gets
identical provider versions.

Next: cloud-init to inject user, SSH key, and hostname. Then SSH into
the VM to prove end-to-end connectivity.

Screenshots in screenshots/ directory.
