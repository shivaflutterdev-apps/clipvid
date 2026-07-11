import os
import re

lib_dir = '/Users/shivakumar/AndroidStudioProjects/video_clip/clipvid/lib'

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart') and file != 'constants.dart' and 'theme_bloc' not in root:
            path = os.path.join(root, file)
            with open(path, 'r') as f:
                content = f.read()

            if 'AppColors.' in content:
                # Add import if needed
                if "import '../core/constants.dart';" not in content and "import 'core/constants.dart';" not in content and "import '../../core/constants.dart';" not in content:
                    pass # We will rely on existing imports which are already AppColors
                
                new_lines = []
                for line in content.split('\n'):
                    if 'AppColors.' in line:
                        # Replace AppColors. with context.colors.
                        line = line.replace('AppColors.', 'context.colors.')
                        
                        # Strip 'const ' if present on the same line since dynamic colors break const
                        # This is a naive strip, it might strip const from other valid things on the line,
                        # but it's the safest way to prevent compiler errors.
                        line = re.sub(r'\bconst\s+', '', line)
                        
                    new_lines.append(line)
                
                new_content = '\n'.join(new_lines)
                with open(path, 'w') as f:
                    f.write(new_content)
                print(f"Refactored {path}")
