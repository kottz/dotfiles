import re
import sys


def srt_to_text(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()

    # Remove subtitle numbers and timestamps
    cleaned_content = re.sub(
        r'\d+\n\d{2}:\d{2}:\d{2},\d{3} --> \d{2}:\d{2}:\d{2},\d{3}\n', '', content)

    # Split into lines and remove empty lines
    lines = [line.strip()
             for line in cleaned_content.split('\n') if line.strip()]

    # Remove duplicates while preserving order
    unique_lines = []
    for line in lines:
        if line not in unique_lines:
            unique_lines.append(line)

    # Join the unique lines into a single paragraph
    final_text = ' '.join(unique_lines)

    return final_text


def main():
    if len(sys.argv) != 2:
        print("Usage: python script.py <path_to_srt_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    try:
        output_text = srt_to_text(input_file)
        #print(output_text)

        # Optionally, save the output to a file
        output_file = input_file.rsplit('.', 1)[0] + '_converted.txt'
        with open(output_file, 'w', encoding='utf-8') as out_file:
            out_file.write(output_text)
        #print(f"\nConverted text has been saved to: {output_file}")
    except FileNotFoundError:
        print(f"Error: The file '{input_file}' was not found.")
    except Exception as e:
        print(f"An error occurred: {e}")


if __name__ == "__main__":
    main()
