import sys
import os

def clean_lst(input_path, output_path):
    try:
        with open(input_path, 'r', encoding='utf-8') as infile, \
             open(output_path, 'w', encoding='utf-8') as outfile:
            
            for line in infile:
                # Remove rows that begin with a semicolon in column 0
                if line.startswith(';'):
                    continue
                
                # Strip trailing newlines so we don't accidentally slice them off
                # if the line is exactly 32 characters long.
                line_no_nl = line.rstrip('\r\n')
                
                # Chop off the first 32 columns. 
                # (Python safely handles lines shorter than 32 chars by returning an empty string)
                chopped_line = line_no_nl[32:]
                
                # Write the chopped line back out with a standard newline
                outfile.write(chopped_line + '\n')
                
        print(f"Cleaned output written to: {output_path}")

    except FileNotFoundError:
        print(f"Error: The input file '{input_path}' was not found.")
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: python {os.path.basename(__file__)} <input_file> <output_file>")
        sys.exit(1)

    input_filename = sys.argv[1]
    output_filename = sys.argv[2]
    
    clean_lst(input_filename, output_filename)