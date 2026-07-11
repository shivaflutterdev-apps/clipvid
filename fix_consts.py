import re
import os

analyze_output = """
  error • Invalid constant value • lib/screens/history_screen.dart:168:81 • invalid_constant
  error • Invalid constant value • lib/screens/home_screen.dart:146:30 • invalid_constant
  error • Invalid constant value • lib/screens/home_screen.dart:250:24 • invalid_constant
  error • Invalid constant value • lib/screens/home_screen.dart:349:37 • invalid_constant
  error • Invalid constant value • lib/screens/home_screen.dart:427:30 • invalid_constant
  error • Invalid constant value • lib/screens/login_screen.dart:88:42 • invalid_constant
  error • Invalid constant value • lib/screens/login_screen.dart:160:46 • invalid_constant
  error • Invalid constant value • lib/screens/processing_screen.dart:279:20 • invalid_constant
  error • Invalid constant value • lib/screens/register_screen.dart:90:42 • invalid_constant
  error • Invalid constant value • lib/screens/register_screen.dart:178:46 • invalid_constant
  error • Invalid constant value • lib/screens/results_screen.dart:41:16 • invalid_constant
  error • Invalid constant value • lib/screens/results_screen.dart:53:30 • invalid_constant
  error • Invalid constant value • lib/widgets/clip_card.dart:242:28 • invalid_constant
  error • Invalid constant value • lib/widgets/clip_card.dart:257:32 • invalid_constant
  error • Invalid constant value • lib/widgets/url_input_card.dart:462:26 • invalid_constant
"""

for line in analyze_output.strip().split('\n'):
    if not line.strip(): continue
    parts = line.split('•')
    if len(parts) >= 3:
        file_info = parts[2].strip()
        if file_info.startswith('lib/'):
            filepath, line_num, _ = file_info.split(':')
            line_num = int(line_num) - 1 # 0-indexed
            
            with open(filepath, 'r') as f:
                lines = f.readlines()
            
            # Find the closest 'const ' on this line or above (up to 5 lines)
            for i in range(line_num, max(-1, line_num - 5), -1):
                if 'const ' in lines[i]:
                    lines[i] = re.sub(r'\bconst\s+', '', lines[i])
                    break
            
            with open(filepath, 'w') as f:
                f.writelines(lines)
            print(f"Fixed const in {filepath}:{line_num+1}")
