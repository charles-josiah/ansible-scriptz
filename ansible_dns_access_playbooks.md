# 📘 Playbooks Ansible – Gerenciamento de DNS e Acesso SSH

Este documento reúne três playbooks essenciais para automação via Ansible em nossos servidores, além de instruções sobre criação do inventário e configuração de acesso sem senha via `ssh-copy-id`.

---

## 🔐 1. Playbook: Copiar chave pública SSH

Permite configurar autenticação sem senha para o usuário `root` em todos os servidores.

**Arquivo:** `copy_ssh_key.yml`

```yaml
- name: Copiar chave pública para os servidores
  hosts: all
  gather_facts: no
  tasks:
    - name: Adicionar chave pública ao authorized_keys
      authorized_key:
        user: root
        state: present
        key: "{{ lookup('file', '~/.ssh/id_rsa.pub') }}"

- name: Copiar chave pública para os servidores via ssh-copy-id
  hosts: all
  gather_facts: no
  vars:
    local_ssh_key: "{{ lookup('file', '~/.ssh/id_rsa.pub') }}"
  tasks:
    - name: Copiar chave via ssh-copy-id
      ansible.builtin.command: >
        ssh-copy-id -o StrictHostKeyChecking=no root@{{ inventory_hostname }}
      delegate_to: localhost
```

---

## 🔍 2. Playbook: Verificar DNS atual

Exibe o conteúdo atual de `/etc/resolv.conf` em todos os hosts.

**Arquivo:** `check_dns.yml`

```yaml
- name: Verificar DNS configurado
  hosts: all
  gather_facts: no
  tasks:
    - name: Mostrar conteúdo de /etc/resolv.conf
      command: cat /etc/resolv.conf
      register: resolv_output

    - name: Exibir DNS atual
      debug:
        var: resolv_output.stdout_lines
```

---

## 🔧 3. Playbook: Alterar DNS dos servidores

Cria um backup datado do arquivo de DNS e aplica nova configuração com os servidores `10.3.66.72` e `10.3.66.73`.

**Arquivo:** `change_dns.yml`

```yaml
- name: Alterar DNS para 10.3.66.72 e 10.3.66.73
  hosts: all
  become: yes
  gather_facts: no
  vars:
    data_hoje: "{{ lookup('pipe', 'date +%F') }}"  # formato: 2025-07-28
  tasks:
    - name: Backup do resolv.conf com data
      copy:
        src: /etc/resolv.conf
        dest: "/etc/resolv.conf.{{ data_hoje }}.bak"
        remote_src: yes

    - name: Configurar novo DNS
      copy:
        dest: /etc/resolv.conf
        content: |
          nameserver 10.3.66.72
          nameserver 10.3.66.73
```

---

## 📁 Inventário Ansible – Exemplo com grupos e nomes genéricos

**Arquivo:** `inventory_key.ini`

```ini
[web]
web01 ansible_host=10.0.0.10 ansible_user=root
web02 ansible_host=10.0.0.11 ansible_user=root
web03 ansible_host=10.0.0.12 ansible_user=root

[app]
app01 ansible_host=10.0.1.10 ansible_user=root
app02 ansible_host=10.0.1.11 ansible_user=root

[dev]
dev01 ansible_host=10.0.2.10 ansible_user=root

[remote]
asia01 ansible_host=10.0.3.10 ansible_user=root
asia02 ansible_host=10.0.3.11 ansible_user=root
asia-db01 ansible_host=10.0.3.12 ansible_user=root
asia-db02 ansible_host=10.0.3.13 ansible_user=root

[all:children]
web
app
dev
remote
```

---

## 🔑 Copiar chave SSH manualmente (alternativa ao Ansible)

Você pode copiar sua chave pública para um servidor com:

```bash
ssh-copy-id root@<ip-do-servidor>
```

> Exemplo:
> ```bash
> ssh-copy-id root@10.0.0.10
> ```

---

## ❓ Por que usar autenticação por chave SSH?

- ✅ **Segurança:** mais seguro que usar senhas (pode-se usar com passphrase).
- ⚙️ **Automação:** essencial para playbooks, scripts e CI/CD que precisam de acesso sem intervenção humana.
- 🚫 **Evita senhas no inventário:** reduz o risco de vazamento de credenciais em arquivos versionados.

---

## 🚀 Execução dos playbooks

```bash
ansible-playbook -i inventory_key.ini copy_ssh_key.yml
ansible-playbook -i inventory_key.ini check_dns.yml
ansible-playbook -i inventory_key.ini change_dns.yml
```

Ou por grupo específico:

```bash
ansible-playbook -i inventory_key.ini -l dev check_dns.yml
```

---

**Autor:** Charles Josiah Rusch Alandt - Y2hhcmxlcy5hbGFuZHRAZ21haWwuY29tCg==
**Atualizado em:** 2025-07-28
