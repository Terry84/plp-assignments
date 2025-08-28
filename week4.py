try:
    # Step 1: Ask user for filename
    filename = input("Enter the filename to read: ")

    # Step 2: Try opening the file in read mode
    with open(filename, "r") as infile:
        content = infile.read()
        print("\n✅ Original content:")
        print(content)

    # Step 3: Modify content (example: convert to uppercase)
    modified_content = content.upper()

    # Step 4: Save modified content into a new file
    new_filename = "modified_" + filename
    with open(new_filename, "w") as outfile:
        outfile.write(modified_content)

    print(f"\n✅ Modified content has been written to {new_filename}")

# Error handling
except FileNotFoundError:
    print("❌ Error: The file does not exist.")
except PermissionError:
    print("❌ Error: You don’t have permission to read this file.")
except Exception as e:
    print(f"❌ Unexpected error: {e}")
