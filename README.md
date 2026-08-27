<<<<<<< HEAD
# CIS Microsoft Windows Server 2025 Stand-alone v1.0.0 L1 - Ansible over SSH

Proyecto de hardening generado a partir del archivo CIS `.audit` proporcionado.

## Arquitectura prevista

```text
Ubuntu / Ansible Control Node
          |
          | SSH TCP/22
          v
Windows Server 2025 + Microsoft OpenSSH Server
          |
          +-- DefaultShell = Windows PowerShell
          +-- ansible.windows / community.windows modules
          +-- CIS L1 hardening
```

**No se requiere WinRM.** El transporte utilizado por Ansible es
`ansible_connection=ssh`. Los modulos Windows siguen ejecutandose en el host
Windows; SSH solo sustituye el transporte que normalmente seria WinRM/PSRP.

## Requisitos

### Nodo Ubuntu

Se recomienda `ansible-core >= 2.18`, ya que es la version a partir de la cual
Windows sobre SSH cuenta con soporte oficial.

Comprueba:

```bash
ansible --version
```

Instala las colecciones:

```bash
ansible-galaxy collection install -r requirements.yml
```

### Windows Server 2025

- Microsoft OpenSSH Server instalado y activo.
- Puerto SSH accesible desde el nodo Ubuntu.
- `DefaultShell` de OpenSSH configurado a Windows PowerShell.
- La cuenta utilizada por Ansible debe tener privilegios administrativos.
- PowerShell 5.1 es suficiente para los modulos empleados en este proyecto.

Si tus servidores ya se administran correctamente desde Ansible por SSH y
PowerShell, no necesitas ejecutar ningun bootstrap adicional. En caso contrario,
se incluye:

```text
bootstrap/configure_openssh_for_ansible.ps1
```

Debe ejecutarse una sola vez desde una sesion PowerShell elevada en el servidor.

## Inventario SSH

Edita `inventory/hosts.ini`:

```ini
[windows_2025]
InntecProfact ansible_host=10.0.0.10 ansible_user=ansible-cis
Contpaq       ansible_host=10.0.0.11 ansible_user=ansible-cis

[windows_2025:vars]
ansible_connection=ssh
ansible_port=22
ansible_shell_type=powershell
ansible_ssh_private_key_file=~/.ssh/id_ed25519
```

El valor critico es:

```ini
ansible_shell_type=powershell
```

Debe coincidir con el `DefaultShell` de OpenSSH configurado en Windows.

## Prueba antes del hardening

Primero prueba conectividad:

```bash
ansible -i inventory/hosts.ini windows_2025 -m ansible.windows.win_ping
```

Despues prueba PowerShell:

```bash
ansible -i inventory/hosts.ini windows_2025 \
  -m ansible.windows.win_powershell \
  -a 'script="$PSVersionTable.PSVersion.ToString()"'
```

Y ejecuta el playbook inicialmente en modo comprobacion:

```bash
ansible-playbook -i inventory/hosts.ini site.yml --check --diff
```

> Nota: algunos modulos/politicas Windows no pueden representar todos sus cambios
> perfectamente en `--check`. Debe hacerse una primera ejecucion en laboratorio.

## Aplicacion

```bash
ansible-playbook -i inventory/hosts.ini site.yml
```

Para comenzar con una fase conservadora y omitir User Rights:

```bash
ansible-playbook -i inventory/hosts.ini site.yml \
  -e cis_apply_user_rights=false
```

## Seguridad de autenticacion SSH

Se recomienda autenticacion por clave en lugar de almacenar contraseñas en el
inventario. La clave privada debe permanecer unicamente en el nodo de control.

Para cuentas miembro del grupo local Administrators, OpenSSH en Windows puede
usar el archivo administrado por la configuracion de `sshd_config` para claves
de administradores. Si tu acceso SSH ya funciona, conserva el esquema existente.

## Controles incluidos

El rol contiene las categorias obtenidas del `.audit`, entre ellas:

- politicas de cuenta y contrasena;
- bloqueo de cuenta;
- controles de cuentas locales;
- User Rights Assignment;
- Advanced Audit Policy;
- configuraciones de registro;
- banner legal opcional;
- renombrado opcional de cuentas integradas.

Los controles potencialmente disruptivos siguen parametrizados. En particular,
los User Rights deben validarse contra servicios como IIS, SQL Server, agentes,
backups y cuentas de servicio antes de desplegarse masivamente.

## Preflight incluido

Antes de modificar el servidor, el rol valida:

1. que el control node tenga `ansible-core >= 2.18`;
2. que el destino sea Windows Server 2025;
3. que PowerShell pueda ejecutarse a traves de SSH;
4. que la cuenta remota tenga token administrativo.

Esto evita comenzar el hardening con una sesion SSH que no tenga permisos para
aplicar correctamente el benchmark.

## Estructura

```text
cis_windows_server_2025_standalone_l1_ansible/
├── ansible.cfg
├── site.yml
├── requirements.yml
├── control_manifest.yml
├── inventory/
│   └── hosts.ini
├── group_vars/
│   └── windows_2025.yml
├── bootstrap/
│   └── configure_openssh_for_ansible.ps1
└── roles/
    └── cis_windows_server_2025_l1/
        ├── defaults/main.yml
        ├── handlers/main.yml
        └── tasks/
            ├── main.yml
            ├── preflight.yml
            ├── account_policies.yml
            ├── local_accounts.yml
            ├── user_rights.yml
            ├── audit_policy.yml
            ├── registry.yml
            └── banner.yml
```
=======
# CIS-WindowsServer2025
>>>>>>> 7f87ba4712b63ddacfcc1762841bbbedb19f0158
