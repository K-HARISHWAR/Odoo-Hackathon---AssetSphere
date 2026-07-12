import os
import re

sql_dir = os.path.join('database', 'sql')

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    
    # 1. Fix Triggers
    # We want to match: create trigger <name> \n (before|after) ... on <table>
    # Let's use a robust regex
    trigger_pattern = re.compile(r'create trigger (\w+)\s+(before|after)\s+([^\n]+)\s+on\s+([a-zA-Z0-9_.]+)', re.IGNORECASE)
    def trigger_repl(match):
        trigger_name = match.group(1)
        before_after = match.group(2)
        event = match.group(3)
        table_name = match.group(4)
        return f'drop trigger if exists {trigger_name} on {table_name};\ncreate trigger {trigger_name}\n{before_after} {event} on {table_name}'

    content = trigger_pattern.sub(trigger_repl, content)

    # 2. Fix Policies
    policy_pattern = re.compile(r'create policy "([^"]+)" on ([a-zA-Z0-9_.]+)', re.IGNORECASE)
    def policy_repl(match):
        policy_name = match.group(1)
        table_name = match.group(2)
        return f'drop policy if exists "{policy_name}" on {table_name};\ncreate policy "{policy_name}" on {table_name}'
    
    content = policy_pattern.sub(policy_repl, content)

    # 3. Fix Constraints
    constraint_pattern = re.compile(r'alter table ([a-zA-Z0-9_.]+)\s+add constraint (\w+)', re.IGNORECASE)
    def constraint_repl(match):
        table_name = match.group(1)
        constraint_name = match.group(2)
        return f'alter table {table_name} drop constraint if exists {constraint_name};\nalter table {table_name}\nadd constraint {constraint_name}'
    
    content = constraint_pattern.sub(constraint_repl, content)

    # Check for `create index` without `if not exists`
    content = re.sub(r'create index (\w+)', r'create index if not exists \1', content, flags=re.IGNORECASE)
    content = re.sub(r'create unique index (\w+)', r'create unique index if not exists \1', content, flags=re.IGNORECASE)
    # Undo if we accidentally did `create index if not exists if not exists`
    content = re.sub(r'if not exists if not exists', 'if not exists', content, flags=re.IGNORECASE)

    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

for filename in os.listdir(sql_dir):
    if filename.endswith('.sql'):
        process_file(os.path.join(sql_dir, filename))
