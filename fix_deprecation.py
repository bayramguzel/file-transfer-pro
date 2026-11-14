import sys
import re

def fix_file(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Regex to match .withOpacity(value)
        fixed_content = re.sub(r'\.withOpacity\(([^)]+)\)', r'.withValues(alpha: \1)', content)
        
        if content != fixed_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(fixed_content)
            print(f"Fixed {file_path}")
        else:
            print(f"No changes in {file_path}")
    except Exception as e:
        print(f"Error fixing {file_path}: {e}")

if __name__ == "__main__":
    for file_path in sys.argv[1:]:
        fix_file(file_path)
