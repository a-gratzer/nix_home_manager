---
name: ansible
description: >-
  Ansible automation for infrastructure as code — playbook authoring,
  role creation, inventory management, vault encryption, and
  troubleshooting. Use this skill whenever the user mentions Ansible,
  playbooks, roles, ansible-vault, Molecule testing, infrastructure
  automation, server provisioning, configuration management, or
  needs to debug a failing Ansible run. Also trigger on phrases
  like "automate this server setup", "provision with Ansible",
  "encrypt secrets for deployment", or when the user is working
  with YAML-based infrastructure tasks that follow Ansible patterns.
---

# Ansible Skills

This skill provides reusable patterns for common Ansible tasks. Each section is self-contained — use the one that matches the user's current need. The patterns follow idempotency best practices (every task should be safe to run multiple times) and the principle of least surprise (explicit tags, clear naming, and handlers for service restarts).

## Skill: Create a New Role

```bash
ansible-galaxy role init --init-path roles/ my_role
```

Structure:
```
roles/my_role/
├── defaults/main.yml     # Variables users can override
├── handlers/main.yml     # Service restarts, reloads
├── meta/main.yml         # Role metadata, dependencies
├── tasks/main.yml        # Main task list
├── templates/            # Jinja2 templates
├── tests/
│   ├── inventory
│   └── test.yml
└── vars/main.yml         # Internal variables (higher precedence)
```

Example `tasks/main.yml`:
```yaml
---
- name: Install required packages
  ansible.builtin.package:
    name: "{{ my_role_packages }}"
    state: present
  tags:
    - packages
    - my_role

- name: Deploy configuration
  ansible.builtin.template:
    src: config.j2
    dest: /etc/myapp/config.yml
    owner: root
    group: root
    mode: "0640"
  notify: restart myapp
  tags:
    - config
```

## Skill: Write a Playbook

```yaml
---
- name: Deploy web application
  hosts: webservers
  become: true
  gather_facts: true

  vars:
    app_port: 8080
    app_version: "1.2.3"

  pre_tasks:
    - name: Update apt cache (Debian)
      ansible.builtin.apt:
        update_cache: true
        cache_valid_time: 3600
      when: ansible_os_family == "Debian"
      tags: always

  roles:
    - role: common
    - role: nginx
    - role: node_exporter

  tasks:
    - name: Deploy application binary
      ansible.builtin.copy:
        src: "files/app-{{ app_version }}.jar"
        dest: /opt/myapp/app.jar
        owner: appuser
        group: appuser
        mode: "0755"
      notify: restart myapp
      tags: deploy

  post_tasks:
    - name: Health check
      ansible.builtin.uri:
        url: "http://localhost:{{ app_port }}/health"
        status_code: 200
      register: health_result
      until: health_result.status == 200
      retries: 12
      delay: 5
      tags: verify
```

## Skill: Manage Secrets with Vault

```bash
# Create encrypted file
ansible-vault create vars/secrets.yml

# Edit existing encrypted file
ansible-vault edit vars/secrets.yml

# Encrypt existing file
ansible-vault encrypt vars/secrets.yml

# Decrypt
ansible-vault decrypt vars/secrets.yml

# Rekey (change password)
ansible-vault rekey vars/secrets.yml
```

Run playbook with vault:
```bash
ansible-playbook playbooks/site.yml --ask-vault-pass
# Or with password file (restrictive permissions!)
ansible-playbook playbooks/site.yml --vault-password-file .vault_pass
```

## Skill: Debug a Failing Play

```bash
# Step-by-step (confirm each task)
ansible-playbook playbooks/site.yml --step

# Verbose output
ansible-playbook playbooks/site.yml -vvv

# Start from a specific task
ansible-playbook playbooks/site.yml --start-at-task="Task name"

# Show diff of changes
ansible-playbook playbooks/site.yml --diff

# Check mode (dry run)
ansible-playbook playbooks/site.yml --check --diff
```

Debug task in playbook:
```yaml
- name: Debug variable
  ansible.builtin.debug:
    var: my_variable
    verbosity: 1
```

## Skill: Test with Molecule

```bash
# Initialize molecule for a role
cd roles/my_role
molecule init scenario --driver-name docker

# Run tests
molecule test           # Full: create, converge, verify, destroy
molecule converge       # Apply playbook
molecule verify         # Run tests
molecule login          # SSH into test container
molecule destroy        # Clean up
```

## Skill: Lint and Validate

```bash
# Syntax check
ansible-playbook playbooks/site.yml --syntax-check

# Ansible lint
ansible-lint playbooks/site.yml
ansible-lint roles/my_role/

# List hosts in inventory
ansible-inventory -i inventories/production --list --yaml

# List all tasks with tags
ansible-playbook playbooks/site.yml --list-tasks
ansible-playbook playbooks/site.yml --list-tags
```
