# Working log

## 2026-08-29 - Environment setup

Built AlmaLinux 10 VM in Hyper-V, 6GB RAM, 4 vCPU, nested virt enabled via PowerShell.
Went with Default Switch (not External) because FortiClient conflict from previous project.
Installed git, KVM/libvirt, rootless Podman, Terraform 1.16.
All installs clean. virt-host-validate PASS on VMX so nested virt is working.

Hit two issues: typo on libvirt install ("libvrt"), and virsh defaulted to session mode
instead of system mode — fixed by adding LIBVIRT_DEFAULT_URI to .bashrc.

Next: write first Terraform config against libvirt provider, deploy a small nested VM.
